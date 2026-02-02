# Sikkerhetsrapport og Sårbarhetsanalyse

**Dato:** 21. januar 2026 (oppdatert 2. februar 2026)
**Status:** ✅ KRITISKE SÅRBARHETER FIKSET

> **Oppdatering 2. feb 2026:** Den kritiske privilege escalation-sårbarheten er nå fikset via:
> - `033_secure_role_updates.sql` - Trigger som blokkerer rolleendringer fra vanlige brukere
> - `050_security_improvements.sql` - RLS-policy som eksplisitt ekskluderer rolle-oppdateringer

Denne rapporten oppsummerer sikkerhetsgjennomgangen av SMEB Kursportal (basert på nåværende kildekode).

## 1. Oppsummering
Jeg har gjennomført en manuell sjekk av kodebasen med fokus på RLS (Row Level Security), autentisering, og autorisasjon. 

**Hovedfunn:**
Det er funnet et **kritisk sikkerhetshull** i database-policyen som teoretisk tillater enhver innlogget bruker å oppgradere seg selv til administrator. I tillegg er beskyttelsen av admin-ruter i hovedsak basert på UI-logikk (Layout) fremfor streng middleware-håndheving, noe som er risikabelt.

---

## 2. Kritiske Sårbarheter (High Severity)

### 🔴 2.1 Egen-oppgradering til Admin (Privilege Escalation)
**Sted:** `supabase/schema.sql` (Linje 23-24)

**Kode:**
```sql
create policy "Users can update own profile"
  on profiles for update using ( auth.uid() = id );
```

**Problem:**
Denne policyen tillater en bruker å oppdatere *alle* kolonner i sin egen rad i `profiles`-tabellen. Siden `role` (som styrer om du er 'admin' eller 'member') lagres i samme tabell, kan en ondsinnet bruker sende en API-forespørsel direkte til Supabase (utenom nettsiden) og sette `role = 'admin'`.

**Konsekvens:**
En vanlig bruker kan få full tilgang til admin-panelet, slette brukere, endre innhold, og få tilgang til sensitive data.

**Anbefalt Løsning:**
Du må begrense hvilke kolonner en bruker kan oppdatere, eller flytte rollen til en egen tabell/mekanisme. Den enkleste fixen er å bruke en database-trigger eller definere kolonner i policyen (hvis Postgres-versjonen støtter det), men det vanligste i Supabase er å ha en `handle_profile_update` funksjon eller sjekke dataene som kommer inn.

Enda bedre: Fjern `UPDATE`-rettigheter for vanlige brukere på `role`-kolonnen ved å splitte dataene eller bruke en `BEFORE UPDATE` trigger som nekter endring av `role` hvis `auth.uid()` ikke allerede er admin (noe som blir sirkulært), så det tryggeste er:
**Bruk en `BEFORE UPDATE` trigger for å hindre endring av sensitive felter.**

**Forslag til fix (SQL):**
```sql
-- 1. Lag en funksjon som sjekker om rollen endres
create or replace function public.forbid_role_change()
returns trigger as $$
begin
  -- Hvis bruker prøver å endre rollen sin, og de ikke allerede er admin (eller systemet gjør det), blokker det.
  -- Enklest: Bare nekt endring av role-kolonnen via vanlig API for eier.
  if new.role is distinct from old.role then
     -- Her kan man legge inn logikk for at KUN service_role kan endre dette, 
     -- men RLS gjelder ikke for service_role uansett. 
     -- Siden policyen "Users can update own profile" kjøres som brukeren selv:
     raise exception 'You are not allowed to change your own role.';
  end if;
  return new;
end;
$$ language plpgsql;

-- 2. Koble den til tabellen
create trigger on_profile_update_secure_role
  before update on public.profiles
  for each row execute procedure public.forbid_role_change();
```

---

## 3. Middels Risiko (Medium Severity)

