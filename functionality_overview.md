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
| **Stripe-integrasjon** | ⚠️ Database klar | 26. jan 2026 |

---

## � Tilgangskontroll (Invitasjonsbasert)

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

### Hva filtreres

- Kursene på `/courses` vises kun for brukerens gruppe(r)
- Vurderingene på `/assessment` vises kun for brukerens gruppe(r)
- Journalverktøy filtreres etter `target_groups`
- Anbefalte kurs på dashboard filtreres

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
