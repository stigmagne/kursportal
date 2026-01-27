# 🎓 Kursportal - Funksjonsoversikt

> SMEB Stiftelsen - Læringsplattform for søsken, foreldre og arbeidsmiljø

---

## 📊 Statusoversikt

| Kategori | Status | Sist oppdatert |
| :------- | :----- | :------------- |
| **Kurs-motor** | ✅ Komplett | 26. jan 2026 |
| **Quiz-system** | ✅ Komplett | 21. jan 2026 |
| **Journal (kryptert)** | ✅ Komplett | 26. jan 2026 |
| **Vurderingssystem** | ✅ Komplett | 26. jan 2026 |
| **Tilgangskontroll** | ✅ Komplett | 26. jan 2026 |
| **Arbeidsmiljø-modul** | ✅ Komplett | 26. jan 2026 |
| **Invitasjonsbasert tilgang** | ✅ Komplett | 26. jan 2026 |
| **Mobil-først UX** | ✅ Komplett | 27. jan 2026 |
| **PWA-støtte** | ✅ Komplett | 27. jan 2026 |
| **Gruppe/Undergruppe-system** | ✅ Komplett | 27. jan 2026 |
| **Obligatorisk vurdering** | ✅ Komplett | 27. jan 2026 |
| **Stripe-integrasjon** | ⚠️ Database klar | 26. jan 2026 |

---

## 📱 Mobil-først UX (Nytt!)

### Læringsmodus

- **Hamburger-sidebar**: Kursmeny skjules bak ikon på mobil
- **Sticky navigasjon**: Forrige/Fullført/Neste alltid synlig nederst
- **Fokusert læring**: Skjuler navbar i læringsmodus

### Dashboard

- **Forenklet visning**: Badges, quizresultater, aktivitet skjult på mobil
- **Continue Learning**: Primært fokus på neste leksjon

### Journal

- **Fullskjerm editor**: Distraksjonfri skriving på mobil
- **Sticky lagre-knapp**: Alltid tilgjengelig nederst
- **Autosave**: Lagrer lokalt mens du skriver

### Navigasjon

- **MobileBottomNav**: Fast bunn-meny (Hjem, Kurs, Journal, Profil)
- **App-lik opplevelse**: 4 hovedlenker med ikoner

### PWA

- **Installerbar**: Kan legges på hjemskjerm
- **Standalone**: Kjører i fullskjerm uten nettlesergrensesnitt
- **App-ikoner**: 192x192 og 512x512 PNG
- **Service Worker**: Cacher leksjoner automatisk
- **Offline-modus**: Viser lagrede leksjoner uten nett
- **Fallback-side**: Norsk "Du er offline"-side

---

## 🔗 Integrasjoner

| Plattform | Type | Varsel-hendelser |
| :-------- | :--- | :--------------- |
| **Slack** | Webhook | Ny bruker, kurs fullført, quiz bestått |
| **Discord** | Webhook | Ny bruker, kurs fullført, quiz bestått |
| **Microsoft Teams** | Webhook | Ny bruker, kurs fullført, quiz bestått |
| **Stripe** | Betalinger | Abonnementer og enkeltbetalinger |

Konfigureres i Admin → Innstillinger → Integrasjoner.

---

## 🔐 Tilgangskontroll (Invitasjonsbasert)

### Brukergrupper

| Gruppe | Kode | Tilgang |
| :------- | :----- | :-------- |
| Søsken 18+ | `sibling` | Søskenkurs, familiejournal, søskenvurdering |
| Foreldre | `parent` | Foreldrekurs, familiejournal, foreldrevurdering |
| Team-medlem | `team-member` | Medarbeiderkurs, jobbjournal, team-vurdering |
| Leder | `team-leader` | Lederkurs, jobbjournal, ledervurdering |

### Tilgangsregler

- **Invitasjonsbasert**: Admin sender lenke med spesifikk gruppe
- **Automatisk tildeling**: Gruppe tildeles ved registrering via invitasjonslenke
- **Gjensidig ekskluderende**: sibling↔parent og team-member↔team-leader kan ikke kombineres
- **Maks 2 grupper**: Én fra familie-verden + én fra jobb-verden

