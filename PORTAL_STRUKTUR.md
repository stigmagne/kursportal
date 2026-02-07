# Kursportal - Struktur og Oversikt

## Innholdsfortegnelse

1. [Mappestruktur](#mappestruktur)
2. [Sider (Routes)](#sider-routes)
3. [Admin-sider](#admin-sider)
4. [Komponenter](#komponenter)
5. [Utils](#utils)
6. [Server Actions](#server-actions)
7. [Database](#database)
8. [Teknologi-stack](#teknologi-stack)

---

## Mappestruktur

```
kursportal/
├── src/
│   ├── app/                          # Next.js App Router
│   │   ├── [locale]/                 # Språkstøtte (no/en)
│   │   │   ├── page.tsx              # Forside
│   │   │   ├── login/                # Innlogging
│   │   │   ├── dashboard/            # Bruker-dashboard
│   │   │   ├── courses/              # Kursoversikt og læring
│   │   │   ├── journal/              # Kryptert dagbok
│   │   │   ├── assessment/           # Selvvurdering
│   │   │   ├── profile/              # Brukerprofil
│   │   │   ├── pricing/              # Priser/abonnement
│   │   │   └── admin/                # Admin-panel
│   │   ├── actions/                  # Server Actions
│   │   └── api/webhooks/             # Stripe webhooks
│   │
│   ├── components/                   # React-komponenter
│   │   ├── ui/                       # Gjenbrukbare UI-elementer
│   │   ├── student/                  # Student-komponenter
│   │   ├── admin/                    # Admin-komponenter
│   │   ├── journal/                  # Journal-komponenter
│   │   ├── assessment/               # Vurdering-komponenter
│   │   └── profile/                  # Profil-komponenter
│   │
│   ├── utils/                        # Hjelpefunksjoner
│   │   ├── supabase/                 # Database-klienter
│   │   └── stripe/                   # Betalingsintegrasjon
│   │
│   ├── types/                        # TypeScript-typer
│   ├── messages/                     # Oversettelser (no.json, en.json)
│   ├── i18n/                         # Internasjonaliseringskonfig
│   └── middleware.ts                 # Auth-middleware
│
├── supabase/
│   ├── migrations/                   # Database-migrasjoner (49 stk)
│   └── schema.sql                    # Komplett database-skjema
│
├── public/                           # Statiske filer
└── package.json                      # Avhengigheter
```

---

## Sider (Routes)

### Offentlige/Bruker-sider

| Side | Sti | Beskrivelse |
|------|-----|-------------|
| **Forside** | `/` | Landing page med hero-seksjon, features og call-to-action |
| **Innlogging** | `/login` | Registrering og innlogging via Supabase Auth |
| **Dashboard** | `/dashboard` | Oversikt over påmeldte kurs, fremgang, sertifikater og badges |
| **Kursoversikt** | `/courses` | Liste over tilgjengelige kurs filtrert på brukergruppe |
| **Kursdetaljer** | `/courses/[id]` | Kursbeskrivelse, moduloversikt og påmeldingsknapp |
| **Læringsmodus** | `/courses/[id]/learn` | Redirect til første leksjon |
| **Leksjon** | `/courses/[id]/learn/[lessonId]` | Leksjonsinnhold med video, tekst, filer og quiz |
| **Journal** | `/journal` | Kryptert dagbok - liste over oppføringer |
| **Ny journalpost** | `/journal/new` | Opprett ny kryptert journaloppføring |
| **Journalverktøy** | `/journal/tools` | 12 strukturerte journalverktøy for refleksjon |
| **Vurdering** | `/assessment` | Velg vurderingstype (søsken/foreldre/team) |
| **Ta vurdering** | `/assessment/[type]` | Gjennomfør selvvurdering med 30 spørsmål |
| **Vurderingsresultat** | `/assessment/results` | Se resultater på 6 dimensjoner og kursanbefalinger |
| **Profil** | `/profile` | Rediger navn, bio, avatar og e-postpreferanser |
| **Priser** | `/pricing` | Abonnementsplaner og Stripe checkout |

---

## Admin-sider

| Side | Sti | Beskrivelse |
|------|-----|-------------|
| **Dashboard** | `/admin` | Statistikk: totalt antall brukere, kurs, påmeldinger, quiz-forsøk |
| **Brukere** | `/admin/users` | Administrer brukere, endre roller, ban/unban |
| **Kurs** | `/admin/courses` | Liste over alle kurs med redigering og sletting |
| **Nytt kurs** | `/admin/courses/new` | Opprett nytt kurs med metadata |
| **Rediger kurs** | `/admin/courses/edit/[id]` | Full kursredigering med moduler, leksjoner og innhold |
| **Quiz-builder** | `/admin/courses/[id]/quiz/new` | Bygg quiz med spørsmål, svaralternativer og forklaringer |
| **Kategorier** | `/admin/categories` | Administrer kurskategorier |
| **Ny kategori** | `/admin/categories/new` | Opprett ny kategori |
| **Rediger kategori** | `/admin/categories/edit/[id]` | Rediger eksisterende kategori |
| **Tags** | `/admin/tags` | Administrer tags for kursmerking |
| **Invitasjoner** | `/admin/invitations` | Opprett og administrer invitasjonskoder for brukergrupper |
| **Analytics** | `/admin/analytics` | Detaljert statistikk med grafer og trender |
| **Innstillinger** | `/admin/settings` | Systeminnstillinger |

---

## Komponenter

### Student-komponenter (`/components/student/`)

| Komponent | Fil | Beskrivelse |
|-----------|-----|-------------|
| **CourseCard** | `CourseCard.tsx` | Kurskort med bilde, fremgangsindikator og "Fortsett"-knapp |
| **CourseList** | `CourseList.tsx` | Responsiv grid-visning av kurs |
| **CourseSidebar** | `CourseSidebar.tsx` | Sidebar med moduler og leksjoner under kursgjennomgang |
| **LessonContent** | `LessonContent.tsx` | Renderer leksjonsinnhold (Markdown, video, filer) |
| **LessonViewer** | `LessonViewer.tsx` | Wrapper-komponent for leksjonsvisning |
| **LessonNavigation** | `LessonNavigation.tsx` | Forrige/Neste-navigasjon mellom leksjoner |
| **LessonComments** | `LessonComments.tsx` | Kommentarfelt på leksjoner med CRUD |
| **LessonSidebar** | `LessonSidebar.tsx` | Kompakt sidebar for leksjonsmodus |
| **QuizTaker** | `QuizTaker.tsx` | Quiz-gjennomføring med tidtaker, scoring og forklaringer |
| **EnrollButton** | `EnrollButton.tsx` | Påmeldingsknapp med loading-state |
| **DashboardContent** | `DashboardContent.tsx` | Hovedinnhold på bruker-dashboard |
| **DashboardControls** | `DashboardControls.tsx` | Filtreringsknapper på dashboard |
| **ContinueLearning** | `ContinueLearning.tsx` | "Fortsett hvor du slapp"-seksjon |
| **RecommendedCourses** | `RecommendedCourses.tsx` | Anbefalte kurs basert på brukergruppe |
| **CertificatesList** | `CertificatesList.tsx` | Liste over opptjente sertifikater |
| **CertificateCard** | `CertificateCard.tsx` | Enkelt sertifikatkort med nedlasting |
| **RecentBadges** | `RecentBadges.tsx` | Nylig opptjente badges |
| **RecentQuizResults** | `RecentQuizResults.tsx` | Siste quiz-resultater med score |
| **RecentActivity** | `RecentActivity.tsx` | Aktivitetslogg |
| **SubscriptionStatus** | `SubscriptionStatus.tsx` | Viser abonnementsstatus og fornyelsesdato |
| **EmptyDashboard** | `EmptyDashboard.tsx` | Visning når bruker ikke har kurs |

### Admin-komponenter (`/components/admin/`)

| Komponent | Fil | Beskrivelse |
|-----------|-----|-------------|
| **CourseEditor** | `CourseEditor.tsx` | Fullstendig kursredigering (moduler, leksjoner, innhold) |
| **CourseList** | `CourseList.tsx` | Admin-liste over kurs med handlinger |
| **ModuleManager** | `ModuleManager.tsx` | Legg til, fjern og sorter moduler med drag-and-drop |
| **LessonManager** | `LessonManager.tsx` | Legg til, fjern og sorter leksjoner |
| **ContentBlockEditor** | `ContentBlockEditor.tsx` | Rediger innholdsblokker (tekst/video/fil) |
| **QuizBuilder** | `QuizBuilder.tsx` | Bygg quiz med spørsmål, svaralternativer og tidsgrense |
| **PrerequisiteEditor** | `PrerequisiteEditor.tsx` | Sett opp kursavhengigheter |
| **UserList** | `UserList.tsx` | Administrer brukere med søk og filtrering |
| **InvitationManager** | `InvitationManager.tsx` | Opprett invitasjonskoder for brukergrupper |
| **InvitationList** | `InvitationList.tsx` | Liste over aktive invitasjoner |
| **EnrollmentManager** | `EnrollmentManager.tsx` | Se og administrer kurspåmeldinger |
| **CategoryForm** | `CategoryForm.tsx` | Opprett/rediger kategorier |
| **CategoryList** | `CategoryList.tsx` | Liste over kategorier |
| **TagsList** | `tags/TagsList.tsx` | Administrer tags |
| **CreateTagDialog** | `tags/CreateTagDialog.tsx` | Dialog for å opprette ny tag |
| **CourseImporter** | `CourseImporter.tsx` | Importer kurs fra JSON-fil |
| **AdminSidebar** | `AdminSidebar.tsx` | Navigasjonsmeny for admin-panelet |

### Admin Analytics (`/components/admin/analytics/`)

| Komponent | Fil | Beskrivelse |
|-----------|-----|-------------|
| **AnalyticsDashboardClient** | `AnalyticsDashboardClient.tsx` | Interaktiv analytics med grafer |
| **CourseCompletionChart** | `CourseCompletionChart.tsx` | Graf over kursgjennomføring |
| **StatsCard** | `StatsCard.tsx` | Statistikkort med tall og trend |

### Journal-komponenter (`/components/journal/`)

| Komponent | Fil | Beskrivelse |
|-----------|-----|-------------|
| **AssessmentTaker** | `AssessmentTaker.tsx` | Gjennomfør psykometrisk vurdering |
| **AssessmentHistory** | `AssessmentHistory.tsx` | Historikk over tidligere vurderinger |
| **JournalReportGenerator** | `JournalReportGenerator.tsx` | Eksporter journal til PDF |

### Assessment-komponenter (`/components/assessment/`)

| Komponent | Fil | Beskrivelse |
|-----------|-----|-------------|
| **AssessmentFlow** | `AssessmentFlow.tsx` | Vurderingsflyt med spørsmål og fremgang |

### Profil-komponenter (`/components/profile/`)

| Komponent | Fil | Beskrivelse |
|-----------|-----|-------------|
| **EmailPreferences** | `EmailPreferences.tsx` | Administrer e-postvarsler |
| **ActivityLog** | `ActivityLog.tsx` | Brukerens aktivitetshistorikk |
| **BadgeCollection** | `BadgeCollection.tsx` | Samling av opptjente badges |

### UI-komponenter (`/components/ui/`)

| Komponent | Fil | Beskrivelse |
|-----------|-----|-------------|
| **Button** | `button.tsx` | Stilisert knapp med varianter (primary, secondary, outline) |
| **Card** | `card.tsx` | Kort-container med header, content og footer |
| **Badge** | `badge.tsx` | Status-merke/etikett |
| **Dialog** | `dialog.tsx` | Modal-dialog med overlay |
| **Progress** | `progress.tsx` | Fremgangsindikator (progress bar) |
| **Textarea** | `textarea.tsx` | Flerlinje tekstfelt |
| **Skeleton** | `Skeleton.tsx` | Loading-placeholder for innhold |
| **Breadcrumb** | `Breadcrumb.tsx` | Brødsmulesti for navigasjon |
| **ScrollArea** | `scroll-area.tsx` | Scrollbar container |

### Globale komponenter (`/components/`)

| Komponent | Fil | Beskrivelse |
|-----------|-----|-------------|
| **Navbar** | `Navbar.tsx` | Hovednavigasjon med logo, lenker og brukerinfo |
| **LanguageSwitcher** | `LanguageSwitcher.tsx` | Bytt mellom norsk og engelsk |
| **SearchBar** | `SearchBar.tsx` | Søkefelt for kurs |
| **NotificationBell** | `NotificationBell.tsx` | Varsler-ikon med teller |
| **NotificationDropdown** | `NotificationDropdown.tsx` | Dropdown med varsler |
| **ConfirmDialog** | `ConfirmDialog.tsx` | Bekreftelsesdialog for destruktive handlinger |
| **CourseProgressSidebar** | `CourseProgressSidebar.tsx` | Fremgangssidebar |
| **QuizTaker** | `QuizTaker.tsx` | Generisk quiz-komponent |

### Providers (`/components/providers/`)

| Komponent | Fil | Beskrivelse |
|-----------|-----|-------------|
| **ToastProvider** | `ToastProvider.tsx` | Context for toast-varsler |

---

## Utils

### Hjelpefunksjoner (`/src/utils/`)

| Fil | Beskrivelse |
|-----|-------------|
| `crypto.ts` | AES-256-GCM kryptering/dekryptering for journal (zero-knowledge) |
| `userGroups.ts` | Logikk for brukergrupper (sibling, parent, team-member, team-leader) |
| `paywall.ts` | Sjekk abonnementsstatus og tilgang |

### Supabase (`/src/utils/supabase/`)

| Fil | Beskrivelse |
|-----|-------------|
| `client.ts` | Supabase browser-klient for client components |
| `server.ts` | Supabase server-klient for server components |
| `middleware.ts` | Supabase auth-håndtering i middleware |

### Stripe (`/src/utils/stripe/`)

| Fil | Beskrivelse |
|-----|-------------|
| `client.ts` | Stripe browser-klient |
| `server.ts` | Stripe server-klient |
| `admin.ts` | Stripe admin-operasjoner |

### Lib (`/src/lib/`)

| Fil | Beskrivelse |
|-----|-------------|
| `utils.ts` | Generelle hjelpefunksjoner (cn, formatDate, etc.) |
| `toast.ts` | Toast-varsler hjelpefunksjoner |
| `certificateGenerator.ts` | Genererer PDF-sertifikater |

---

## Server Actions

### Stripe Actions (`/src/app/actions/stripe.ts`)

| Funksjon | Beskrivelse |
|----------|-------------|
| `createCheckoutSession` | Oppretter Stripe checkout-sesjon for abonnement |
| `createBillingPortalSession` | Oppretter Stripe kundeportal-sesjon |

### Admin Course Actions (`/src/app/actions/admin-course-actions.ts`)

| Funksjon | Beskrivelse |
|----------|-------------|
| `createCourse` | Opprett nytt kurs |
| `updateCourse` | Oppdater eksisterende kurs |
| `deleteCourse` | Slett kurs |
| `importCourse` | Importer kurs fra JSON |
| `duplicateCourse` | Dupliser eksisterende kurs |

### Admin User Actions (`/src/app/actions/admin-user-actions.ts`)

| Funksjon | Beskrivelse |
|----------|-------------|
| `getAdminUsers` | Hent liste over brukere med paginering |
| `updateUser` | Oppdater brukerinfo og rolle |
| `toggleBanUser` | Ban eller unban bruker |
| `anonymizeUser` | Anonymiser brukerdata (GDPR) |

---

## Database

### Hovedtabeller

| Tabell | Beskrivelse |
|--------|-------------|
| `profiles` | Brukerinfo: navn, bio, avatar, rolle (user/admin) |
| `user_groups` | Kobling mellom bruker og gruppe (sibling/parent/team) |
| `invitations` | Invitasjonskoder med gruppe og utløpsdato |

### Kurs og innhold

| Tabell | Beskrivelse |
|--------|-------------|
| `courses` | Kurs: tittel, beskrivelse, bilde, target_group, published |
| `course_modules` | Moduler innenfor kurs med rekkefølge |
| `lessons` | Leksjoner med tittel og rekkefølge |
| `content_blocks` | Innholdsblokker: type (text/video/file), innhold, rekkefølge |
| `categories` | Kurskategorier |
| `tags` | Tags for kursmerking |
| `course_tags` | Kobling mellom kurs og tags |
| `prerequisites` | Kursavhengigheter |

### Quiz

| Tabell | Beskrivelse |
|--------|-------------|
| `quizzes` | Quiz knyttet til leksjon med tidsgrense |
| `quiz_questions` | Spørsmål med tekst og rekkefølge |
| `quiz_answers` | Svaralternativer med is_correct-flagg |
| `quiz_attempts` | Brukerens quiz-forsøk med score og tidspunkt |

### Fremgang

| Tabell | Beskrivelse |
|--------|-------------|
| `user_progress` | Kurspåmeldinger (enrollment) |
| `lesson_completion` | Fullførte leksjoner per bruker |

### Journal (kryptert)

| Tabell | Beskrivelse |
|--------|-------------|
| `journals` | Krypterte dagbokoppføringer (ciphertext, IV) |
| `journal_tools` | Tilgjengelige journalverktøy |

### Vurdering (Assessment)

| Tabell | Beskrivelse |
|--------|-------------|
| `assessment_types` | Vurderingstyper (sibling, parent, team-member, team-leader) |
| `assessment_dimensions` | 6 dimensjoner per vurderingstype |
| `assessment_questions` | 30 spørsmål per vurdering |
| `assessment_sessions` | Brukerens vurderingsforsøk |
| `assessment_responses` | Svar på enkeltspørsmål |
| `assessment_results` | Beregnede resultater per dimensjon |

### Gamification

| Tabell | Beskrivelse |
|--------|-------------|
| `badges` | Tilgjengelige badges (bronze, silver, gold, platinum) |
| `user_badges` | Opptjente badges per bruker |
| `certificates` | Kurssertifikater |

### Betaling

| Tabell | Beskrivelse |
|--------|-------------|
| `products` | Stripe-produkter |
| `prices` | Stripe-priser |
| `subscriptions` | Brukerabonnementer |

---

## Teknologi-stack

| Kategori | Teknologi |
|----------|-----------|
| **Frontend** | Next.js 16.1, React 19, TypeScript |
| **Styling** | Tailwind CSS 4.1, Framer Motion |
| **Backend** | Next.js Server Actions, Server Components |
| **Database** | Supabase (PostgreSQL) med RLS |
| **Auth** | Supabase Auth (e-post/passord) |
| **Kryptering** | Web Crypto API (AES-256-GCM) |
| **Betaling** | Stripe (abonnementer) |
| **Internasjonalisering** | next-intl (norsk + engelsk) |
| **UI-bibliotek** | Radix UI, shadcn/ui |
| **PDF** | jsPDF, @react-pdf/renderer |
| **Grafer** | Recharts |
| **Ikoner** | Lucide React |

---

## Brukergrupper

Portalen støtter 4 brukergrupper med gjensidig eksklusivitet:

| Gruppe | Kode | Beskrivelse |
|--------|------|-------------|
| **Søsken** | `sibling` | Voksne søsken (18+) til personer med funksjonsnedsettelse |
| **Foreldre** | `parent` | Foreldre til personer med funksjonsnedsettelse |
| **Team-medlem** | `team-member` | Ansatte i arbeidsmiljø |
| **Team-leder** | `team-leader` | Ledere i arbeidsmiljø |

**Regler:**
- Kan ikke være både `sibling` og `parent` (gjensidig eksklusivt)
- Kan ha maks 2 grupper (1 familie + 1 jobb)
- Kurser filtreres basert på brukerens grupper

---

## Sikkerhetsmekanismer

| Mekanisme | Beskrivelse |
|-----------|-------------|
| **Row Level Security (RLS)** | Alle tabeller har RLS-policyer |
| **Invitasjonsbasert registrering** | Nye brukere må ha invitasjonskode |
| **Zero-knowledge journal** | Dagbok krypteres client-side, serveren ser aldri klartekst |
| **PBKDF2 nøkkelderivering** | 100 000 iterasjoner for passphrase → nøkkel |
| **Middleware auth-sjekk** | Beskyttede ruter krever innlogging |

---

*Sist oppdatert: Januar 2026*
