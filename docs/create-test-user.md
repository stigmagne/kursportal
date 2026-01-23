# Opprette testbruker - Instruksjoner

Siden vi ikke kan endre Supabase sine interne triggers, er den enkleste løsningen å bruke **Supabase CLI** eller **registreringsskjemaet på nettsiden**.

## Alternativ 1: Bruk nettsiden (ANBEFALT)

1. Åpne nettleseren og gå til: `http://localhost:3001/signup`
2. Fyll inn:
   - **Navn:** Stig Brekken
   - **Email:** stig@smeb.no
   - **Passord:** 12345678
3. Klikk "Registrer"

Hvis du får feilmelding, sjekk browser console (F12) for detaljer.

## Alternativ 2: Bruk Supabase CLI

Hvis du har Supabase CLI installert:

```bash
# Opprett bruker
npx supabase auth users create stig@smeb.no --password 12345678

# Eller hvis du har supabase CLI globalt installert:
supabase auth users create stig@smeb.no --password 12345678
```

Deretter, sett navnet i SQL Editor:
```sql
UPDATE profiles 
SET full_name = 'Stig Brekken'
WHERE id = (SELECT id FROM auth.users WHERE email = 'stig@smeb.no');
```

## Alternativ 3: Bruk en annen email

Hvis problemet er at emailen allerede eksisterer, prøv:
- stig.brekken@smeb.no
- stig+test@smeb.no

## Feilsøking

Hvis registreringsskjemaet ikke fungerer, kan det være en av disse årsakene:

1. **Email allerede i bruk** - Sjekk i Supabase Dashboard > Authentication > Users
2. **Trigger-feil** - Sjekk browser console for detaljer
3. **RLS policy** - Sjekk at profiles-tabellen tillater INSERT

For å sjekke om emailen finnes:
```sql
SELECT email FROM auth.users WHERE email = 'stig@smeb.no';
```

For å slette eksisterende bruker (hvis nødvendig):
```sql
DELETE FROM auth.users WHERE email = 'stig@smeb.no';
```
