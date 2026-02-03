# 🎓 Kursportal - Funksjonsoversikt

> SMEB Stiftelsen - Læringsplattform for søsken, foreldre, arbeidsmiljø og byggebransjen

---

## 📊 Statusoversikt

| Kategori                      | Status          | Sist oppdatert |
| :---------------------------- | :-------------- | :------------- |
| **Kurs-motor**                | ✅ Komplett      | 2. feb 2026    |
| **Quiz-system**               | ✅ Komplett      | 21. jan 2026   |
| **Journal (kryptert)**        | ✅ Komplett      | 26. jan 2026   |
| **Vurderingssystem**          | ✅ Komplett      | 2. feb 2026    |
| **Tilgangskontroll**          | ✅ Komplett      | 2. feb 2026    |
| **Arbeidsmiljø-modul**        | ✅ Komplett      | 26. jan 2026   |
| **Byggebransje-modul**        | ✅ Komplett      | 2. feb 2026    |
| **Invitasjonsbasert tilgang** | ✅ Komplett      | 26. jan 2026   |
| **Mobil-først UX**            | ✅ Komplett      | 27. jan 2026   |
| **PWA-støtte**                | ✅ Komplett      | 27. jan 2026   |
| **Gruppe/Undergruppe-system** | ✅ Komplett      | 2. feb 2026    |
| **Tags-system**               | ✅ Komplett      | 2. feb 2026    |
| **Obligatorisk vurdering**    | ✅ Komplett      | 27. jan 2026   |
| **Stripe-integrasjon**        | ⚠️ Database klar | 26. jan 2026   |
| **Sertifikatsystem**          | ✅ Komplett      | 3. feb 2026    |
| **E-postvarsling**            | ✅ Komplett      | 3. feb 2026    |
| **Admin Dashboard**           | ✅ Komplett      | 3. feb 2026    |

---

## � Tilgangskontroll (6 brukergrupper)

### Brukergrupper

| Gruppe             | Kode                  | Tilgang                                         |
| :----------------- | :-------------------- | :---------------------------------------------- |
| Søsken 18+         | `sibling`             | Søskenkurs, familiejournal, søskenvurdering     |
| Foreldre           | `parent`              | Foreldrekurs, familiejournal, foreldrevurdering |
| Team-medlem        | `team-member`         | Medarbeiderkurs, jobbjournal, team-vurdering    |
| Teamleder          | `team-leader`         | Lederkurs, jobbjournal, ledervurdering          |
| **Håndverker**     | `construction_worker` | Byggebransje-kurs, kvalitet og trygghet         |
| **Bas/Byggeleder** | `site_manager`        | Lederkurs for bygg, økonomi og forebygging      |

### Tilgangsregler

- **Invitasjonsbasert**: Admin sender lenke med spesifikk gruppe
- **Automatisk tildeling**: Gruppe tildeles ved registrering via invitasjonslenke
- **Kursfiltrering**: Kurs tilordnes målgrupper via `target_groups`-kolonne
- **Undergrupper**: Organisasjoner avgrenset kommentarer og samarbeid
- **Admin-oversikt**: Gruppe-badges og filter i kursliste

---

## 📚 Kursinnhold (30 kurs totalt)

### Søskenkurs (6)

| Kurs                       | Fokus                 |
| :------------------------- | :-------------------- |
| *Hvem Er Jeg?*             | Identitet             |
| *Å Forstå Mine Følelser*   | Emosjonell bevissthet |
| *Min Stemme, Mine Grenser* | Kommunikasjon         |
| *Finne Min Stamme*         | Støttenettverk        |
| *Sorg og Aksept*           | Kronisk sorg          |
| *Karriere og Kall*         | Fremtid               |

### Foreldrekurs (6)

| Kurs                         | Fokus                      |
| :--------------------------- | :------------------------- |
| *Kommunikasjon i Familien*   | Aldersriktig kommunikasjon |
| *Å Se Alle Barna*            | Oppmerksomhetsbalanse      |
| *Egen Mestring som Forelder* | Egenomsorg                 |
| *Foreldres Sorg*             | Diagnosesjokk              |
| *Søsken som Ressurs*         | Sunn involvering           |
| *Praktisk Hverdag*           | Tidsplanlegging            |