- **Undergrupper**: Organisasjoner (NFTSC, Sykehus X, osv.) avgrenset kommentarer
- **Kursoversikt**: Gruppe-badges og filter i admin-panel

---

## 📚 Kursinnhold (24 kurs totalt)

### Søskenkurs (6)

| Kurs | Fokus |
| :--- | :---- |
| *Å Forstå Mine Følelser* | Emosjonell bevissthet |
| *Min Stemme, Mine Grenser* | Kommunikasjon |
| *Hvem Er Jeg?* | Identitet |
| *Sorg og Aksept* | Kronisk sorg |
| *Karriere og Kall* | Fremtid |
| *Finne Min Stamme* | Støttenettverk |

### Foreldrekurs (6)

| Kurs | Fokus |
| :--- | :---- |
| *Å Se Alle Barna* | Oppmerksomhetsbalanse |
| *Kommunikasjon i Familien* | Aldersriktig kommunikasjon |
| *Egen Mestring som Forelder* | Egenomsorg |
| *Praktisk Hverdag* | Tidsplanlegging |
| *Foreldres Sorg* | Diagnosesjokk |
| *Søsken som Ressurs* | Sunn involvering |

### Team-medlem kurs (6)

| Kurs | Fokus |
| :--- | :---- |
| *Trygg på Jobb* | Psykologisk trygghet |
| *Min Plass i Teamet* | Tilhørighet |
| *Kommunikasjon på Jobb* | Aktiv lytting |
| *Sunne Grenser på Jobb* | Work-life balance |
| *Håndtere Konflikt* | Konflikthåndtering |
| *Vekst og Mestring* | Growth mindset |

### Leder-kurs (6)

| Kurs | Fokus |
| :--- | :---- |
| *Lederen som Trygghetsskaper* | Skape trygghet |
| *Inkluderende Ledelse* | Mangfold |
| *Tilbakemeldingskultur* | Feedback |
| *Delegering og Tillit* | Autonomi |
| *Lederens Konflikthåndtering* | Mekling |
| *Lederens Egenomsorg* | Stressmestring |

---

## 🎯 Vurderingssystem (120 spørsmål, 24 dimensjoner)

**4 vurderingstyper** med 30 spørsmål og 6 dimensjoner hver.

Hver dimensjon mapper til 1-2 anbefalte kurs basert på score.

### Obligatorisk onboarding

- **Førstegangsbruker**: Må fullføre vurdering før kurstilgang
- **Re-vurdering**: Påminnelse hver 3. måned
- **Progresjonssporing**: Sammenligning med tidligere vurderinger

---

## 📓 Journalverktøy (12 stk)

### Familie-fokusert (7)

Følelsesdagbok, Følelsesskala, Energibarometer, Takknemlighetslogg, Bekymringsboks, Mestringssituasjoner, Relasjonsrefleksjon

### Jobb-fokusert (5)

Daglig sjekk-inn, Trygghetsdagbok, Feedback-logg, Konflikt-refleksjon, Grense-tracker

Alle kryptert med AES-256-GCM (zero-knowledge).

---

## 🗄️ Database-migrasjoner

| Migrasjon | Innhold |
| :-------- | :------ |
| 037-038 | Vurdering + Journal (SMEB) |
| 039-044 | Søsken/foreldre-kurs |
| 045 | Arbeidsmiljø vurdering (60 spørsmål) |
| 046 | Arbeidsmiljø journalverktøy |
| 047 | Team-medlem kurs (6) |
| 048 | Leder-kurs (6) |
| 049 | Invitasjonsbasert tilgangskontroll |
| 055 | Webhook-integrasjoner (Slack, Discord, Teams) |
| 056 | Undergruppe-støtte i invitasjoner |

---

## 🧪 Testbrukere

| E-post | Passord | Gruppe |
| :----- | :------ | :----- |
| <foreldre@smeb.no> | Pass1234 | parent |
| <sosken@smeb.no> | Pass1234 | sibling |
| <team-medlem@smeb.no> | Pass1234 | team-member |
| <team-leder@smeb.no> | Pass1234 | team-leader |

---

## ⚠️ Mangler

- [ ] Stripe Checkout-flyt
- [ ] Abonnements-håndtering