### 🟠 3.1 Svak Rute-beskyttelse (Middleware)
**Sted:** `src/middleware.ts` og `src/app/[locale]/admin/layout.tsx`

**Problem:**
Middlewaren (`src/middleware.ts`) sjekker kun om sesjonen er gyldig, den sjekker *ikke* roller.
Beskyttelsen av `/admin` gjøres i `layout.tsx`. Dette er "greit" for sidevisninger i Next.js App Router, men det beskytter ikke nødvendigvis API-ruter eller Server Actions hvis de ikke eksplisitt gjentar sjekken.

Hvis du oppretter en ny `page.tsx` under `/admin` men glemmer å sjekke auth i selve data-hentingen (og stoler på at layout stopper renderingen), kan data lekke hvis komponenten er en Client Component som henter data selv, eller hvis `layout` feiler på en uventet måte.

**Anbefalt Løsning:**
Implementer sjekk av `admin`-rolle direkte i Middleware for alle ruter som starter med `/admin`, ELLER sørg for at *hver eneste* Server Action og Database Call sjekker `isAdmin`.

### 🟠 3.2 Server Actions Autorisasjon
**Sted:** `src/app/actions/admin-user-actions.ts`

**Observasjon:**
Funksjoner som `updateUser` i `admin-user-actions.ts` bruker:
```typescript
const supabase = await createServerClient();
// ...
const { error } = await supabase.from('profiles').update(...)
```
Her stoler vi 100% på at RLS stopper en vanlig bruker fra å kalle denne Server Action-en for å oppdatere andres profiler.
*   Hvis RLS er satt opp riktig (bruker kan kun oppdatere seg selv), så kan ikke bruker A oppdatere bruker B.
*   MEN, hvis en bruker A kaller denne funksjonen med *sine egne* data, men endrer `role` (se punkt 2.1), så smeller det.
*   En admin som bruker denne funksjonen vil bli blokkert av RLS hvis policyen er "Users can update own profile", med mindre admin også har en "Admins can update all profiles"-policy.
    *   Sjekk `schema.sql`: Det mangler faktisk en `create policy "Admins can update all profiles" ...`.
    *   Dette betyr at `updateUser` funksjonen sannsynligvis *feiler* for admin når de prøver å oppdatere andre, med mindre de bruker `getSupabaseAdmin()` (Service Role). I koden bruker `updateUser` *ikke* service role, den bruker `createServerClient()`.

**Konklusjon:** Admin-funksjonen for å oppdatere brukere vil sannsynligvis feile for andre enn admin selv, ELLER hvis RLS mangler admin-tilgang. (Koden viser at `toggleBanUser` bruker `getSupabaseAdmin`, men `updateUser` bruker vanlig klient).

---

## 4. Andre Observasjoner

### 🔵 4.1 Generelle "Best Practices"
*   **Service Role Usage:** Det er bra at `getSupabaseAdmin` er skilt ut og sjekker miljøvariabler.
*   **Anonymisering:** God praksis å ha en dedikert anonymiseringsfunksjon for GDPR.
*   **Feilhåndtering:** Koden har lagt inn `try/catch` rundt bruker-henting for å unngå krasj (ref. tidligere debuggings-arbeid), noe som er bra for stabilitet.

## 5. Konklusjon og Tiltaksplan

1.  **HASTER:** Implementer en trigger eller juster RLS for å hindre at brukere kan endre sin egen `role`.
2.  **VIKTIG:** Gå gjennom `admin-user-actions.ts` og sørg for at *alle* admin-handlinger bruker `getSupabaseAdmin()` (Service Role) ELLER at du legger til en RLS-policy: `create policy "Admins can update all profiles" ...`. Slik det er nå, ser det ut til at `updateUser` er inkonsistent med `toggleBanUser`.
3.  **ANBEFALT:** Legg til rolle-sjekk i `middleware.ts` for å blokkere `/admin` forespørsler tidlig.