### Team-medlem kurs (6)

| Kurs                    | Fokus                |
| :---------------------- | :------------------- |
| *Trygg på Jobb*         | Psykologisk trygghet |
| *Min Plass i Teamet*    | Tilhørighet          |
| *Kommunikasjon på Jobb* | Aktiv lytting        |
| *Sunne Grenser på Jobb* | Work-life balance    |
| *Håndtere Konflikt*     | Konflikthåndtering   |
| *Vekst og Mestring*     | Growth mindset       |

### Teamleder-kurs (6)

| Kurs                          | Fokus          |
| :---------------------------- | :------------- |
| *Lederen som Trygghetsskaper* | Skape trygghet |
| *Inkluderende Ledelse*        | Mangfold       |
| *Tilbakemeldingskultur*       | Feedback       |
| *Delegering og Tillit*        | Autonomi       |
| *Lederens Konflikthåndtering* | Mekling        |
| *Lederens Egenomsorg*         | Stressmestring |

### Håndverker-kurs (3) - NYTT

| Kurs                       | Fokus                                              |
| :------------------------- | :------------------------------------------------- |
| *Si Fra Før Det Blir Dyrt* | Stoppe feil tidlig, si fra ved usikkerhet          |
| *Feilreisen*               | Forstå hvordan feil utvikler seg til reklamasjoner |
| *Stolthet Og Kvalitet*     | Fagstolthet som driver for kvalitet                |

### Bas/Byggeleder-kurs (3) - NYTT

| Kurs                          | Fokus                            |
| :---------------------------- | :------------------------------- |
| *Lederen Som Trygghetsskaper* | Skape trygg kultur på byggeplass |
| *Feil Koster - Ditt Ansvar*   | Økonomi bak reklamasjoner        |
| *Fra Innsikt Til Tiltak*      | Implementere forebyggende tiltak |

---

## 🏷️ Tags-system

### Funksjonalitet

- **Emne-tags**: Kategoriserer kurs etter tema (Ernæring, Psykologisk trygghet, osv.)
- **Gruppe-synlighet**: Tags kan begrenses til spesifikke brukergrupper
- **Admin-side**: `/admin/tags` for å administrere alle tags
- **Filtrering**: Brukere kan filtrere kurskatalogen etter tags

### Teknisk

- `tags`-tabell med `target_groups`-kolonne for synlighet
- `course_tags`-junctiontabell for kurs-tag-relasjoner
- RLS-policies for gruppebasert synlighet

---

## 📱 Mobil-først UX

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
- **Service Worker**: Cacher leksjoner automatisk
- **Offline-modus**: Viser lagrede leksjoner uten nett

---

## 🔗 Integrasjoner

| Plattform           | Type       | Varsel-hendelser                       |
| :------------------ | :--------- | :------------------------------------- |
| **Slack**           | Webhook    | Ny bruker, kurs fullført, quiz bestått |
| **Discord**         | Webhook    | Ny bruker, kurs fullført, quiz bestått |
| **Microsoft Teams** | Webhook    | Ny bruker, kurs fullført, quiz bestått |
| **Resend**          | E-postAPI  | Velkomst, sertifikat, påminnelser      |
| **Stripe**          | Betalinger | Abonnementer og enkeltbetalinger       |

Konfigureres i Admin → Innstillinger → Integrasjoner.

---

## 🎯 Vurderingssystem (150+ spørsmål, 30 dimensjoner)

**5 vurderingstyper** tilpasset hver brukergruppe:
- Søsken-vurdering
- Foreldre-vurdering  
- Team-medlem vurdering
- Leder-vurdering
- Byggebransje-vurdering

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

