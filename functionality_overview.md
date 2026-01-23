# Funksjonell Oversikt: Kurs- og Abonnementportal

**Dato:** 21. januar 2026

Denne rapporten gir en oversikt over faktisk implementert funksjonalitet i portalen, vurdert opp mot visjonen om en **Kursportal med Abonnementsløsning**.

---

## 1. Implementert Funksjonalitet (LMS-kjernen)

Systemet har i dag en solid kjerne for Learning Management (LMS), som fungerer for kursgjennomføring.

### 🎓 For Deltakere (Studenter)
*   **Dashboard (`/dashboard`):**
    *   Personlig oversikt over påbegynte kurs.
    *   Fremdriftsindikatorer (prosentvis fullført).
    *   Anbefalte kurs (basert på hva man ikke har tatt).
    *   "Badges" og aktivitetslogg.
*   **Kursavspiller:**
    *   Støtte for leksjoner med tekst og video.
    *   Modulbasert navigasjon.
*   **Kunnskapskontroll:**
    *   Integrerte quizer med umiddelbar feedback (Bestått/Ikke bestått).

### 🛡️ For Administratorer (`/admin`)
*   **Innholdsproduksjon:**
    *   **Kurs-bygger (`/admin/courses`):** Komplett verktøy for å lage struktur, moduler og leksjoner.
    *   **Quiz-bygger:** Verktøy for å lage tester med svaralternativer.
    *   **Innholdseditor:** Rich-text redigering av leksjoner.
*   **Brukeradministrasjon:**
    *   Oversikt over brukere og deres fremdrift.
    *   Mulighet for utestengelse og anonymisering.
    *   Invitasjonssystem ("Tickets") for å gi tilgang manuelt.

---

## 2. Manglende Funksjonalitet (Visjon: Abonnement)

For å realisere visjonen om at *"de som ikke har vært med kan kjøpe månedsabonnement"*, mangler hele betalings- og tilgangslaget.

### 🔴 Kritisk Mangler (Må bygges)
*   **Betalingsløsning:**
    *   Ingen integrasjon mot betalingsleverandør (f.eks. Stripe eller Vipps).
    *   Ingen logikk for å håndtere *"Abonnement"* (Recurring payments).
*   **Produkt/Pakke-styring:**
    *   Ingen database-tabeller for å definere produkter (f.eks. "Månedsabonnement", "Enkeltkurs").
    *   Ingen "Paywall" som sjekker om brukeren har *betalt* før de får tilgang til kurs (idag styres dette kun av om man er "enrolled" eller har en "ticket").
*   **Kjøpsflyt:**
    *   Ingen "Checkout"-side eller handlekurv.
    *   Ingen "Min Side / Faktura" for å se betalingshistorikk.

---

## 3. Konklusjon

Kodebasen er ren og fri for "Forenings"-logikk (ingen spor av dugnad, styremøter etc. i koden, kun i gammel dokumentasjon).

**Status:**
*   ✅ **Kurs-motor:** Ferdig implementert.
*   ❌ **Abonnements-motor:** Ikke påbegynt.

**Anbefalt neste steg:**
1.  Design datamodell for `Subscriptions` og `Products`.
2.  Implementer betalingsintegrasjon (f.eks. Stripe Checkout).
3.  Bygg en "Pricing Page" og koble betalingsstatus mot kurstilgang.
