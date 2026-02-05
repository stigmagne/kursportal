---
name: Neo-Brutalist Design System
description: A guide to implementing the project's consistent Neo-Brutalist aesthetic, including ready-to-use Tailwind class combinations for common components.
---

# Neo-Brutalist Design System

This project uses a strict Neo-Brutalist aesthetic characterized by high contrast, bold borders, hard shadows, and distinct hover states.

## Core Design Tokens

### Borders
All structural elements (cards, inputs, buttons) use a thick black border.
- **Class:** `border-4 border-black`
- **Use on:** Cards, Buttons, Inputs, Modals, Images

### Shadows
We use hard, offset shadows. No soft blurs.
- **Default Shadow:** `shadow-[8px_8px_0px_0px_rgba(0,0,0,1)]`
- **Small Shadow:** `shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]` (Use for smaller buttons or tags)

### Hover States (Interactive Elements)
Interactive elements should feel tactile. When hovered/clicked, they should move "down" and "right" to simulate being pressed, and the shadow should descrease or disappear.

**Standard Button Hover:**
- **Initial:** `translate-x-0 translate-y-0 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]`
- **Hover:** `hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-none` (or `hover:shadow-[2px_2px...]`)
*Note: Make sure to add `transition-all`.*

## Component Recipes

### 1. Primary Button
Used for main actions (Submit, CTA).
```tsx
<button className="
  px-6 py-3 
  font-bold text-lg 
  bg-primary text-primary-foreground 
  border-4 border-black 
  shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] 
  hover:shadow-none 
  hover:translate-x-[4px] hover:translate-y-[4px] 
  transition-all
">
  Click Me
</button>
```

### 2. Secondary / Outline Button
Used for secondary actions (Cancel, Back).
```tsx
<button className="
  px-6 py-3 
  font-bold text-lg 
  bg-white text-black 
  border-4 border-black 
  shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] 
  hover:shadow-none 
  hover:translate-x-[4px] hover:translate-y-[4px] 
  transition-all
">
  Cancel
</button>
```

### 3. Card Container
Used for grouping content (Forms, Feature lists).
```tsx
<div className="
  bg-white 
  border-4 border-black 
  p-8 
  shadow-[8px_8px_0px_0px_rgba(0,0,0,1)]
">
  {children}
</div>
```

### 4. Input Field
```tsx
<div className="flex flex-col gap-2">
  <label className="font-bold text-sm flex items-center gap-2">
    <Icon className="w-4 h-4" />
    Label
  </label>
  <input className="
    w-full 
    px-4 py-3 
    border-2 border-black 
    focus:outline-none 
    focus:ring-2 focus:ring-primary 
    focus:border-black
  " />
</div>
```

### 5. Badge / Tag
```tsx
<span className="
  inline-block 
  bg-primary text-primary-foreground 
  px-3 py-1 
  text-sm font-bold 
  border-2 border-black 
  shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]
">
  Badge
</span>
```

## Icons
Use `lucide-react` icons.
- **Stroke Width:** Default or Bold (e.g., `stroke-[3]`) often matches better.
- **Size:** `w-6 h-6` is standard for buttons.

## Colors
- **Background:** `bg-secondary` (often a light distinct color like beige or light gray) for the page background.
- **Surface:** `bg-white` for cards/sections.
- **Accent:** `bg-primary` for primary actions.
