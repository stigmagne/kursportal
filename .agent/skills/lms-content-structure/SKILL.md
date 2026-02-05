---
name: LMS Content Structure Protocol
description: Standardized JSON structures and rules for adding new courses, modules, and gamification elements.
---

# LMS Content Structure Protocol

This skill defines the data models and rules for expanding the course catalog. All new content MUST adhere to this structure to ensure compatibility with the gamification engine and RLS policies.

## 1. Course Data Model
Courses are the top-level container.
- **Slug:** Must be URL-friendly (kebab-case).
- **Target Groups:** Array of user group codes (e.g., `['team-leader', 'site_manager']`).
- **Access Level:** `open` or `invite_only`.

```json
{
  "slug": "lederens-konflikthandtering",
  "title": "Lederens Konflikthåndtering",
  "description": "Lær å mekle og løse konflikter på en konstruktiv måte.",
  "target_groups": ["team-leader", "site_manager"],
  "tags": ["ledelse", "kommunikasjon"],
  "modules": [ ... ]
}
```

## 2. Module & Lesson Structure
Each course consists of Modules, which contain Lessons.
- **Micro-learning:** Keep lessons under 5 minutes read time.
- **Interactivity:** Every module SHOULD end with a Quiz.

```json
{
  "title": "Modul 1: Hva er en konflikt?",
  "lessons": [
    {
      "title": "Konfliktens natur",
      "content_type": "text/video",
      "video_url": "https://vimeo.com/...", // Optional
      "content_markdown": "## Introduksjon..."
    }
  ],
  "quiz": { ... }
}
```

## 3. Quiz & Assessment Standard
Quizzes trigger gamification events (XP, Streaks).
- **Passing Score:** Default is 80%.
- **Question Types:** `multiple_choice`, `true_false`.
- **Feedback:** Must provide feedback for WRONG answers to facilitate learning.

```json
"quiz": {
  "title": "Sjekk din forståelse",
  "passing_score": 80,
  "questions": [
    {
      "question": "Er alle konflikter negative?",
      "options": [
        { "text": "Ja, alltid", "correct": false },
        { "text": "Nei, de kan skape vekst", "correct": true }
      ],
      "explanation": "Konflikter kan lede til bedre løsninger hvis de håndteres rett."
    }
  ]
}
```

## 4. Gamification Triggers
System automatically awards:
- **Course Completion:** When all modules + quizzes are passed.
- **Perfect Score Badge:** If 100% on first try.
- **Streak:** Daily login + 1 lesson read.

**Manual Badges:**
To add a custom badge (e.g., "Master Mediator"), add it to the `badges` table and link it via `course_completion_badge_id` in the course definition.

## 5. RLS & Access Control
- **Strict Separation:** A user in `siblings` group MUST NOT see `construction_worker` content.
- **Testing:** Always create a test user in the specific target group to verify visibility before deploying.