| Migrasjon | Innhold                                       |
| :-------- | :-------------------------------------------- |
| 037-038   | Vurdering + Journal (SMEB)                    |
| 039-044   | Søsken/foreldre-kurs                          |
| 045       | Arbeidsmiljø vurdering (60 spørsmål)          |
| 046       | Arbeidsmiljø journalverktøy                   |
| 047       | Team-medlem kurs (6)                          |
| 048       | Leder-kurs (6)                                |
| 049       | Invitasjonsbasert tilgangskontroll            |
| 055       | Webhook-integrasjoner (Slack, Discord, Teams) |
| 056       | Undergruppe-støtte i invitasjoner             |
| 066-074   | Komplett leksjonsinnhold alle grupper         |
| 075       | Håndverker-kurs (3)                           |
| 076       | Bas/Byggeleder-kurs (3)                       |
| 077       | Byggebransje-vurdering                        |
| 078       | Mental helse bygg-kurs                        |
| 079       | Unicode-symboler erstatter emojis             |
| 080       | Tag-gruppesynlighet                           |
| 081-084   | Target_groups konsolidering                   |

---

## 🧪 Testbrukere

| E-post                | Passord  | Gruppe      |
| :-------------------- | :------- | :---------- |
| <foreldre@smeb.no>    | Pass1234 | parent      |
| <sosken@smeb.no>      | Pass1234 | sibling     |
| <team-medlem@smeb.no> | Pass1234 | team-member |
| <team-leder@smeb.no>  | Pass1234 | team-leader |

---

## ⚠️ Mangler / Pågående

- [ ] Stripe Checkout-flyt
- [ ] Abonnements-håndtering
- [ ] Video-innhold for leksjoner
- [ ] Testbrukere for byggebransjen

---

## 💡 Idéer og Forbedringer

### Høy Prioritet

- [x] **Video-integrasjon**: Vimeo + YouTube embedding i leksjoner ✅
- [x] **Ferdigstillelsesbevis**: PDF-sertifikat ved fullført kurs ✅
- [x] **E-postvarsler**: Automatisk påminnelse om uavsluttede kurs ✅
- [x] **Statistikkpanel**: Utvidet statistikk for admin (completion rate, tid brukt) ✅

### Medium Prioritet

- [x] **Gamification**: Badges, streaks, XP-system ✅
- [x] **Sosial læring**: Diskusjonsforum per kurs ✅
- [ ] **Mentor-matching**: Koble erfarne brukere med nykommere
- [ ] **Flere språk**: Engelsk versjon av alt innhold
- [ ] **SCORM-eksport**: Eksportere kurs til andre LMS-systemer

### Lav Prioritet / Fremtidige Idéer

- [ ] **AI-generert sammendrag**: Oppsummering av leksjoner
- [ ] **Mikrolæring**: 2-minutters "snacks" med nøkkelpunkter
- [ ] **Podcast-modus**: Lytt til leksjoner som audio
- [ ] **VR-trening**: Simulering av vanskelige samtaler
- [ ] **Integrasjon med HR-systemer**: Synkronisere fremgang med bedriftssystemer

### Tekniske Forbedringer

- [x] **Bedre caching**: Service worker-oppdatering for raskere lasting ✅
- [ ] **Søkefunksjon**: Globalt søk på tvers av kurs og leksjoner
- [x] **Tilgjengelighet (a11y)**: WCAG 2.1 AA compliance-gjennomgang ✅
- [x] **Performance-optimalisering**: Lazy loading av moduler ✅

### UI/UX Forbedringer

- [x] **Profilside badges**: Erstatte emojis med Lucide-ikoner på `/profile`-siden ✅
- [x] **Profilside styling**: Oppdatere knapper og rammer i Oversikt-seksjonen til neo-brutalist design ✅
- [x] **Kursside styling**: Oppdatere header og modulliste til neo-brutalist design ✅

### Innholdsforbedringer

- [ ] **Flere quizer**: Quiz for hver modul, ikke bare hvert kurs
- [ ] **Interaktive elementer**: Drag-and-drop, flervalg i leksjonene
- [ ] **Case studies**: Virkelige historier fra målgruppene
- [ ] **Ekspertvideo**: Intervjuer med fagpersoner

---

*Sist oppdatert: 3. februar 2026 (Neo-brutalist Redesign)*
