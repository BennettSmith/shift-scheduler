# Troop 900 Tree Lot Scheduler
## iOS UI Design Specification

**Version:** 1.0  
**Date:** December 2024  
**Project:** iOS presentation layer specification for the Troop 900 Tree Lot Shift Scheduler

---

## Table of Contents

1. [Design Philosophy](#design-philosophy)
2. [Design System](#design-system)
3. [App Structure & Navigation](#app-structure--navigation)
4. [Tab 1: Home](#tab-1-home)
5. [Tab 2: Schedule](#tab-2-schedule)
6. [Tab 3: Check-In](#tab-3-check-in)
7. [Tab 4: Profile](#tab-4-profile)
8. [Tab 5: Committee](#tab-5-committee)
9. [Common Components](#common-components)
10. [Role-Based Variations](#role-based-variations)
11. [State Handling](#state-handling)
12. [Accessibility](#accessibility)

---

## Design Philosophy

### Visual Style
**Clean and polished.** The app should feel modern, trustworthy, and easy to navigate. Avoid clutter. Use whitespace generously. Prioritize clarity over decoration.

### Tone & Language
**Fun and casual.** Use friendly, encouraging language throughout the app. Examples:
- "You're all set!" (after signing up)
- "Great job!" (when viewing hours)
- "See you at the lot!" (after check-in)
- "No shifts today—enjoy your day!" (empty state)

Avoid corporate or formal language. This is a volunteer app for families, not a business tool.

### Design Priorities
1. **Viewing shifts and checking in/out** — Must be fastest and most frictionless
2. **Finding and signing up for shifts** — Important but secondary
3. **Viewing hours and leaderboards** — Accessible but not primary focus

---

## Design System

### Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| **Primary (Accent)** | `#FF6D00` | CalTrans Orange. Buttons, active states, key actions |
| **Primary Dark** | `#E65100` | Pressed states, emphasis |
| **Primary Light** | `#FFF3E0` | Backgrounds, highlights |
| **Neutral 900** | `#1A1A1A` | Primary text |
| **Neutral 700** | `#4A4A4A` | Secondary text |
| **Neutral 500** | `#8A8A8A` | Tertiary text, placeholders |
| **Neutral 200** | `#E5E5E5` | Borders, dividers |
| **Neutral 100** | `#F5F5F5` | Card backgrounds |
| **Neutral 0** | `#FFFFFF` | Page backgrounds |
| **Success** | `#2E7D32` | Checked in, confirmed, fully staffed |
| **Warning** | `#F9A825` | Needs attention, understaffed |
| **Error** | `#C62828` | Critical, errors, cancellations |
| **Info** | `#1565C0` | Informational states |

### Typography

Use **San Francisco** (iOS system font) throughout.

| Style | Weight | Size | Line Height | Usage |
|-------|--------|------|-------------|-------|
| **Large Title** | Bold | 34pt | 41pt | Screen titles |
| **Title 1** | Bold | 28pt | 34pt | Section headers |
| **Title 2** | Bold | 22pt | 28pt | Card titles |
| **Title 3** | Semibold | 20pt | 25pt | Subsection headers |
| **Headline** | Semibold | 17pt | 22pt | List item titles |
| **Body** | Regular | 17pt | 22pt | Primary content |
| **Callout** | Regular | 16pt | 21pt | Supporting content |
| **Subhead** | Regular | 15pt | 20pt | Secondary labels |
| **Footnote** | Regular | 13pt | 18pt | Tertiary information |
| **Caption 1** | Regular | 12pt | 16pt | Timestamps, metadata |
| **Caption 2** | Regular | 11pt | 13pt | Badges, small labels |

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `spacing-xs` | 4pt | Tight spacing, inline elements |
| `spacing-sm` | 8pt | Related elements |
| `spacing-md` | 16pt | Standard padding, gaps |
| `spacing-lg` | 24pt | Section spacing |
| `spacing-xl` | 32pt | Major sections |
| `spacing-2xl` | 48pt | Screen-level spacing |

### Corner Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 8pt | Buttons, small elements |
| `radius-md` | 12pt | Cards, inputs |
| `radius-lg` | 16pt | Modal sheets, large cards |
| `radius-full` | 9999pt | Pills, avatars |

### Shadows

| Token | Value | Usage |
|-------|-------|-------|
| `shadow-sm` | 0 1pt 2pt rgba(0,0,0,0.05) | Subtle lift |
| `shadow-md` | 0 2pt 8pt rgba(0,0,0,0.10) | Cards |
| `shadow-lg` | 0 4pt 16pt rgba(0,0,0,0.15) | Floating elements |

### Iconography

Use **SF Symbols** throughout for consistency with iOS conventions.

| Context | Icon | SF Symbol Name |
|---------|------|----------------|
| Home tab | House | `house.fill` |
| Schedule tab | Calendar | `calendar` |
| Check-In tab | Checkmark | `checkmark.circle.fill` |
| Profile tab | Person | `person.fill` |
| Committee tab | Shield | `shield.fill` |
| Scouts indicator | Tent | `tent.fill` |
| Parents indicator | Person 2 | `person.2.fill` |
| Fully staffed | Checkmark circle | `checkmark.circle.fill` |
| Needs volunteers | Exclamation | `exclamationmark.circle.fill` |
| Critical | X circle | `xmark.circle.fill` |
| Signed up | Star | `star.fill` |
| Add/Plus | Plus | `plus.circle.fill` |
| Settings | Gear | `gearshape` |
| Sign out | Arrow right | `rectangle.portrait.and.arrow.right` |

---

## App Structure & Navigation

### Tab Bar Configuration

The app uses a standard iOS tab bar with 5 tabs. The Committee tab is only visible to users with `Admin` or `Committee` roles.

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                      [Screen Content]                       │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  🏠 Home  │  📅 Schedule  │  ✓ Check-In  │  👤 Profile  │  🛡️ Committee  │
└─────────────────────────────────────────────────────────────┘
```

| Tab | Label | Icon (Inactive) | Icon (Active) | Visible To |
|-----|-------|-----------------|---------------|------------|
| 1 | Home | `house` | `house.fill` | All users |
| 2 | Schedule | `calendar` | `calendar.fill` | All users |
| 3 | Check-In | `checkmark.circle` | `checkmark.circle.fill` | All users |
| 4 | Profile | `person` | `person.fill` | All users |
| 5 | Committee | `shield` | `shield.fill` | Admin, Committee only |

### Navigation Patterns

- **Tab-to-tab:** Standard iOS tab bar switching
- **Drill-down:** Push navigation within tabs (e.g., Schedule → Week → Shift Detail)
- **Modals:** Used for actions like signing up, adding walk-ins, editing profiles
- **Sheets:** Half-sheet presentations for quick actions and confirmations

---

## Tab 1: Home

### Purpose
The Home tab serves as the dashboard—a quick-glance overview of what's happening today and what's coming up for the user's family.

### Screen: Home Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│ Home                                           [Season Badge]│
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  TODAY - Saturday, Dec 7                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Your Family's Shifts                                │   │
│  │ ┌─────────────────────────────────────────────────┐ │   │
│  │ │ 🏕️ Alex Smith         10:00 AM - 2:00 PM       │ │   │
│  │ │    Morning Shift      ✓ Checked in 9:58 AM     │ │   │
│  │ └─────────────────────────────────────────────────┘ │   │
│  │ ┌─────────────────────────────────────────────────┐ │   │
│  │ │ 👤 Sarah Smith        2:00 PM - 6:00 PM        │ │   │
│  │ │    Afternoon Shift    Not checked in           │ │   │
│  │ └─────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Who's at the Lot Today                              │   │
│  │                                                     │   │
│  │ 10:00 AM - 2:00 PM (Morning Shift)                 │   │
│  │   Parents: John D., Sarah S.                        │   │
│  │   Scouts: Alex S., Emma W., Jake T.                │   │
│  │                                                     │   │
│  │ 2:00 PM - 6:00 PM (Afternoon Shift)                │   │
│  │   Parents: Sarah S., Mike R.                        │   │
│  │   Scouts: Ben R., Lily M.                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  COMING UP                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Next 3 Days                                         │   │
│  │                                                     │   │
│  │ Tomorrow - Sunday, Dec 8                            │   │
│  │ ┌─────────────────────────────────────────────────┐ │   │
│  │ │ 👤 Sarah Smith        10:00 AM - 2:00 PM       │ │   │
│  │ └─────────────────────────────────────────────────┘ │   │
│  │                                                     │   │
│  │ Monday, Dec 9                                       │   │
│  │   No shifts scheduled                               │   │
│  │                                                     │   │
│  │ Tuesday, Dec 10                                     │   │
│  │ ┌─────────────────────────────────────────────────┐ │   │
│  │ │ 🏕️ Alex Smith         4:00 PM - 7:00 PM       │ │   │
│  │ └─────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Section: Today

#### Your Family's Shifts Card
Displays all shifts for family members occurring today.

**Card Contents:**
- Section header: "Your Family's Shifts"
- List of shift items, each showing:
  - **Icon:** Tent (🏕️) for scouts, Person (👤) for parents
  - **Name:** Family member's first and last name
  - **Time:** Shift start and end time (e.g., "10:00 AM - 2:00 PM")
  - **Shift Label:** The shift name (e.g., "Morning Shift")
  - **Status:** Check-in status
    - "Not checked in" (Neutral 500 text)
    - "✓ Checked in [time]" (Success green text)
    - "✓ Checked out [time]" (Success green text)

**Empty State:**
- "No shifts today—enjoy your day! 🌲"

**Tap Action:**
- Tapping a shift item navigates to the Shift Detail screen

#### Who's at the Lot Today Card
Shows all people working at the lot today, grouped by shift.

**Card Contents:**
- Section header: "Who's at the Lot Today"
- For each shift today:
  - **Time range and label** (e.g., "10:00 AM - 2:00 PM (Morning Shift)")
  - **Parents list:** Comma-separated first names with last initial
  - **Scouts list:** Comma-separated first names with last initial

**Empty State:**
- "The lot is closed today"

### Section: Coming Up

#### Next 3 Days Card
Shows upcoming shifts for all family members over the next 3 days.

**Card Contents:**
- Section header: "Next 3 Days"
- For each day:
  - **Day header:** "Tomorrow - Sunday, Dec 8" or "Monday, Dec 9"
  - **Shift items** (same format as Today's Family Shifts)
  - **No shifts message:** "No shifts scheduled" (if applicable)

**Empty State (no shifts in next 3 days):**
- "No upcoming shifts. [Find a shift →]" (link to Schedule tab)

---

## Tab 2: Schedule

### Purpose
The Schedule tab allows users to browse available shifts by week and sign up for shifts.

### Screen: Season Overview

```
┌─────────────────────────────────────────────────────────────┐
│ Schedule                                                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  2024 Tree Lot Season                                       │
│  Nov 25 - Dec 23                                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Week 1                                              │   │
│  │ Nov 25 - Dec 1                                      │   │
│  │                                                     │   │
│  │ 📅 12 shifts    ⚠️ 3 need coverage    ⭐ 2 signed up │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Week 2                                              │   │
│  │ Dec 2 - Dec 8                                       │   │
│  │                                                     │   │
│  │ 📅 14 shifts    ✓ Fully staffed      ⭐ 1 signed up │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Week 3                                              │   │
│  │ Dec 9 - Dec 15                                      │   │
│  │                                                     │   │
│  │ 📅 14 shifts    🔴 5 need coverage    ⭐ 0 signed up │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Week 4                                              │   │
│  │ Dec 16 - Dec 22                                     │   │
│  │                                                     │   │
│  │ 📅 12 shifts    ⚠️ 2 need coverage    ⭐ 0 signed up │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Week Card

**Card Contents:**
- **Week Label:** "Week 1", "Week 2", etc.
- **Date Range:** "Nov 25 - Dec 1"
- **Stats Row:**
  - 📅 Total shifts count
  - Staffing status:
    - ✓ "Fully staffed" (Success green) — all shifts have required volunteers
    - ⚠️ "[N] need coverage" (Warning yellow) — some shifts understaffed
    - 🔴 "[N] need coverage" (Error red) — 3+ shifts critically understaffed
  - ⭐ "[N] signed up" — family's commitments this week

**Tap Action:**
- Navigates to Week Detail screen

### Screen: Week Detail

```
┌─────────────────────────────────────────────────────────────┐
│ ← Schedule          Week 1                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  MONDAY, NOV 25                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 4:00 PM - 7:00 PM                                   │   │
│  │ Weekday Evening                                     │   │
│  │                                                     │   │
│  │ 🏕️ 1/2 scouts    👥 1/2 parents    ⚠️ Needs help   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  TUESDAY, NOV 26                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 4:00 PM - 7:00 PM                                   │   │
│  │ Weekday Evening                                     │   │
│  │                                                     │   │
│  │ 🏕️ 2/2 scouts    👥 2/2 parents    ✓ Fully staffed │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  FRIDAY, NOV 29                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 10:00 AM - 2:00 PM                          ⭐     │   │
│  │ Black Friday Morning                                │   │
│  │                                                     │   │
│  │ 🏕️ 3/4 scouts    👥 2/2 parents    ⚠️ Needs scouts │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 2:00 PM - 6:00 PM                                   │   │
│  │ Black Friday Afternoon                              │   │
│  │                                                     │   │
│  │ 🏕️ 4/4 scouts    👥 2/2 parents    ✓ Fully staffed │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  SATURDAY, NOV 30                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 9:00 AM - 1:00 PM                                   │   │
│  │ Saturday Morning                                    │   │
│  │                                                     │   │
│  │ 🏕️ 2/3 scouts    👥 1/2 parents    🔴 Critical     │   │
│  └─────────────────────────────────────────────────────┘   │
│  ...                                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Day Group
- **Day Header:** "MONDAY, NOV 25" (uppercase, Subhead style, Neutral 500)
- Contains all shift cards for that day

#### Shift Card (in Week Detail)

**Card Contents:**
- **Time:** "4:00 PM - 7:00 PM"
- **Label:** Shift name (e.g., "Weekday Evening")
- **Signed-up indicator:** ⭐ star icon in top-right if user/family is signed up
- **Staffing row:**
  - 🏕️ "[current]/[required] scouts"
  - 👥 "[current]/[required] parents"
  - Status badge:
    - ✓ "Fully staffed" (Success)
    - ⚠️ "Needs help" / "Needs scouts" / "Needs parents" (Warning)
    - 🔴 "Critical" (Error) — below 50% staffed

**Tap Action:**
- Navigates to Shift Detail screen

### Screen: Shift Detail

```
┌─────────────────────────────────────────────────────────────┐
│ ← Week 1            Shift Details                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Saturday Morning                                           │
│  Saturday, Nov 30                                           │
│  9:00 AM - 1:00 PM                                         │
│  📍 Tree Lot - Main Entrance                               │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ STAFFING                                            │   │
│  │                                                     │   │
│  │ Scouts          2 of 3           ⚠️ Need 1 more    │   │
│  │ ├─ Alex Smith                                       │   │
│  │ └─ Emma Wilson                                      │   │
│  │                                                     │   │
│  │ Parents         1 of 2           ⚠️ Need 1 more    │   │
│  │ └─ John Davis                                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ NOTES                                               │   │
│  │ Busy morning expected - opening weekend!            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │              [  Sign Up  ]                          │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Header Section
- **Shift Label:** Large title (Title 1)
- **Date:** Full date (e.g., "Saturday, Nov 30")
- **Time:** Start and end time
- **Location:** With 📍 icon (if applicable)

#### Staffing Card
- **Section header:** "STAFFING"
- **Scouts section:**
  - Header row: "Scouts" + "[current] of [required]" + status badge
  - List of signed-up scout names (indented with tree lines)
- **Parents section:**
  - Header row: "Parents" + "[current] of [required]" + status badge
  - List of signed-up parent names

**Status badges:**
- ✓ "Full" (Success)
- ⚠️ "Need [N] more" (Warning)

#### Notes Card (conditional)
- Only shown if shift has notes
- **Section header:** "NOTES"
- **Content:** Note text

#### Action Section

**Sign Up Button:**
- Primary button style (Orange background, white text)
- Full width within card
- Label: "Sign Up"

**When tapped:** Opens Sign-Up Sheet (see below)

**Cancel Button (shown if user is signed up):**
- Destructive secondary button (Red text, no background)
- Label: "Cancel My Signup"
- Only shown if user has permission to cancel

### Sheet: Sign Up for Shift

Presented as a half-sheet modal.

```
┌─────────────────────────────────────────────────────────────┐
│                    Sign Up for Shift                    [X] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Saturday Morning                                           │
│  Nov 30, 9:00 AM - 1:00 PM                                 │
│                                                             │
│  Who's signing up?                                          │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ○  Sarah Smith (me)                    Parent       │   │
│  │ ●  Alex Smith                          Scout        │   │
│  │ ○  Emma Smith                          Scout        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Add a note (optional)                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Will arrive 10 mins early to help set up           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Confirm Sign Up  ]                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Contents:**
- **Header:** "Sign Up for Shift" with close (X) button
- **Shift summary:** Label, date, time
- **Person selector:** Radio button list of eligible family members
  - Shows "(me)" suffix for current user
  - Shows role badge (Parent/Scout)
  - Disabled/grayed out if already signed up or claimed scout
- **Note field:** Optional text input
- **Confirm button:** Primary button

**Success Feedback:**
- Haptic feedback (success)
- Toast: "You're all set! See you at the lot! 🌲"
- Sheet dismisses
- Shift Detail updates to show new signup

---

## Tab 3: Check-In

### Purpose
The Check-In tab is the attendance management hub. It shows the current or next shift's roster and allows authorized users to check people in and out.

### Screen: Check-In (Active Shift)

```
┌─────────────────────────────────────────────────────────────┐
│ Check-In                                                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ CURRENT SHIFT                                       │   │
│  │ Saturday Morning                                    │   │
│  │ 9:00 AM - 1:00 PM                                  │   │
│  │ In progress • Started 47 min ago                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  PARENTS                                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ John Davis                                          │   │
│  │ ✓ Checked in 8:58 AM                               │   │
│  │                                    [ Check Out ]    │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Sarah Smith                                         │   │
│  │ Not checked in                                      │   │
│  │                                    [ Check In  ]    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  SCOUTS                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Alex Smith                                          │   │
│  │ ✓ Checked in 9:02 AM                               │   │
│  │                                    [ Check Out ]    │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Emma Wilson                                         │   │
│  │ ✓ Checked in 9:15 AM                               │   │
│  │                                    [ Check Out ]    │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Jake Thompson                                       │   │
│  │ Not checked in                                      │   │
│  │                                    [ Check In  ]    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│                      [ + Add Walk-In ]                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Shift Info Card
- **Label:** "CURRENT SHIFT" (Caption, Neutral 500)
- **Shift name:** Title 2
- **Time range:** Body
- **Status:** "In progress • Started [X] min ago" (Caption, Success green)

#### Roster Section

**Section Headers:**
- "PARENTS" / "SCOUTS" (Subhead, Neutral 500, uppercase)

**Person Row:**
- **Name:** Headline style
- **Status line:**
  - "Not checked in" (Neutral 500)
  - "✓ Checked in [time]" (Success green)
  - "✓ Checked out [time]" (Neutral 500, indicates completed)
- **Action button:** Right-aligned
  - "Check In" button (Primary style) — when not checked in
  - "Check Out" button (Secondary style) — when checked in

**Button Behavior:**
- **Check In:** Single tap checks in. Tapping again within 30 seconds shows "Undo" to reverse mistaken tap.
- **Check Out:** Only enabled after check-in. Shows confirmation: "Check out [Name]?"

**Permissions:**
| User Type | Can Check In/Out |
|-----------|------------------|
| Parent on shift | Anyone on the shift |
| Scout on shift (with phone) | Only themselves |
| Anyone not on shift | Read-only view |

#### Add Walk-In Button
- Secondary button at bottom of roster
- Only visible to parents currently checked in to the shift
- Opens Add Walk-In Sheet

### Screen: Check-In (No Active Shift)

```
┌─────────────────────────────────────────────────────────────┐
│ Check-In                                                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ NEXT SHIFT                                          │   │
│  │ Saturday Afternoon                                  │   │
│  │ 2:00 PM - 6:00 PM                                  │   │
│  │ Starts in 2 hours 15 min                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  PARENTS                                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Mike Roberts                                        │   │
│  │ Sarah Smith                                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  SCOUTS                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Ben Roberts                                         │   │
│  │ Lily Martinez                                       │   │
│  │ ⚠️ 1 spot open                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         [  Sign Up for This Shift  ]                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Differences from Active Shift view:**
- Label shows "NEXT SHIFT" instead of "CURRENT SHIFT"
- Status shows "Starts in [time]" instead of "In progress"
- Roster is read-only (no check-in/out buttons)
- Shows "[N] spot(s) open" if understaffed
- Shows "Sign Up for This Shift" button if spots available (navigates to Sign-Up Sheet)

### Screen: Check-In (No Shifts Today)

```
┌─────────────────────────────────────────────────────────────┐
│ Check-In                                                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                                                             │
│                          📅                                 │
│                                                             │
│              No shifts scheduled today                      │
│                                                             │
│          The lot opens again tomorrow at 10 AM              │
│                                                             │
│                                                             │
│              [  View Schedule  ]                            │
│                                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Empty State Contents:**
- Calendar icon (large, centered)
- Primary message: "No shifts scheduled today"
- Secondary message: "The lot opens again [day] at [time]" or "The season hasn't started yet"
- Action button: "View Schedule" (navigates to Schedule tab)

### Sheet: Add Walk-In

```
┌─────────────────────────────────────────────────────────────┐
│                      Add Walk-In                        [X] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Someone covering for a no-show?                            │
│  Add them to this shift.                                    │
│                                                             │
│  Search by name                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🔍  Type a name...                                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Ben Roberts                            Scout        │   │
│  │ Brandon Taylor                         Scout        │   │
│  │ Beth Williams                          Parent       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Add & Check In  ]                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Contents:**
- **Header:** "Add Walk-In" with close button
- **Helper text:** "Someone covering for a no-show? Add them to this shift."
- **Search field:** Filters active users by name
- **Results list:** Shows matching users with role badge
- **Action button:** "Add & Check In" (disabled until selection made)

**Behavior:**
- Search filters as user types
- Single selection from list
- "Add & Check In" adds the walk-in assignment and checks them in immediately
- Success toast: "[Name] added and checked in!"

---

## Tab 4: Profile

### Purpose
The Profile tab shows the user's personal information, hours worked, leaderboard standings, family management, and settings.

### Screen: Profile

```
┌─────────────────────────────────────────────────────────────┐
│ Profile                                                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│           ┌───────┐                                         │
│           │  👤   │                                         │
│           └───────┘                                         │
│           Sarah Smith                                       │
│           Parent • Smith Family                             │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ MY HOURS                                            │   │
│  │                                                     │   │
│  │      12.5 hours                                     │   │
│  │      this season                                    │   │
│  │                                                     │   │
│  │ This Week        3.5 hrs                           │   │
│  │ Last Week        5.0 hrs                           │   │
│  │ Earlier          4.0 hrs                           │   │
│  │                                                     │   │
│  │ Upcoming         6.0 hrs scheduled                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ LEADERBOARDS                                    >   │   │
│  │                                                     │   │
│  │ 👤 Individual         #4 of 32                     │   │
│  │ 👨‍👩‍👧‍👦 Family              #2 of 15                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 👨‍👩‍👧 Family Management                             >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ⚙️ Settings                                       >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│                    [ Sign Out ]                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Profile Header
- **Avatar:** Large circle with person icon (or initials, or photo if available)
- **Name:** Title 1, centered
- **Subtitle:** Role + Family name (e.g., "Parent • Smith Family")

#### My Hours Card
- **Section header:** "MY HOURS"
- **Hero stat:** Large number (Title 1) + "this season" subtitle
- **Breakdown rows:**
  - "This Week" + hours
  - "Last Week" + hours
  - "Earlier" + hours
  - "Upcoming" + "[hours] scheduled" (future shifts)

#### Leaderboards Card
- **Section header:** "LEADERBOARDS" with chevron (>)
- **Individual ranking:** Person icon + "Individual" + "#[rank] of [total]"
- **Family ranking:** Family icon + "Family" + "#[rank] of [total]"
- **Tap action:** Navigate to Leaderboards screen

#### Family Management Row
- Row with family icon, "Family Management" label, chevron
- **Tap action:** Navigate to Family Management screen

#### Settings Row
- Row with gear icon, "Settings" label, chevron
- **Tap action:** Navigate to Settings screen

#### Sign Out Button
- Destructive secondary button (Red text)
- Confirmation alert: "Sign out of Tree Lot?"

### Screen: Leaderboards

```
┌─────────────────────────────────────────────────────────────┐
│ ← Profile           Leaderboards                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┬──────────────────┐                   │
│  │   Individual     │     Family       │                   │
│  └──────────────────┴──────────────────┘                   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🥇  Alex Smith                           18.5 hrs   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 🥈  Emma Wilson                          16.0 hrs   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 🥉  Jake Thompson                        14.5 hrs   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 4.  Sarah Smith (you)                    12.5 hrs   │   │  ← Highlighted
│  ├─────────────────────────────────────────────────────┤   │
│  │ 5.  John Davis                           11.0 hrs   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 6.  Mike Roberts                         10.5 hrs   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ ...                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Segmented Control:**
- "Individual" / "Family" toggle

**Leaderboard List:**
- Top 3 show medal emoji (🥇🥈🥉)
- Others show numeric rank
- Name (with "(you)" or "(your family)" suffix if applicable)
- Hours right-aligned
- Current user/family row highlighted with accent background

### Screen: Family Management

```
┌─────────────────────────────────────────────────────────────┐
│ ← Profile           Family                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Smith Family                                               │
│  Family Unit ID: smith-2024                                 │
│                                                             │
│  PARENTS                                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Sarah Smith (you)                          Primary  │   │
│  │ sarah@email.com                                 >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ David Smith                                Spouse   │   │
│  │ david@email.com                                 >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  SCOUTS                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Alex Smith                              ✓ Claimed   │   │
│  │ Has own account                                 >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Emma Smith                              Unclaimed   │   │
│  │ Claim code: TREE-EMMA-2024                      >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│                  [ + Add Family Member ]                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Family Header:**
- Family name (Title 2)
- Family Unit ID (Caption, Neutral 500)

**Parents Section:**
- Each row shows name, email, role badge (Primary/Spouse)
- "(you)" suffix for current user
- Chevron for drill-down

**Scouts Section:**
- Each row shows name, claim status badge
- Claimed scouts: "Has own account"
- Unclaimed scouts: Show claim code
- Chevron for drill-down to edit/regenerate codes

**Add Button:**
- "+ Add Family Member" secondary button
- Opens sheet to add spouse or scout

### Screen: Settings

```
┌─────────────────────────────────────────────────────────────┐
│ ← Profile           Settings                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  NOTIFICATIONS                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Push Notifications                         [====]   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Shift Reminders                            [====]   │   │
│  │ 1 hour before shift                                 │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ New Shifts Available                       [====]   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Announcements                              [====]   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ABOUT                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ App Version                               1.0.0     │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Help & Support                                  >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Privacy Policy                                  >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Notifications Section:**
- Toggle switches for each notification type
- Subtitle explanations where helpful

**About Section:**
- Static info rows (version, build)
- Links to support and legal

---

## Tab 5: Committee

### Purpose
The Committee tab provides administrative tools for creating shifts, managing the schedule, viewing reports, and sending announcements. Only visible to Admin and Committee role users.

### Screen: Committee Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│ Committee                                                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ⚠️ STAFFING ALERTS                                  │   │
│  │                                                     │   │
│  │ 3 shifts critically understaffed this week         │   │
│  │                                                     │   │
│  │                          [ View Alerts ]            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  SCHEDULE MANAGEMENT                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 📋 Shift Templates                              >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 📅 Generate Schedule                            >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ ➕ Create Individual Shift                      >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  REPORTS                                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 📊 Season Statistics                            >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 🎖️ Scout Bucks Report                           >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 📋 Attendance History                           >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  COMMUNICATION                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 📢 Send Announcement                            >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ADMIN (Admin role only)                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 👥 Manage Families                              >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 🎟️ Generate Invite Codes                        >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Staffing Alerts Card (conditional)
- Only shown if there are understaffed shifts
- Warning style card (Warning background tint)
- Message: "[N] shifts critically understaffed this week"
- "View Alerts" button navigates to detailed alerts view

#### Schedule Management Section
- **Shift Templates:** Manage reusable shift templates
- **Generate Schedule:** Bulk create shifts from templates
- **Create Individual Shift:** Add a one-off shift

#### Reports Section
- **Season Statistics:** Overview of season metrics
- **Scout Bucks Report:** End-of-season hours report for credits
- **Attendance History:** View past attendance records

#### Communication Section
- **Send Announcement:** Compose and send push notifications

#### Admin Section (Admin role only)
- **Manage Families:** View/edit/deactivate families
- **Generate Invite Codes:** Create codes for new families

### Screen: Staffing Alerts

```
┌─────────────────────────────────────────────────────────────┐
│ ← Committee         Staffing Alerts                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  THIS WEEK                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🔴 Saturday Morning                                 │   │
│  │    Dec 7, 9:00 AM - 1:00 PM                        │   │
│  │    Need: 2 scouts, 1 parent                        │   │
│  │                                     [ View Shift ]  │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 🔴 Saturday Afternoon                               │   │
│  │    Dec 7, 1:00 PM - 5:00 PM                        │   │
│  │    Need: 1 scout                                   │   │
│  │                                     [ View Shift ]  │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ ⚠️ Sunday Morning                                   │   │
│  │    Dec 8, 10:00 AM - 2:00 PM                       │   │
│  │    Need: 1 parent                                  │   │
│  │                                     [ View Shift ]  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  NEXT WEEK                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ⚠️ Friday Evening                                   │   │
│  │    Dec 13, 5:00 PM - 8:00 PM                       │   │
│  │    Need: 2 scouts                                  │   │
│  │                                     [ View Shift ]  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Alert Rows:**
- 🔴 Critical (< 50% staffed)
- ⚠️ Warning (< 100% staffed)
- Shift name, date/time, what's needed
- "View Shift" button navigates to Shift Detail

### Screen: Season Statistics

```
┌─────────────────────────────────────────────────────────────┐
│ ← Committee         Season Statistics                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  2024 Tree Lot Season                                       │
│  Nov 25 - Dec 23                                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         72              486            15           │   │
│  │       shifts           hours        families        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ PARTICIPATION                                       │   │
│  │                                                     │   │
│  │ Active Scouts                    28 / 32           │   │
│  │ Active Parents                   24 / 38           │   │
│  │ Avg Hours per Scout              8.2 hrs           │   │
│  │ Avg Hours per Family             32.4 hrs          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ SHIFT COVERAGE                                      │   │
│  │                                                     │   │
│  │ Fully Staffed                    58 / 72 (81%)     │   │
│  │ Understaffed                     14 / 72 (19%)     │   │
│  │ Average Fill Rate                94%               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Screen: Send Announcement

```
┌─────────────────────────────────────────────────────────────┐
│ ← Committee         Send Announcement                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Recipients                                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ● All Families                                      │   │
│  │ ○ Parents Only                                      │   │
│  │ ○ Scouts Only                                       │   │
│  │ ○ Specific Shift                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Title                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Schedule Change                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Message                                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Due to weather, Saturday morning shift is          │   │
│  │ cancelled. Please sign up for a different shift    │   │
│  │ this week. Thanks!                                  │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Send Announcement  ]                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Contents:**
- **Recipients:** Radio button selection for target audience
- **Title:** Text input for notification title
- **Message:** Multi-line text input for body
- **Send button:** Shows confirmation before sending

**Confirmation Alert:**
- Title: "Send Announcement?"
- Message: "This will send a push notification to [recipient count] people."
- Buttons: "Cancel" / "Send"

**Success Feedback:**
- Toast: "Announcement sent to [N] people"

### Screen: Shift Templates

```
┌─────────────────────────────────────────────────────────────┐
│ ← Committee         Shift Templates                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Templates are reusable shift patterns for quick            │
│  schedule generation.                                       │
│                                                             │
│  WEEKDAY TEMPLATES                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Weekday Evening                                     │   │
│  │ 4:00 PM - 7:00 PM                                  │   │
│  │ 🏕️ 2 scouts    👥 2 parents                        │   │
│  │                                                 >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  FRIDAY TEMPLATES                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Friday Afternoon                                    │   │
│  │ 3:00 PM - 6:00 PM                                  │   │
│  │ 🏕️ 3 scouts    👥 2 parents                        │   │
│  │                                                 >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Friday Evening                                      │   │
│  │ 6:00 PM - 9:00 PM                                  │   │
│  │ 🏕️ 3 scouts    👥 2 parents                        │   │
│  │                                                 >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  WEEKEND TEMPLATES                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Weekend Morning                                     │   │
│  │ 9:00 AM - 1:00 PM                                  │   │
│  │ 🏕️ 3 scouts    👥 2 parents                        │   │
│  │                                                 >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Weekend Afternoon                                   │   │
│  │ 1:00 PM - 5:00 PM                                  │   │
│  │ 🏕️ 3 scouts    👥 2 parents                        │   │
│  │                                                 >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Weekend Evening                                     │   │
│  │ 5:00 PM - 8:00 PM                                  │   │
│  │ 🏕️ 2 scouts    👥 2 parents                        │   │
│  │                                                 >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  SPECIAL EVENT TEMPLATES                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Black Friday Morning                                │   │
│  │ 9:00 AM - 1:00 PM                                  │   │
│  │ 🏕️ 4 scouts    👥 3 parents                        │   │
│  │                                                 >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│                   [ + Create Template ]                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Template Row Contents:**
- **Template name:** Headline style
- **Time range:** Subhead, Neutral 500
- **Staffing requirements:** Scout and parent counts with icons
- **Chevron:** For drill-down to edit

**Tap Action:**
- Navigates to Edit Template screen

**Create Button:**
- Opens Create/Edit Template sheet

### Sheet: Create/Edit Template

```
┌─────────────────────────────────────────────────────────────┐
│                    Create Template                      [X] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Template Name                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Weekend Morning                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Category                                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Weekday | Friday | Weekend | Special Event         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Time                                                       │
│  ┌────────────────────┐    ┌────────────────────┐          │
│  │ Start    9:00 AM   │    │ End      1:00 PM   │          │
│  └────────────────────┘    └────────────────────┘          │
│                                                             │
│  Staffing Requirements                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🏕️ Scouts Required              [ - ]  3  [ + ]    │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 👥 Parents Required             [ - ]  2  [ + ]    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Default Notes (optional)                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Busy time - arrive 10 min early if possible        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Save Template  ]                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│                   [ Delete Template ]                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Form Fields:**
- **Template Name:** Text input
- **Category:** Segmented control (determines grouping on list)
- **Start/End Time:** Time pickers
- **Scouts Required:** Stepper (1-10)
- **Parents Required:** Stepper (1-10)
- **Default Notes:** Optional text area

**Delete Button (edit mode only):**
- Destructive style, shown only when editing existing template
- Confirmation: "Delete this template? This won't affect shifts already created from it."

### Screen: Generate Schedule

```
┌─────────────────────────────────────────────────────────────┐
│ ← Committee         Generate Schedule                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Create shifts in bulk using your templates.                │
│                                                             │
│  SEASON DATES                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Start Date                                          │   │
│  │ Friday, Nov 29, 2024                            >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ End Date                                            │   │
│  │ Monday, Dec 23, 2024                            >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  TEMPLATES TO USE                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Weekday                                             │   │
│  │ ☑️ Weekday Evening (Mon-Thu)                        │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Friday                                              │   │
│  │ ☑️ Friday Afternoon                                 │   │
│  │ ☑️ Friday Evening                                   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Weekend                                             │   │
│  │ ☑️ Weekend Morning (Sat-Sun)                        │   │
│  │ ☑️ Weekend Afternoon (Sat-Sun)                      │   │
│  │ ☐ Weekend Evening (Sat only)                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ PREVIEW                                             │   │
│  │                                                     │   │
│  │ This will create 72 shifts:                        │   │
│  │ • 16 weekday shifts                                │   │
│  │ • 8 Friday shifts                                  │   │
│  │ • 48 weekend shifts                                │   │
│  │                                                     │   │
│  │ Shifts will be created as DRAFT                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Generate Draft  ]                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Form Sections:**

**Season Dates:**
- Start/End date pickers
- Tapping opens iOS date picker

**Templates Selection:**
- Grouped by category
- Checkboxes to include/exclude templates
- Day applicability shown in parentheses

**Preview Card:**
- Auto-calculated based on selections
- Shows total shifts and breakdown by category
- Reminds user shifts will be drafts

**Generate Button:**
- Creates shifts in draft status
- Progress indicator during generation
- On completion, navigates to Review Draft screen

### Screen: Review Draft Schedule

```
┌─────────────────────────────────────────────────────────────┐
│ ← Generate          Review Draft                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 📋 72 shifts created as draft                       │   │
│  │                                                     │   │
│  │ Review and adjust before publishing.               │   │
│  │ Families won't see drafts until published.         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  WEEK 1 • Nov 25 - Dec 1                           12 shifts│
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Fri Nov 29                                          │   │
│  │   3:00 PM  Friday Afternoon         🏕️3 👥2    [✎] │   │
│  │   6:00 PM  Friday Evening           🏕️3 👥2    [✎] │   │
│  │ Sat Nov 30                                          │   │
│  │   9:00 AM  Weekend Morning          🏕️3 👥2    [✎] │   │
│  │   1:00 PM  Weekend Afternoon        🏕️3 👥2    [✎] │   │
│  │ Sun Dec 1                                           │   │
│  │   9:00 AM  Weekend Morning          🏕️3 👥2    [✎] │   │
│  │   1:00 PM  Weekend Afternoon        🏕️3 👥2    [✎] │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  WEEK 2 • Dec 2 - Dec 8                            14 shifts│
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Mon Dec 2                                           │   │
│  │   4:00 PM  Weekday Evening          🏕️2 👥2    [✎] │   │
│  │ Tue Dec 3                                           │   │
│  │   4:00 PM  Weekday Evening          🏕️2 👥2    [✎] │   │
│  │ ...                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ... (more weeks)                                           │
│                                                             │
│  ┌───────────────────┐  ┌───────────────────┐              │
│  │  Discard Draft    │  │  Publish All  ✓   │              │
│  └───────────────────┘  └───────────────────┘              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Header Card:**
- Summary of draft
- Reminder that families can't see drafts

**Week Sections:**
- Collapsible week groups
- Each shift row shows: time, name, staffing, edit button
- Edit button (✎) opens Edit Shift sheet

**Action Buttons:**
- **Discard Draft:** Destructive secondary, deletes all draft shifts
- **Publish All:** Primary button, makes all shifts visible to families

**Edit Shift Interaction:**
- Tapping ✎ opens sheet to adjust individual shift details
- Can delete individual shifts from draft
- Can adjust staffing numbers, times, notes

### Screen: Create Individual Shift

```
┌─────────────────────────────────────────────────────────────┐
│ ← Committee         Create Shift                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Create a one-off shift outside the regular schedule.       │
│                                                             │
│  START FROM TEMPLATE (optional)                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ None - Start from scratch                       >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  SHIFT DETAILS                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Shift Name                                          │   │
│  │ Special Setup Day                                   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Date                                                │   │
│  │ Thursday, Nov 28, 2024                          >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Start Time                                          │   │
│  │ 10:00 AM                                        >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ End Time                                            │   │
│  │ 4:00 PM                                         >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  STAFFING REQUIREMENTS                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🏕️ Scouts Required              [ - ]  4  [ + ]    │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 👥 Parents Required             [ - ]  3  [ + ]    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ADDITIONAL                                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Location                                            │   │
│  │ Tree Lot - Main Entrance                            │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Notes                                               │   │
│  │ Help set up lot before opening day. Wear work      │   │
│  │ clothes!                                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  STATUS                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ○ Draft (only committee can see)                    │   │
│  │ ● Published (visible to all families)               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Create Shift  ]                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Form Sections:**

**Start from Template:**
- Optional dropdown to pre-fill form from existing template
- "None - Start from scratch" default

**Shift Details:**
- Name, date, start time, end time
- Date/time fields open iOS pickers

**Staffing Requirements:**
- Steppers for scouts and parents (1-10)

**Additional:**
- Location (optional text)
- Notes (optional text area)

**Status:**
- Radio buttons: Draft or Published
- Published is default for individual shifts

**Validation:**
- End time must be after start time
- Name required
- At least 1 scout or parent required

### Screen: Scout Bucks Report

```
┌─────────────────────────────────────────────────────────────┐
│ ← Committee         Scout Bucks Report                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  End-of-season report for calculating Scout Bucks           │
│  credits based on volunteer hours.                          │
│                                                             │
│  2024 SEASON SUMMARY                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         486.5              32               15      │   │
│  │       total hours        scouts          families   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  SCOUT HOURS                                                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Name              Scout Hrs   Family Hrs    Total   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Alex Smith           18.5        28.0       46.5   │   │
│  │ Emma Wilson          16.0        24.5       40.5   │   │
│  │ Jake Thompson        14.5        32.0       46.5   │   │
│  │ Ben Roberts          12.0        18.5       30.5   │   │
│  │ Lily Martinez        11.5        22.0       33.5   │   │
│  │ Sam Chen             10.0        26.0       36.0   │   │
│  │ ...                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Export includes:                                    │   │
│  │ • Scout name and family unit                        │   │
│  │ • Individual scout hours                            │   │
│  │ • Family total hours                                │   │
│  │ • Combined total for Scout Bucks calculation        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Export as CSV  ]                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Contents:**

**Summary Card:**
- Total hours, scout count, family count

**Scout Hours Table:**
- Scrollable list sorted by total hours (descending)
- Columns: Name, Scout Hours, Family Hours, Total
- Scout Hours = that scout's individual hours
- Family Hours = total hours from all family members
- Total = combined for Scout Bucks calculation

**Export Info:**
- Explains what's included in export

**Export Button:**
- Generates CSV file
- Uses iOS share sheet to save/send file

### Screen: Attendance History

```
┌─────────────────────────────────────────────────────────────┐
│ ← Committee         Attendance History                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┬──────────────────┐                   │
│  │    By Shift      │    By Person     │                   │
│  └──────────────────┴──────────────────┘                   │
│                                                             │
│  Filter: All shifts                                     ▼   │
│                                                             │
│  TODAY • Dec 7                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Saturday Morning • 9:00 AM - 1:00 PM                │   │
│  │                                                     │   │
│  │ ✓ John Davis         9:02 AM → 1:05 PM    4.05 hrs │   │
│  │ ✓ Alex Smith         9:15 AM → 1:00 PM    3.75 hrs │   │
│  │ ✓ Emma Wilson        9:08 AM → 12:45 PM   3.62 hrs │   │
│  │ ✗ Sarah Smith        No show                        │   │
│  │ ✓ Jake Thompson      9:30 AM → 1:10 PM    3.67 hrs │   │
│  │   (walk-in)                                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  YESTERDAY • Dec 6                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Friday Evening • 5:00 PM - 8:00 PM                  │   │
│  │                                                     │   │
│  │ ✓ Mike Roberts       4:55 PM → 8:02 PM    3.12 hrs │   │
│  │ ✓ Ben Roberts        5:10 PM → 8:00 PM    2.83 hrs │   │
│  │ ✓ Beth Williams      5:00 PM → 7:45 PM    2.75 hrs │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Friday Afternoon • 3:00 PM - 6:00 PM                │   │
│  │                                                     │   │
│  │ ✓ Sarah Smith        3:05 PM → 6:00 PM    2.92 hrs │   │
│  │ ✓ Alex Smith         3:00 PM → 5:45 PM    2.75 hrs │   │
│  │ ...                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Segmented Control:**
- "By Shift" (default) / "By Person" toggle

**Filter Dropdown:**
- All shifts, This week, Last week, Custom date range

**By Shift View (shown above):**
- Grouped by day
- Each shift card shows:
  - Shift name and time
  - List of all assigned people with attendance status
  - ✓ = Checked in/out with times and hours
  - ✗ = No show
  - "(walk-in)" label for walk-in volunteers

**By Person View:**

```
┌─────────────────────────────────────────────────────────────┐
│  Search by name                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🔍  Type a name...                                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Alex Smith                              18.5 hrs    │   │
│  │ Scout • Smith Family                           >    │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Sarah Smith                             12.5 hrs    │   │
│  │ Parent • Smith Family                          >    │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Emma Wilson                             16.0 hrs    │   │
│  │ Scout • Wilson Family                          >    │   │
│  │ ...                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

- Search field to filter
- List shows each person with total hours
- Tap to see individual attendance history

### Screen: Manage Families (Admin Only)

```
┌─────────────────────────────────────────────────────────────┐
│ ← Committee         Manage Families                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Search families                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🔍  Type a name...                                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌──────────────────┬──────────────────┐                   │
│  │     Active       │    Inactive      │                   │
│  └──────────────────┴──────────────────┘                   │
│                                                             │
│  15 ACTIVE FAMILIES                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Smith Family                                        │   │
│  │ Sarah Smith, David Smith                            │   │
│  │ 2 scouts: Alex, Emma                            >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Wilson Family                                       │   │
│  │ Jennifer Wilson                                     │   │
│  │ 1 scout: Emma                                   >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Roberts Family                                      │   │
│  │ Mike Roberts, Susan Roberts                         │   │
│  │ 2 scouts: Ben, Lily                             >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Thompson Family                                     │   │
│  │ James Thompson                                      │   │
│  │ 1 scout: Jake                                   >   │   │
│  │ ...                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Search and Filter:**
- Search by family or member name
- Segmented control: Active / Inactive

**Family Row:**
- Family name (Headline)
- Parent names
- Scout count and names
- Chevron for detail

**Tap Action:**
- Navigate to Family Detail (Admin View)

### Screen: Family Detail (Admin View)

```
┌─────────────────────────────────────────────────────────────┐
│ ← Families          Smith Family                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ STATUS                                              │   │
│  │                                                     │   │
│  │ ● Active    ○ Inactive                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  PARENTS                                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Sarah Smith                                Primary  │   │
│  │ sarah@email.com                                     │   │
│  │ Role: Parent                                    >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ David Smith                                 Spouse  │   │
│  │ david@email.com                                     │   │
│  │ Role: Parent                                    >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  SCOUTS                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Alex Smith                              ✓ Claimed   │   │
│  │ Role: Scout                                     >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Emma Smith                              Unclaimed   │   │
│  │ Claim Code: TREE-EMMA-2024                      >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  HOURS THIS SEASON                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Family Total                              46.5 hrs  │   │
│  │ Sarah Smith                               12.5 hrs  │   │
│  │ David Smith                                6.0 hrs  │   │
│  │ Alex Smith                                18.5 hrs  │   │
│  │ Emma Smith                                 9.5 hrs  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ADMIN ACTIONS                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🔄 Reset Claim Codes                            >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 👤 Change Member Roles                          >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ ⚠️ Deactivate Family                            >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Status Section:**
- Radio toggle to activate/deactivate family
- Deactivating prevents signups and hides from active lists

**Members Sections:**
- Same format as Profile → Family Management
- Admins can tap into any member to edit

**Hours Section:**
- Summary of family hours

**Admin Actions:**
- Reset Claim Codes: Regenerate codes for unclaimed scouts
- Change Member Roles: Promote to Committee, etc.
- Deactivate Family: With confirmation

### Screen: Generate Invite Codes (Admin Only)

```
┌─────────────────────────────────────────────────────────────┐
│ ← Committee         Invite Codes                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Invite codes allow new families to join the app.           │
│  Each code can only be used once.                           │
│                                                             │
│  GENERATE NEW CODES                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ How many codes?            [ - ]   5   [ + ]        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Generate Codes  ]                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  UNUSED CODES (3)                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ TREE-2024-ABCD                                      │   │
│  │ Created Dec 1, 2024                          [📋]   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ TREE-2024-EFGH                                      │   │
│  │ Created Dec 1, 2024                          [📋]   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ TREE-2024-IJKL                                      │   │
│  │ Created Dec 3, 2024                          [📋]   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  RECENTLY USED (5)                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ TREE-2024-MNOP                          ✓ Used      │   │
│  │ Smith Family • Dec 5, 2024                          │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ TREE-2024-QRST                          ✓ Used      │   │
│  │ Wilson Family • Dec 4, 2024                         │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ TREE-2024-UVWX                          ✓ Used      │   │
│  │ Roberts Family • Dec 3, 2024                        │   │
│  │ ...                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│                                                             │
│                  [ Share All Unused Codes ]                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Generate Section:**
- Stepper to select quantity (1-20)
- Generate button creates new codes

**Unused Codes Section:**
- List of codes not yet redeemed
- Copy button (📋) copies code to clipboard
- Swipe to delete/deactivate code

**Recently Used Section:**
- Shows which family used each code
- Date used
- Historical reference only

**Share Button:**
- Opens iOS share sheet with all unused codes as text
- For easy distribution via email/message

### Sheet: Share Invite Codes

```
┌─────────────────────────────────────────────────────────────┐
│                    Share Invite Codes                   [X] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Troop 900 Tree Lot App                              │   │
│  │                                                     │   │
│  │ Use one of these codes to join:                     │   │
│  │                                                     │   │
│  │ • TREE-2024-ABCD                                    │   │
│  │ • TREE-2024-EFGH                                    │   │
│  │ • TREE-2024-IJKL                                    │   │
│  │                                                     │   │
│  │ Download the app from the App Store and enter       │   │
│  │ your code when prompted.                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Copy to Clipboard  ]                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Share via...  ]                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Common Components

### Cards

All cards use:
- Background: Neutral 100 (#F5F5F5) or Neutral 0 (#FFFFFF)
- Corner radius: `radius-md` (12pt)
- Shadow: `shadow-md`
- Padding: `spacing-md` (16pt)

### Buttons

**Primary Button:**
- Background: Primary (#FF6D00)
- Text: White, Semibold
- Corner radius: `radius-sm` (8pt)
- Height: 50pt
- Full width or auto based on context

**Secondary Button:**
- Background: Transparent
- Border: 1pt Primary
- Text: Primary, Semibold
- Same dimensions as primary

**Destructive Button:**
- Background: Transparent
- Text: Error (#C62828), Semibold
- No border

### Status Badges

Small pill-shaped indicators:

| Status | Background | Text Color | Icon |
|--------|------------|------------|------|
| Fully Staffed | Success Light | Success | ✓ |
| Needs Help | Warning Light | Warning | ⚠️ |
| Critical | Error Light | Error | 🔴 |
| Signed Up | Primary Light | Primary | ⭐ |

### Empty States

All empty states include:
- Large icon (SF Symbol, 48pt, Neutral 300)
- Primary message (Title 3, Neutral 700)
- Secondary message (Body, Neutral 500)
- Optional action button

### Loading States

- Use native iOS activity indicators
- Skeleton loading for cards (animated gray placeholders)
- Pull-to-refresh on scrollable lists

### Toast Notifications

- Appear at top of screen, below safe area
- Auto-dismiss after 3 seconds
- Swipeable to dismiss
- Include icon + message
- Success: Green tint
- Error: Red tint
- Info: Blue tint

---

## Role-Based Variations

### Scout (Unclaimed)
- Cannot log in—profile managed by parents
- No UI variations (they don't see the app)

### Scout (Claimed)
- **Home:** Same as parent, but only sees their own shifts
- **Schedule:** Can sign up for themselves only
- **Check-In:** Can only check in/out themselves when working a shift
- **Profile:** Personal hours only, no family management
- **Committee:** Tab not visible

### Parent
- Full access to Home, Schedule, Check-In, Profile
- Can manage unclaimed scouts
- Cannot manage claimed scouts' signups
- Committee tab not visible

### Committee
- Same as Parent, plus:
- Committee tab visible (minus Admin section)

### Admin
- Same as Committee, plus:
- Admin section visible in Committee tab
- Can manage all families and generate invite codes

---

## Multi-Household Support

The app supports scouts belonging to multiple households to accommodate divorced parents, joint custody, and blended families. This section details how the UI handles these scenarios.

### Key Principles

1. **Scouts can belong to multiple households** (e.g., Mom's household AND Dad's household)
2. **Each parent manages their own household** — they can sign up scouts in their household
3. **All assignments are visible across households** — if Mom signs up a scout, Dad sees it too
4. **Cancellation is restricted to the assigning household** — parents can only cancel assignments their household created
5. **Scouts with phones can manage their own assignments** — regardless of which household signed them up

### Profile Header Variations

**Standard Parent:**
```
┌─────────────────────────────────────────────────────────────┐
│           ┌───────┐                                         │
│           │  👤   │                                         │
│           └───────┘                                         │
│           Sarah Johnson                                     │
│           Parent • Johnson Household                        │
└─────────────────────────────────────────────────────────────┘
```

**Scout in Single Household:**
```
┌─────────────────────────────────────────────────────────────┐
│           ┌───────┐                                         │
│           │  🏕️   │                                         │
│           └───────┘                                         │
│           Alex Smith                                        │
│           Scout • Smith Family                              │
└─────────────────────────────────────────────────────────────┘
```

**Scout in Multiple Households:**
```
┌─────────────────────────────────────────────────────────────┐
│           ┌───────┐                                         │
│           │  🏕️   │                                         │
│           └───────┘                                         │
│           Alex Smith                                        │
│           Scout • Smith Family                              │
│           Also in: Johnson Household                        │
└─────────────────────────────────────────────────────────────┘
```
- Shows primary family unit (for leaderboard purposes)
- "Also in:" line lists other households (for clarity)

### Family Management - Multi-Household Indicators

```
┌─────────────────────────────────────────────────────────────┐
│ ← Profile           Family                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Johnson Household                                          │
│  You manage this household                                  │
│                                                             │
│  PARENTS                                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Sarah Johnson (you)                        Primary  │   │
│  │ sarah@email.com                                 >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  SCOUTS                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Alex Smith                              ✓ Claimed   │   │
│  │ Has own account                                     │   │
│  │ 🏠 Also in: Smith Household                     >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ Emma Johnson                            Unclaimed   │   │
│  │ Claim code: TREE-EMMA-2024                      >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│                  [ + Add Family Member ]                    │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  LINK A SCOUT FROM ANOTHER HOUSEHOLD                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Have a scout who lives in two households?           │   │
│  │ Enter their household link code to add them here.   │   │
│  │                                                     │   │
│  │                 [ Enter Link Code ]                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Key Elements:**
- **Household name** shown prominently (not "Family")
- **"Also in:" indicator** on scouts who belong to other households
- **"Link a Scout" section** for adding a scout from another household via link code

### Scout Detail - Multi-Household View

When tapping on a scout who belongs to multiple households:

```
┌─────────────────────────────────────────────────────────────┐
│ ← Family            Alex Smith                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│           ┌───────┐                                         │
│           │  🏕️   │                                         │
│           └───────┘                                         │
│           Alex Smith                                        │
│           Scout • Claimed ✓                                 │
│                                                             │
│  HOUSEHOLDS                                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🏠 Johnson Household (yours)                        │   │
│  │    You can sign Alex up for shifts                  │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 🏠 Smith Household                                  │   │
│  │    Alex's other household                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ℹ️  When you sign Alex up for a shift, it will be   │   │
│  │    visible to both households. This helps prevent   │   │
│  │    scheduling conflicts.                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  HOURS THIS SEASON                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Total Hours                               18.5 hrs  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  HOUSEHOLD LINK CODE                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Share this code with Alex's other parent to let     │   │
│  │ them add Alex to their household.                   │   │
│  │                                                     │   │
│  │ LINK-ALEX-7X9K                            [📋 Copy] │   │
│  │                                                     │   │
│  │                 [ Regenerate Code ]                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Home Dashboard - Shift Attribution

When showing upcoming shifts, indicate which household made the assignment:

```
┌─────────────────────────────────────────────────────────────┐
│  COMING UP                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Next 3 Days                                         │   │
│  │                                                     │   │
│  │ Tomorrow - Sunday, Dec 8                            │   │
│  │ ┌─────────────────────────────────────────────────┐ │   │
│  │ │ 🏕️ Alex Smith         10:00 AM - 2:00 PM       │ │   │
│  │ │    Morning Shift                                │ │   │
│  │ │    Signed up by: Smith Household                │ │   │
│  │ └─────────────────────────────────────────────────┘ │   │
│  │ ┌─────────────────────────────────────────────────┐ │   │
│  │ │ 👤 Sarah Johnson       2:00 PM - 6:00 PM       │ │   │
│  │ │    Afternoon Shift                              │ │   │
│  │ └─────────────────────────────────────────────────┘ │   │
│  │                                                     │   │
│  │ Monday, Dec 9                                       │   │
│  │ ┌─────────────────────────────────────────────────┐ │   │
│  │ │ 🏕️ Alex Smith         4:00 PM - 7:00 PM       │ │   │
│  │ │    Weekday Evening                              │ │   │
│  │ │    Signed up by: You                            │ │   │
│  │ └─────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Attribution Line (for multi-household scouts only):**
- "Signed up by: You" — current user's household made assignment
- "Signed up by: [Household Name]" — other household made assignment
- Not shown for single-household members (unnecessary)

### Shift Detail - Conditional Cancel Button

The cancel button behavior depends on who made the assignment:

**Can Cancel (your household's assignment):**
```
┌─────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────┐   │
│  │ SIGNED UP                                           │   │
│  │                                                     │   │
│  │ 🏕️ Alex Smith                                      │   │
│  │    Signed up by your household                      │   │
│  │                                                     │   │
│  │                [ Cancel Signup ]                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Cannot Cancel (other household's assignment):**
```
┌─────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────┐   │
│  │ SIGNED UP                                           │   │
│  │                                                     │   │
│  │ 🏕️ Alex Smith                                      │   │
│  │    Signed up by: Smith Household                    │   │
│  │                                                     │   │
│  │    ℹ️  Contact Alex's other household to cancel     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

**Scout's Own View (claimed scout with phone):**
```
┌─────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────┐   │
│  │ YOU'RE SIGNED UP                                    │   │
│  │                                                     │   │
│  │ Saturday Morning                                    │   │
│  │ Dec 7, 9:00 AM - 1:00 PM                           │   │
│  │                                                     │   │
│  │                [ Cancel My Signup ]                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```
- Scouts can always cancel their own assignments regardless of which household signed them up

### Sign-Up Sheet - Multi-Household Awareness

When signing up a multi-household scout:

```
┌─────────────────────────────────────────────────────────────┐
│                    Sign Up for Shift                    [X] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Saturday Morning                                           │
│  Nov 30, 9:00 AM - 1:00 PM                                 │
│                                                             │
│  Who's signing up?                                          │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ○  Sarah Johnson (me)                  Parent       │   │
│  │ ●  Alex Smith                          Scout        │   │
│  │    🏠 Also in Smith Household                       │   │
│  │ ○  Emma Johnson                        Scout        │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ ℹ️  This signup will be visible to Alex's other     │   │
│  │    household too.                                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Confirm Sign Up  ]                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Info Banner:**
- Only shown when selecting a multi-household scout
- Reminds parent that other household will see this assignment

### Sheet: Enter Household Link Code

When a parent wants to add a scout from another household:

```
┌─────────────────────────────────────────────────────────────┐
│                    Link a Scout                         [X] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Enter the household link code for the scout you want       │
│  to add. You can get this code from the scout's other       │
│  parent.                                                    │
│                                                             │
│  Link Code                                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ LINK-ALEX-7X9K                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Link Scout  ]                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Success State:**
```
┌─────────────────────────────────────────────────────────────┐
│                    Scout Linked!                        [X] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                          ✓                                  │
│                                                             │
│  Alex Smith has been added to your household.               │
│                                                             │
│  You can now:                                               │
│  • See all of Alex's shift assignments                      │
│  • Sign Alex up for new shifts                              │
│  • Check Alex in/out when you're working                   │
│                                                             │
│  Alex's other household (Smith Household) will also         │
│  continue to see Alex's schedule.                           │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Done  ]                             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Admin View - Multi-Household Scout

In the Committee → Manage Families area, admins can see the full picture:

```
┌─────────────────────────────────────────────────────────────┐
│ ← Families          Alex Smith                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│           ┌───────┐                                         │
│           │  🏕️   │                                         │
│           └───────┘                                         │
│           Alex Smith                                        │
│           Scout • Claimed                                   │
│                                                             │
│  FAMILY UNIT (for leaderboards)                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Smith Family                                        │   │
│  │ Alex's hours count toward this family's total       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  HOUSEHOLDS (2)                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🏠 Smith Household                                  │   │
│  │    Managed by: John Smith, Lisa Smith               │   │
│  │    Primary household                            >   │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │ 🏠 Johnson Household                                │   │
│  │    Managed by: Sarah Johnson                        │   │
│  │    Linked via code                              >   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  UPCOMING ASSIGNMENTS                                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Dec 7, 9:00 AM    Morning Shift    by: Smith       │   │
│  │ Dec 9, 4:00 PM    Weekday Evening  by: Johnson     │   │
│  │ Dec 14, 1:00 PM   Afternoon Shift  by: Smith       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Summary: Multi-Household UI Elements

| Location | Element | Purpose |
|----------|---------|---------|
| Profile Header | "Also in: [Household]" line | Shows scout's other households |
| Family Management | "🏠 Also in:" badge on scout rows | Indicates multi-household scouts |
| Family Management | "Link a Scout" section | Add scout from another household |
| Scout Detail | Households list | Shows all households scout belongs to |
| Scout Detail | Household Link Code | Share code with other parent |
| Home Dashboard | "Signed up by:" attribution | Shows which household made assignment |
| Shift Detail | Conditional cancel button | Only show cancel for own household's assignments |
| Shift Detail | Info message | Explain why cancel isn't available |
| Sign-Up Sheet | "Also in" badge + info banner | Remind parent of cross-household visibility |
| Admin Views | Full household list | See complete picture of scout's households |

---

## State Handling

### Loading States

| Screen | Loading Behavior |
|--------|------------------|
| Home Dashboard | Skeleton cards for Today + Coming Up |
| Schedule (Season) | Skeleton week cards |
| Schedule (Week) | Skeleton shift cards |
| Check-In | Skeleton roster rows |
| Profile | Skeleton for hours card |
| Leaderboards | Skeleton rows |

### Error States

**Network Error:**
- Full-screen message with retry button
- Icon: wifi.slash
- Message: "Couldn't connect. Check your connection and try again."
- Button: "Try Again"

**Server Error:**
- Full-screen message
- Icon: exclamationmark.triangle
- Message: "Something went wrong. Please try again later."
- Button: "Try Again"

**Permission Denied:**
- Contextual inline message
- Example: "You don't have permission to cancel this signup."

### Offline Behavior

Firestore provides automatic offline persistence on iOS. When the network becomes unavailable, the app should gracefully degrade to a read-only experience using cached data.

#### What Users CAN Do Offline

| Tab | Offline Capability |
|-----|-------------------|
| **Home** | View cached Today section and Coming Up shifts |
| **Schedule** | Browse cached season, weeks, and shift details |
| **Check-In** | View cached shift roster (read-only) |
| **Profile** | View cached hours, leaderboards, family info |
| **Committee** | View cached reports, templates, family lists |

All data shown reflects the last successful sync with the server.

#### What Users CANNOT Do Offline

All write operations require network connectivity:

| Action | Offline Behavior |
|--------|------------------|
| Sign up for shift | Disabled |
| Cancel signup | Disabled |
| Check in / Check out | Disabled |
| Add walk-in | Disabled |
| Edit family members | Disabled |
| Create/edit shifts | Disabled |
| Send announcements | Disabled |
| Generate invite codes | Disabled |

#### Offline UI Indicators

**Persistent Offline Banner:**
```
┌─────────────────────────────────────────────────────────────┐
│ ⚠️  You're offline. Some features are unavailable.     [X] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                      [Screen Content]                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```
- Appears at top of screen (below navigation bar)
- Warning yellow background
- Dismissible, but reappears on tab switch as reminder
- Remains until network is restored

**Disabled Action Buttons:**
```
┌─────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────┐   │
│  │              [  Sign Up  ]  ← grayed out            │   │
│  │                                                     │   │
│  │         ⚠️ You're offline                          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```
- Primary action buttons appear grayed out (50% opacity)
- Tapping shows inline message: "You're offline"
- No toast or alert—keep it lightweight

**Check-In Tab (Offline):**
```
┌─────────────────────────────────────────────────────────────┐
│ Check-In                                                    │
├─────────────────────────────────────────────────────────────┤
│ ⚠️  You're offline. Check-in/out unavailable.          [X] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ CURRENT SHIFT                                       │   │
│  │ Saturday Morning                                    │   │
│  │ 9:00 AM - 1:00 PM                                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  PARENTS                                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ John Davis                                          │   │
│  │ ✓ Checked in 8:58 AM                               │   │
│  │                                                     │   │  ← No buttons
│  ├─────────────────────────────────────────────────────┤   │
│  │ Sarah Smith                                         │   │
│  │ Not checked in                                      │   │
│  │                                                     │   │  ← No buttons
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  SCOUTS                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Alex Smith                                          │   │
│  │ Status unknown while offline                        │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```
- Check In / Check Out buttons hidden entirely (not just disabled)
- Add Walk-In button hidden
- Roster shows cached status, with caveat that it may be stale
- If status is uncertain: "Status unknown while offline"

**Stale Data Indicator (Optional):**

For data that may have changed since last sync, show timestamp:
```
┌─────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────┐   │
│  │ STAFFING                     Last updated: 9:45 AM │   │
│  │                                                     │   │
│  │ Scouts          2 of 3           ⚠️ Need 1 more    │   │
│  │ ...                                                 │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```
- "Last updated: [time]" shown in section header
- Helps user understand data may be stale

#### Returning Online

When network connectivity is restored:

1. **Banner dismisses automatically** after successful sync
2. **Data refreshes silently** in the background
3. **Action buttons re-enable** immediately
4. **No toast needed** — seamless transition back to normal

If data changed while offline (e.g., someone else signed up for a shift):
- UI updates to reflect new data
- No special notification (user discovers naturally)

#### Network Error vs. Offline

Distinguish between being offline and encountering a server error:

**Offline (no network):**
- Device has no internet connection
- Show offline banner
- Allow browsing cached data

**Network Error (server unreachable):**
- Device has internet, but server request failed
- Show error state for affected content
- Retry button available
- Don't block entire app—only affected section

```
┌─────────────────────────────────────────────────────────────┐
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │              ⚠️ Couldn't load shifts               │   │
│  │                                                     │   │
│  │              [ Try Again ]                          │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Accessibility

### VoiceOver Support
- All interactive elements have accessibility labels
- Images have descriptive alt text
- Status indicators have text equivalents (not just color/icon)

### Dynamic Type
- All text respects iOS Dynamic Type settings
- Layouts adapt to larger text sizes
- Minimum touch targets: 44pt × 44pt

### Color Contrast
- All text meets WCAG AA contrast ratios
- Status information never relies solely on color

### Reduce Motion
- Respect iOS "Reduce Motion" setting
- Replace animations with fades when enabled

---

## Appendix: Screen Inventory

| Tab | Screen | Description |
|-----|--------|-------------|
| Home | Dashboard | Today + Coming Up overview |
| Schedule | Season Overview | List of weeks |
| Schedule | Week Detail | All shifts in selected week |
| Schedule | Shift Detail | Single shift info + roster |
| Schedule | Sign Up Sheet | Modal to sign up for shift |
| Check-In | Active Shift | Attendance management |
| Check-In | No Active Shift | Next shift preview |
| Check-In | No Shifts Today | Empty state |
| Check-In | Add Walk-In Sheet | Modal to add walk-in volunteer |
| Profile | Profile | User info + hours + navigation |
| Profile | Leaderboards | Individual + Family rankings |
| Profile | Family Management | Manage family members |
| Profile | Settings | Notifications + about |
| Committee | Dashboard | Admin tools hub |
| Committee | Staffing Alerts | Understaffed shifts list |
| Committee | Shift Templates | List and manage templates |
| Committee | Create/Edit Template | Modal form for template |
| Committee | Generate Schedule | Bulk shift creation wizard |
| Committee | Review Draft Schedule | Review generated shifts before publish |
| Committee | Create Individual Shift | Add one-off shift form |
| Committee | Season Statistics | Metrics overview |
| Committee | Scout Bucks Report | Hours export for credits |
| Committee | Attendance History | Historical attendance by shift/person |
| Committee | Send Announcement | Compose notification |
| Committee | Manage Families | Family list (Admin only) |
| Committee | Family Detail (Admin) | Admin view of single family |
| Committee | Generate Invite Codes | Create/manage invite codes (Admin only) |
| Committee | Share Invite Codes | Share sheet for codes |

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Dec 2024 | Initial UI design specification |

---

**End of Document**
