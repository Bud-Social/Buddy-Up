# BUDDYUP — COMPREHENSIVE PLATFORM BUILD PROMPT

**Version:** 1.0
**Output directory:** `C:\Users\Imani\Documents\Buddy-Up\`
**Minimum age:** 16 years and above (strictly enforced)
**Platform type:** Health & fitness social network + live training + marketplace + community

---

## 📌 PLATFORM VISION

BuddyUp is a **health and fitness social platform** that combines the accountability of a gym buddy, the reach of a social network, the commerce of a marketplace, and the energy of live streaming — all in one place. The platform exists to answer one question: *"Who's working out with me today?"* Whether a user wants a running partner, a certified nutritionist, a live HIIT class, a personalised meal plan, or just a community to keep them accountable — BuddyUp is the single destination.

The platform's signature social primitive is **"Buddying Up"** — a mutual follow system where User A can buddy a User B, and User B can "buddy back", creating a confirmed two-way relationship (like a friendship) that unlocks direct messaging and shared accountability features. This is distinct from one-directional following (like Instagram) and two-way buddying (like a friendship).

BuddyUp operates within a **virtual economy** where the currency is not money but **fitness artifacts** — purchasable digital tokens styled as dumbbells, barbells, burpees, squat icons, etc. — used to tip creators, join paid lives, buy subscriptions, and access premium content.

---

## 🎨 DESIGN SYSTEM

### Brand Identity
BuddyUp's visual language is **energetic, inclusive, and human** — it should feel like a pump-up playlist, not a sterile medical app. The aesthetic is bold, warm, and kinetic.

### Colour Palette

| Token | Hex | Role |
|---|---|---|
| `--buddy-green` | `#00C896` | Primary brand — energy, health, go |
| `--buddy-green-deep` | `#009E78` | Hover, pressed, strong accents |
| `--buddy-electric` | `#7B61FF` | Secondary — live indicator, premium, special |
| `--buddy-orange` | `#FF6B35` | Alerts, streaks, fire energy, artifact highlights |
| `--buddy-black` | `#0A0A0A` | App background (dark mode primary) |
| `--buddy-surface` | `#141414` | Cards, panels on dark background |
| `--buddy-surface-raised` | `#1E1E1E` | Elevated cards, modals |
| `--buddy-white` | `#F8F8F8` | Light mode base |
| `--buddy-text-primary` | `#FFFFFF` | Primary text on dark |
| `--buddy-text-secondary` | `#A0A0A0` | Secondary, timestamps, metadata |
| `--buddy-red` | `#FF4757` | Destructive actions, errors, live dot |
| `--buddy-gold` | `#FFD700` | Verified badge, premium, top-ranked |

**Default mode:** Dark (like most fitness/social apps). Light mode available as a toggle.

### Typography
- **Display / Hero:** `Syne ExtraBold` — punchy, athletic, modern; used for hero headlines and gym names
- **Headings (H2–H4):** `Plus Jakarta Sans SemiBold` — clean, energetic, versatile
- **Body & UI:** `Inter` — highly legible at small sizes
- **Numbers / Metrics / Stats:** `JetBrains Mono` — monospaced, gives data a performance-tracker feel
- **Artifact labels / Coins:** `Nunito Bold` — round, friendly, approachable for the virtual economy

### Signature Design Element
BuddyUp's visual signature is the **"Rep Ring"** — a circular progress arc in `--buddy-green` that appears on profile avatars, gym cards, and live session thumbnails. It represents activity streaks, session completion, and membership status. It is the platform's version of the Instagram ring around Stories — except filled with kinetic energy: animated on hover, pulsing green when the user is in a live session.

### UI/UX Principles
- Dark mode primary; all components must look perfect on `#0A0A0A`
- Mobile-first; primary use case is in a gym, on a phone, often with sweaty hands — touch targets minimum 48×48px
- Reduced motion supported (`prefers-reduced-motion`)
- WCAG AA minimum on all text
- Skeleton loaders everywhere; no raw spinners
- Haptic feedback on key actions (send, buddy up, join live)
- Bottom navigation bar on mobile (max 5 items)
- Optimistic UI: actions feel instant, reconcile in background

---

## 🗺️ PLATFORM ARCHITECTURE OVERVIEW

```
buddyup.app/
│
├── LANDING PAGE (public, unauthenticated)
│   ├── Hero, Value Props, Features, Live Demo, Pricing, Download CTA
│
├── AUTH FLOW
│   ├── /signup
│   ├── /login
│   ├── /verify-age          (DOB gate — under 16 blocked)
│   ├── /onboarding          (multi-step: goals, level, preferences)
│   └── /forgot-password
│
├── MAIN APP (authenticated)
│   ├── /feed                → Home feed (posts, stories, lives)
│   ├── /discover            → Explore users, trainers, gyms, trending
│   ├── /lives               → Live session browser + join
│   ├── /gyms                → Gym directory + my gyms
│   │   └── /gyms/:slug      → Individual gym page
│   ├── /trainers            → Trainer directory
│   │   └── /trainers/:slug  → Trainer profile
│   ├── /marketplace         → Meal plans, supplements, prescriptions, plans
│   ├── /sessions            → Scheduled 1:1 and group sessions
│   ├── /messages            → DMs (buddied users only)
│   ├── /wallet              → Artifact wallet + transactions
│   ├── /notifications       → Activity notifications
│   ├── /profile             → Own profile
│   │   └── /profile/edit    → Edit own profile
│   └── /settings            → Account, privacy, security, preferences
│
├── PROFILE PAGES (public/private)
│   └── /:username           → Any user or trainer's public profile
│
└── LEGAL PAGES (public)
    ├── /terms
    ├── /privacy
    ├── /community-guidelines
    └── /cookie-policy
```

---

## 🔐 SECTION 1: AUTHENTICATION & SECURITY

### 1.1 Registration Flow

**Step 1 — Email or Phone + Password**
- Input: email address OR phone number (+country code picker)
- Password: minimum 8 characters, at least one uppercase, one number, one special character
- Password strength meter (weak/fair/strong/very strong) rendered in real-time
- Terms of Service + Privacy Policy + Community Guidelines acceptance checkbox (required, not pre-checked)
- "I am 16 years of age or older" checkbox (required, not pre-checked)

**Step 2 — Age Verification (DOB Gate)**
- Date of birth picker: Day / Month / Year dropdowns
- If calculated age < 16: hard block — "BuddyUp is for users aged 16 and over. You cannot create an account at this time." — no bypass, no workaround, session terminated.
- DOB stored (hashed, not plaintext) for ongoing age compliance auditing
- If calculated age ≥ 16: proceed

**Step 3 — Email / Phone Verification**
- OTP (6-digit) sent to the provided email or SMS
- OTP valid for 10 minutes, single use
- 3 failed attempts → 30-minute lockout
- "Resend OTP" available after 60 seconds
- Verified status stored: `email_verified: true` or `phone_verified: true`

**Step 4 — Basic Profile Setup**
- Username: 3–30 characters, alphanumeric + underscore, case-insensitive uniqueness check (debounced availability check as they type)
- Display name: 1–50 characters (real name or alias — user's choice)
- Profile photo: upload (optional at this step; can skip)
- Role selection: "I am a..." → **Regular User** / **Trainer** / **Health Practitioner**
  - Trainer and Health Practitioner selections trigger a "verification required" notice; they proceed as a Regular User until verified

**Step 5 — Onboarding (Goal & Preference Setup)**
- Primary fitness goal: multi-select (Weight Loss / Muscle Gain / Endurance / Flexibility / General Wellness / Nutrition / Sports Performance / Rehabilitation / Mental Health)
- Current activity level: Sedentary / Lightly Active / Moderately Active / Very Active / Athlete
- Preferred workout types: Weights / Cardio / HIIT / Yoga / Pilates / CrossFit / Martial Arts / Swimming / Running / Cycling / Other
- Dietary preference: None / Vegan / Vegetarian / Keto / Paleo / Halal / Kosher / Gluten-Free / Other
- Preferred training time: Early Morning / Morning / Afternoon / Evening / Night / Flexible
- Discovery source: How did you hear about BuddyUp? (optional)
- This data feeds the recommendation engine for buddies, gyms, trainers, and content

### 1.2 Login

- Email/phone + password
- "Remember this device" toggle (extends session to 30 days)
- Login with Google (OAuth 2.0)
- Login with Apple (Sign In with Apple — required for iOS App Store compliance)
- 2FA: TOTP (Google Authenticator) or SMS OTP — optional for regular users, mandatory for verified trainers and health practitioners

### 1.3 Session Management

- JWT-based: short-lived access token (15 min) + long-lived refresh token (30 days for "remember me", 7 days otherwise)
- Refresh tokens stored in HttpOnly cookies (not localStorage)
- Access tokens in memory only (not localStorage — XSS resilience)
- Active sessions list in `/settings/security`: device, last active, location (approximate), "Sign out this device" per session
- "Sign out all devices" nuclear option

### 1.4 Security Architecture

- Rate limiting: login attempts (5/10 min per IP), OTP requests (3/hour per user), registration (10/hour per IP)
- CAPTCHA (hCaptcha — privacy-first over reCAPTCHA) triggered after 3 failed login attempts
- IP-based anomaly detection: login from new country → OTP challenge
- Brute force protection: exponential backoff on failed attempts
- All API endpoints: HTTPS only; HSTS enforced
- CSRF protection on all mutating endpoints
- SQL injection prevention: ORM only, no raw queries
- XSS prevention: all user content sanitised before storage and before render
- Content Security Policy headers
- Passwords: Argon2id hashing (not bcrypt)
- PII encryption at rest: email, phone, DOB stored encrypted (AES-256-GCM)
- GDPR / Kenya Data Protection Act compliance:
  - Right to access all personal data (export as JSON/ZIP)
  - Right to erasure (account deletion + anonymisation pipeline)
  - Data minimisation: only collect what is necessary
  - Explicit consent logging (what was consented to, timestamp, IP)

### 1.5 Account Verification System

#### Regular User Verification
- **Email verified badge** (blue tick) — basic; just completes email OTP
- **ID-verified** (silver tick) — user submits government ID via third-party KYC (Smile Identity for Africa / Onfido for international); age re-confirmed; name confirmed

#### Trainer Verification (green "Certified" badge)
Trainer submits:
- Government-issued ID
- Professional certification(s): e.g., NASM, ACE, ACSM, NSCA, local equivalents — scanned copies
- Active certification status confirmation (if registry available)
- Optional: gym affiliation proof
- Selfie holding ID (liveness check)
- Review queue: admin reviews within 5 business days
- Status: Pending → Approved (gets green badge) / Rejected (with reason)
- Re-application: allowed after 14 days with corrected documents

#### Health Practitioner Verification (gold "Practitioner" badge)
Practitioner submits:
- Government ID
- Relevant professional licence: medical doctor, dietitian, physiotherapist, psychologist, etc.
- Registration number with professional body (e.g., Kenya Medical Practitioners Board)
- Proof of active licence
- Review queue: admin + optional third-party verification API
- Higher scrutiny: 7 business days review
- Badge: gold caduceus icon

#### Gym / Group Verification
- Any gym with 50+ members can apply for verification
- Owners submit: gym name, location, description, proof of registration (if formal business)
- Verified gyms show a green "Verified Gym" badge

### 1.6 Anonymity Features

- Users can post to the feed as **Anonymous BuddyUp Member** — name hidden, avatar replaced with generic silhouette, no username visible
- Anonymous posts still go through content moderation (staff can see the real user)
- Anonymous messaging: NOT allowed — DMs always show real identity
- Anonymous lives: NOT allowed — live hosts always identified
- Anonymous reactions and comments: allowed (same mechanism as posts)
- User can toggle their online/active status: "Show when I'm active" in privacy settings

### 1.7 Account Deletion & Data Handling

- **Soft delete:** Account deactivated — profile hidden, content hidden, session terminated. Recoverable for 30 days.
- **Hard delete (after 30-day grace):** All PII permanently deleted. Posts anonymised ("Deleted Account"). All buddy connections severed. Wallet balance refunded per refund policy. Subscriptions cancelled.
- **Data export before deletion:** User can request a full data export (JSON) containing: profile, posts, messages (own side), sessions attended, transactions, saved content. Generated async (Celery), download link emailed.
- Admin-initiated deletion (ban): same pipeline but flagged as `deleted_by: moderation` in audit logs.

---

## 👤 SECTION 2: USER PROFILES

### 2.1 Profile Structure

Every BuddyUp account has a public-facing profile at `/:username`.

#### Profile Header
- **Rep Ring avatar:** circular avatar with the animated Rep Ring arc (activity streak indicator — green arc fills based on weekly activity streak)
- **Display name** + **Username** (@handle)
- **Verification badges:** ID-verified (blue), Certified Trainer (green), Health Practitioner (gold), Gym Verified (green gym icon)
- **Role tag:** "Regular User" / "Personal Trainer" / "Nutritionist" / "Physiotherapist" / etc.
- **Pronouns** (optional): displayed in smaller text below display name
- **Bio:** up to 200 characters
- **Specialties** (for trainers/practitioners): tag chips (e.g., "Strength Training", "Keto Nutrition", "Sports Rehab")
- **Location:** City, Country (optional, can be hidden)
- **Joined:** "Buddy since January 2025"
- **Active status:** "🟢 Active now" / "Active 2 hours ago" / hidden if privacy set to off

#### Profile Stats Row (horizontal pills)
- **Buddies:** total confirmed two-way buddy connections (tappable → buddy list)
- **Following:** users/trainers this person follows one-way
- **Followers:** users following this person one-way
- **Gyms:** number of gyms this person is a member of
- **Posts:** total posts
- **Streak:** 🔥 N-day streak (consecutive days with logged activity)

#### Action Buttons (when viewing another's profile)
- **Buddy Up / Buddied / Buddy Back** — primary CTA (state-aware)
- **Follow / Following** — secondary (one-directional)
- **Message** (only if both are buddied)
- **Book Session** (if they are a trainer; links to session booking)
- **Tip** (send an artifact as a tip)
- **⋮ More:** Block, Report, Share profile, Copy profile link

### 2.2 Profile Tabs

**Posts Tab**
- Grid of image/video posts (Instagram-style grid)
- Toggle: Grid / List view

**Lives Tab** (for trainers and gym owners)
- Past live sessions (replays if saved)
- Upcoming scheduled lives

**Gyms Tab**
- Gyms this user is a member of (visible to buddies; hidden otherwise by default)

**Achievements Tab**
- Streak badges (7-day, 30-day, 90-day, 1-year)
- Milestone badges (100 workouts, 1000 buddy connections, etc.)
- Verification badges
- Gym Founder badge (started a gym)

**Reviews Tab** (Trainers / Practitioners only)
- Client reviews with star ratings
- Average score
- "Leave a review" (only for users who booked a session with them)

### 2.3 Own Profile Page (`/profile`)

Same as public profile plus:
- **Edit Profile** button (full form: display name, username, bio, photo, cover image, pronouns, location, specialties, links)
- **Analytics** tab (visible to trainer/practitioner accounts):
  - Profile views this week
  - Post reach and impressions
  - Buddy growth chart
  - Session bookings count
  - Earnings summary (redirects to wallet)
- **Privacy settings** shortcut
- **Saved** tab: saved posts, saved meal plans, saved trainers

### 2.4 Profile Customisation

- **Profile photo:** circular, min 200×200px, Cloudinary upload, auto-crop
- **Cover image:** 16:9 banner (optional), shown on profile header background
- **Profile link:** one external link (website, linktree, etc.)
- **Workout schedule:** publicly shareable schedule (optional): e.g., "Mon/Wed/Fri — 6AM at KFC Arena"
- **Trainer services card:** (trainers only) mini-card showing rate, availability summary, top reviews — shown on profile for easy booking

---

## 🤝 SECTION 3: THE BUDDY SYSTEM

### 3.1 "Buddy Up" — The Core Social Primitive

BuddyUp has **three relationship tiers**:

| Relationship | How established | What it unlocks |
|---|---|---|
| **Follow** | One-directional; no approval needed | See their public posts in discover; nothing special |
| **Buddy Up** | User A sends a buddy request; User B accepts ("Buddies Back") | Two-way confirmed connection; DMs unlocked; appear in each other's buddy lists; accountability features |
| **Gym Membership** | Both are members of the same gym | Group chat access; gym feed; live access per gym rules |

### 3.2 Buddy Request Flow

1. User A taps "Buddy Up" on User B's profile
2. User B receives a notification: "[User A] wants to be your BuddyUp buddy! 💪"
3. User B can: **Buddy Back** (confirms) / **Decline** / **Ignore** (silent decline — no notification sent to User A)
4. If confirmed: both receive a notification "You and [User A/B] are now BuddyUp Buddies! 🎉"
5. A "New Buddy" system message appears in their DM thread as the conversation opener

### 3.3 Buddy Features (Confirmed Two-Way)

- **Direct Messaging:** Full messaging capability unlocked
- **Accountability Ping:** Send a "How's your workout?" ping (lightweight nudge; max 1 per day per buddy)
- **Shared Goals:** Optional shared goal card visible between buddies ("We're both targeting 10K steps this week")
- **Workout Together:** Join each other's live sessions for free (unless the gym live has a fee — that overrides)
- **Activity visibility:** See each other's workout logs if shared (opt-in per log entry)
- **Streak cheers:** When a buddy hits a streak milestone, receive an auto-generated "Cheer them on!" prompt

### 3.4 Following (One-Directional)

- Any user can follow any other user (unless profile is private)
- Private profiles: must request to follow; user approves/denies
- Following without buddying: see their public posts in your "Following" feed tab; can comment/react; no DMs

### 3.5 Blocking & Removing

- **Block:** removes all connections (buddy + follow both directions), hides profiles from each other, prevents messaging; blocked user does not receive notification
- **Remove buddy:** downgrade from two-way buddy to mutual follow only; DMs locked; no notification sent
- **Unfollow:** remove one-directional follow silently

---

## 📰 SECTION 4: FEED & CONTENT

### 4.1 Home Feed

Three tabs on the home screen:
1. **For You:** Algorithmic feed — posts from buddies, gyms, followed trainers, trending content, promoted posts
2. **Following:** Chronological feed — only from followed users and gyms
3. **Nearby:** Content from users and gyms in the same city/region (using location if permitted)

### 4.2 Post Types

**Text Post**
- Up to 500 characters
- Optional: tag users (@username), tag gyms (#gymname), tag food items, tag exercises
- Mood tags: "Post-workout high 🔥" / "Struggling today 😤" / "PB day 💪" / "Rest day 🛌" / etc.
- Anonymous toggle (see Section 1.6)

**Photo Post**
- Up to 10 photos per post
- Filters (built-in: Sweat, Pump, Clean Bulk, Cut, Beast Mode — all fitness-themed colour treatments)
- Caption: up to 2,200 characters
- Alt text field for accessibility
- Location tag (optional)
- Tag people (up to 10 users)

**Short Video (BuddyClip)**
- Duration: 15 seconds to 3 minutes
- Vertical (9:16) or square (1:1)
- In-app recording with countdown timer
- Auto-captions (speech-to-text, user can edit)
- Sound/music: royalty-free library + original audio
- Effects and speed control (0.5×, 1×, 1.5×, 2×)
- Trim, cut, merge clips within the app
- Filters and text overlays

**Long Video (BuddySession)**
- Duration: 3 minutes to 2 hours
- Landscape or vertical
- Chapters/timestamps (user-defined)
- Thumbnail upload (auto-extracted or custom)
- Subtitles: auto-generated (editable)
- Quality settings: 720p, 1080p, 4K (storage limits apply per plan)

**Workout Log Post**
- Quick-share a completed workout:
  - Workout name/type
  - Duration
  - Exercises with sets/reps or distance/time
  - Calories (optional, manual or wearable-synced)
  - How I felt: emoji scale (💀 to 🔥)
  - PR flags (auto-detected if tracking history)
  - Optional: gym tagged, trainer tagged, buddy tagged ("Worked out with @username")

**Meal Post**
- Photo of a meal + nutritional data
- Manual entry OR scan a barcode (barcode scanner in-app)
- Macro breakdown: Protein / Carbs / Fats / Calories shown as a visual bar
- Meal tags: Breakfast / Lunch / Dinner / Snack / Pre-workout / Post-workout
- Rate the meal: 1–5 stars ("Would eat again" rating)

**Progress Post (Transformation)**
- Side-by-side before/after images
- Date range label ("12 weeks apart")
- Stats comparison (optional): weight, body fat %, measurements
- Auto-applies a subtle "transformation" framing overlay

**Moment (Story-equivalent)**
- Disappears after 24 hours
- Photos or short videos (up to 60 seconds per frame, up to 30 frames)
- Text, stickers (fitness-themed: PR sticker, streak counter, gym location tag)
- Poll sticker: "Did you work out today? YES 💪 / NOT YET 😅"
- Question sticker
- Music sticker (from royalty-free library)
- Reactions (emoji reaction — sender sees who reacted)
- Reply goes to DM (if buddied) or to comment section
- Close Friends: share moments with a custom list of buddies only
- Archive moments to profile highlights ("My Journey", "PBs", "Meals", etc.)

### 4.3 Post Interactions

**Reactions (Artifact-style)**
Not a simple "like". BuddyUp has fitness-themed reactions:
- 💪 Pump (= Like)
- 🔥 Fire (= Love this)
- 🤝 Respect
- 😤 Grind
- 🏋️ Let's Go
- 😂 Haha
- 💀 Too hard

Long-press reaction button → show all 7 reaction options. Tap to select.
Reaction counts shown (total + individual counts on expand).

**Comments**
- Nested (1 level deep: top-level comments + replies to comments)
- @mention users in comments
- Emoji reactions on comments (subset: 💪 🔥 😂 ❤️)
- Pin a comment (post author can pin one comment to the top)
- Comment sorting: Top / Newest / Oldest

**Shares**
- **Repost to feed:** copies the post to own feed with attribution ("Reposted from @username") — original post card embedded
- **Share to moment:** shares as a moment frame (with optional caption)
- **Share to DM:** sends to a specific buddy's inbox
- **Copy link:** public link to the post
- **Share externally:** native share sheet (WhatsApp, Instagram, Twitter, etc.)

**Save**
- Save any post to own private collection
- Organise saved content into named collections ("Workout Ideas", "Meal Inspiration")

**Report**
- Report categories: Spam / Hate speech / Harassment / Misinformation / Dangerous health advice / Under-age content / Other
- Reported posts reviewed within 24 hours
- Three-strikes system: warned → content removed → account suspended

### 4.4 Repost / Reshare System

- **Simple repost:** adds the original post to your feed with original attribution. No added text. One tap.
- **Quote repost:** adds your comment on top, embeds the original post below. Shown distinctly in feed.
- **Unrepost:** remove from your feed at any time (does not delete the original)
- Repost count shown on original post
- Original post author notified of each repost

### 4.5 Algorithm & Feed Ranking

Signals used for "For You" feed ranking:
- Buddy activity (posts from confirmed buddies weighted 2×)
- Engagement prediction (past interactions with this creator type)
- Post freshness (decay function — older posts ranked lower)
- Content format preference (learned: does this user engage more with videos vs text?)
- Gym membership (posts from own gyms boosted)
- Trending in location
- Promoted posts (paid, clearly labelled "Sponsored")
- Diversity injection (prevent echo chamber: 20% content from outside primary interest clusters)

### 4.6 Content Moderation

Automated (pre-publish):
- NSFW image/video detection (Microsoft Azure Content Moderator or AWS Rekognition)
- Text: profanity filter (configurable: strict / standard / off — per user preference for own feed)
- Health misinformation flagging: keyword list + ML model triggers human review queue
- Dangerous content: any content suggesting extreme restriction, self-harm, or unregulated drugs → auto-removed + user warned
- Under-age content: face age estimation → flag for review if estimated age < 16 in content

Human review queue (moderation team):
- All flagged content reviewed within 4 hours
- Escalation path: auto-removed within 1 hour for severe categories
- Appeal process: user can appeal a removal within 14 days

---

## 📡 SECTION 5: LIVE SESSIONS ("BUDDY LIVES")

This is the platform's most distinctive feature. All lives are called **"Buddy Lives"** and follow a structured taxonomy.

### 5.1 Types of Buddy Lives

| Type | Who can start | Access model | Duration |
|---|---|---|---|
| **Open Sweat** | Any user | Free, public | Up to 4 hours |
| **Buddy Circle** | Any user | Free, buddies only | Up to 2 hours |
| **Gym Live** | Gym owners/trainers | Free or paid (artifact fee) | Up to 8 hours |
| **PT Session Live** | Certified trainers | Paid (artifact fee per viewer) | Up to 2 hours |
| **Random Drop** | Any user | Free, surprise join | Up to 45 min |
| **Practitioner Live** | Verified practitioners | Paid or free | Up to 3 hours |

### 5.2 Random Drop (Signature Feature)

The **Random Drop** is BuddyUp's most viral mechanic — a spontaneous live where users are **randomly matched** and dropped into the same session. Think of it as a fitness version of random video chat, but group-based.

**How it works (user-initiated):**
1. User taps "Drop In" on the Lives screen
2. Specifies: activity type (weights / cardio / yoga / run / etc.), duration (15 / 30 / 45 min), and whether they want free or paid viewers (if paid: select artifact amount from preset list)
3. BuddyUp's matching engine finds other users who also tapped "Drop In" with compatible activity types within the last 5 minutes
4. If 2–15 matches found: the group is "dropped" into a shared live room
5. If not enough matches: user gets a "Searching for workout buddies…" waiting screen with a 3-minute timeout; if no match → offered to go solo or start an Open Sweat instead
6. In the Random Drop room: no host; all participants are equal; anyone can leave at any time; session auto-ends if <2 participants remain for >2 minutes
7. At session end: users can send buddy requests to anyone they clicked with

**Random Drop Matching Algorithm:**
- Primary: activity type compatibility (exact match or "compatible" — e.g., HIIT and cardio compatible)
- Secondary: approximate timezone (within 4 hours)
- Tertiary: experience level (beginner grouped with beginner preferably; advanced with advanced)
- Does NOT match users who have blocked each other

### 5.3 Starting a Live

**Pre-live setup screen:**
- Title (required, max 80 chars): e.g., "Monday Morning HIIT 💪"
- Category: Strength / Cardio / HIIT / Yoga / Pilates / Stretching / Nutrition Talk / Q&A / Challenge / Other
- Access: Public / Buddies Only / Gym Members Only
- Fee: Free / Set artifact fee (minimum: 1 Dumbbell token ≈ platform minimum)
- Duration: estimated (shown to viewers; live ends automatically at +15 min grace)
- Thumbnail: auto-captured from camera preview or upload custom
- Co-hosts: invite up to 3 buddies to share the session as co-hosts
- Schedule: Start Now or Schedule for later (see Section 5.6)
- Gym tag: optionally associate with a gym (gym members notified)
- Equipment list: show viewers what they need (Dumbbells ✓ / Yoga mat ✓ / No equipment ✓)

### 5.4 In-Live Experience

**Host controls (left side panel, collapsible):**
- Camera toggle (front/rear flip)
- Microphone toggle
- Screen share (for showing a workout plan, nutrition chart, etc.)
- Music overlay (royalty-free workout music library — background music under voice)
- Timer overlay (countdown or stopwatch displayed on screen for all viewers)
- Rep counter overlay (host taps a button; a bold rep counter displayed for viewers)
- Guest co-host: invite a viewer to appear on camera (split screen)
- Exercise label overlay: "EXERCISE: Deadlift" banner shown to all viewers
- End session button

**Viewer experience:**
- Video feed (host primary + co-hosts in thumbnail row)
- Comment stream (live, right side or bottom — can be minimised)
- Reaction stream: viewers send real-time emoji reactions (float up the screen like TikTok)
- Artifact gifting: viewers can send fitness artifact gifts during the live (animations play on screen when sent — dumbbell rains down, etc.)
- "Do It With Me" button: viewer taps to indicate they're doing the exercise — host sees a counter ("42 doing it with you 💪")
- PiP mode: viewer can minimise live to a picture-in-picture while browsing the rest of the app
- Quality selection: Auto / Low / Medium / High
- Join fee payment: if the live has a fee, the artifact deduction happens at join (not at end)

**Live chat moderation:**
- Host can: slow mode (messages every X seconds), subscriber-only mode, clear chat, pin a comment, remove a viewer, ban a viewer from this live
- Auto-moderation: profanity filter (per host's setting), spam detection

**Viewer count:** shown live; updates in real-time

### 5.5 Live Replay

- Host can choose to save the live as a replay after ending
- Replays stored on Cloudinary with a 30-day default retention (trainer and gym plans may extend)
- Replay appears on host's profile under "Lives" tab
- Replay viewers pay the original fee (if the live was paid)
- Live comments: shown as timestamp-synced chat overlay in replay (can be toggled)

### 5.6 Gym Scheduled Lives

Gyms can publish a **weekly live schedule** — a structured programme like a real gym timetable:

```
IRON CORE GYM — THIS WEEK'S BUDDY LIVES SCHEDULE
┌─────────────────────────────────────────────────────────────────────────┐
│  Monday 6:00 AM    │ Morning HIIT         │ Coach Grace  │ Free (Members)│
│  Monday 12:00 PM   │ Lunchtime Pilates    │ Coach Sam    │ 2 💪 tokens  │
│  Tuesday 7:00 AM   │ Strength & Power     │ Coach Mike   │ Free (Members)│
│  Wednesday 6:30 AM │ Yoga Flow            │ Coach Aisha  │ Free (All)   │
│  Thursday 5:30 PM  │ HIIT + Core          │ Coach Grace  │ 2 💪 tokens  │
│  Friday 6:00 AM    │ Full Body Burn        │ Coach Mike   │ Free (Members)│
│  Saturday 8:00 AM  │ Weekend Warriors     │ All coaches  │ 3 💪 tokens  │
└─────────────────────────────────────────────────────────────────────────┘
```

- Gym members receive push notifications 15 minutes before each scheduled live
- They can RSVP in advance ("I'm joining this one") — RSVP count shown to the host
- Scheduled lives appear on the gym's page, in the global "Lives" browser, and in members' calendars
- Recurring lives: a live can be set as weekly recurring (same time every week)

### 5.7 Technical Architecture (Live Streaming)

- **WebRTC** for low-latency peer-to-peer (for Random Drop small groups, max 15 people)
- **HLS/RTMP via Agora.io or 100ms.live** for large-audience Gym Lives and PT Sessions (scales to thousands of viewers)
- **Mux** (or equivalent) for video encoding, storage, and adaptive bitrate streaming
- Fallback: if WebRTC fails → fall back to HLS automatically
- Recording: all saved lives processed via Mux's recording pipeline → stored on Cloudinary
- CDN: Cloudflare Stream for replay delivery

---

## 🏋️ SECTION 6: GYMS

### 6.1 What is a BuddyUp Gym?

A "Gym" is a **private or public community** within BuddyUp — a named group with its own feed, live schedule, member directory, roles, and optional subscription. Think of it as a cross between a Facebook Group, a Patreon community, and a real gym.

### 6.2 Creating a Gym

**Single or Multiple Ownership:**
- One person can create a gym (single owner)
- Multiple people can co-create a gym (multiple owners, up to 5 co-founders)
- Co-founders: each gets "Owner" role; all have equal admin privileges; majority vote required for gym deletion

**Gym creation form:**
- Gym name (unique on platform, 3–60 characters)
- Gym handle (@gymhandle — used in #gymhandle tags)
- Description (up to 500 characters)
- Category: Fitness / Nutrition / Yoga & Wellness / Strength & Powerlifting / Cardio & Running / Sport-specific / Mixed / Other
- Access type: **Public** (anyone can join) / **Private** (request to join; owner/mod approves) / **Secret** (invite-only; not discoverable in search)
- Subscription model:
  - **Free** for all
  - **Free (members only)** — must request/be approved but no payment
  - **Paid subscription** — set a monthly fee in artifacts (minimum: 5 Dumbbell tokens/month) and/or a one-time join fee
  - **Tiered** — Free tier + Premium tier (different access levels)
- Gym logo: upload (min 500×500px, circular)
- Cover image: 16:9 banner
- Rules: up to 10 custom community rules (shown to joining members; must be accepted)
- Location: city/country (optional; enables geo-discovery)
- Tags: up to 10 discoverability tags (e.g., "beginner-friendly", "keto", "CrossFit", "Nairobi")

### 6.3 Gym Roles & Permissions

| Role | Permissions |
|---|---|
| **Owner** | Full control: all below + delete gym, transfer ownership, manage co-owners |
| **Co-owner** | All below + manage Moderators + gym settings (except delete/transfer) |
| **Trainer** | Lead lives, post to gym feed, see member contact info, manage own sessions |
| **Moderator** | Remove posts, remove members, manage join requests, pin posts |
| **Member** | View gym feed, join lives (per plan), comment, post (per gym settings) |
| **Guest** | View public content only (if gym is public) |

Owners can create custom roles (up to 5 additional roles) with configurable permissions.

### 6.4 Gym Page Structure

**Gym Header:**
- Gym logo + cover image
- Gym name + @handle
- Verification badge (if verified)
- Member count + "Active today" count
- "Join" / "Joined" / "Requested" / "Subscribe" button (state-aware)
- Category tags + location

**Gym Tabs:**
- **Feed:** Posts from gym members (or owners only, depending on gym settings)
- **Lives:** Current live (if any) + weekly schedule + past replays
- **Members:** Searchable member directory (visible to members)
- **Trainers:** Gym's assigned trainers with booking shortcuts
- **About:** Description, rules, tags, creation date, owner profiles

**Gym Feed Settings (configurable by owner):**
- Who can post: Members / Trainers + Owners only / Owners only
- Post approval: instant / owner-approved before visible
- Allowed post types: all / no videos / no external links / etc.

### 6.5 Gym Wallet & Revenue

- **Gym wallet:** separate from personal wallet; receives all subscription payments, live fees, and artifact gifts addressed to the gym
- **Revenue split:** Platform takes 20% of gym revenue; 80% goes to gym wallet
- **Withdrawal:** Gym owners can withdraw gym wallet balance to personal wallet (then to external via cashout)
- **Expense tracking:** within gym wallet — see all incoming and outgoing transactions, subscription renewals, etc.
- **Co-owner split:** gym wallet distributions configurable by owners (e.g., 60/40 split between two co-owners; executed on withdrawal request)

### 6.6 Gym Member Management

- Join request queue (for private gyms): owner/mod sees list with user profile preview, approve/deny/ban
- Member search by username, join date, activity level
- Remove member (member notified; reason optional)
- Ban member (cannot rejoin; can be lifted by owner)
- Bulk actions: approve all requests / remove inactive members

---

## 💰 SECTION 7: THE ARTIFACT ECONOMY (VIRTUAL CURRENCY)

### 7.1 Fitness Artifacts — The Currency

BuddyUp does not transact in raw cash within the app. Users purchase **Fitness Artifacts** — themed digital tokens representing specific amounts of value, styled as exercise equipment icons.

| Artifact | Icon | Value (USD equivalent) | Use |
|---|---|---|---|
| 🏋️ Dumbbell | Dumbbell silhouette | $0.10 | Smallest unit; tips, reactions |
| 🏆 Barbell | Loaded barbell | $0.50 | Mid-tier; live entry, small tips |
| 🔥 Burpee | Stick figure mid-burpee | $1.00 | Standard; session fees |
| 🦵 Squat | Squat position figure | $2.50 | Premium; coach sessions |
| 🏃 Sprint | Runner silhouette | $5.00 | High-value; gym subscriptions |
| 💎 PR (Personal Record) | Trophy with diamond | $10.00 | Premium; exclusive access |
| 🌟 Champion | Star crown | $25.00 | Top-tier; sponsorships |

Exchange rate is fixed to USD equivalent but displayed in user's local currency equivalent at purchase. Rate may adjust quarterly.

### 7.2 Purchasing Artifacts

- **In-app purchase:** Stripe (card), M-Pesa (STK Push via Daraja API for Kenya), Flutterwave (Africa-wide cards), PayPal (international)
- **Bundle pricing:** higher bundles = better rate (e.g., 10 Barbells for $4.50 instead of $5.00)
- **Gift artifacts:** buy a bundle to send to another user (with an optional note)
- KYC required for purchases over $50/month (per AML regulations)
- Purchase history: full statement in wallet

### 7.3 Spending Artifacts

- **Tips:** send to any user on a post or during a live (minimum: 1 Dumbbell)
- **Live session entry:** deducted at the moment of joining
- **Gym subscription:** recurring monthly deduction from wallet
- **PT session booking:** full fee deducted at booking confirmation
- **Marketplace:** purchase meal plans, programmes, etc.
- **Boosting a post:** pay artifacts to promote a post in the "For You" feed (ad-lite system)

### 7.4 Earning Artifacts

Creators and trainers earn artifacts:
- Receiving tips from viewers/readers
- Live session fees (after 20% platform cut)
- Gym subscription revenue (after 20% platform cut)
- PT session fees (after 15% platform cut)
- Marketplace sales (after 15% platform cut)
- Referral bonuses (bring a new user who makes a purchase → receive artifact reward)
- Monthly creator bonus (top 100 most-tipped creators → bonus artifacts from platform)

### 7.5 Withdrawing Earnings

- Minimum withdrawal: equivalent of $10
- Withdrawal methods: M-Pesa, Bank Transfer, PayPal, Flutterwave
- Processing time: 3–5 business days
- Withdrawal fee: 2.5% (platform) + payment processor fee
- Tax documentation: platform generates annual earning statements for creators earning over the local tax threshold
- KYC required for all withdrawals: must be ID-verified at minimum (silver badge)

### 7.6 Wallet UI (`/wallet`)

- **Balance display:** artifact breakdown (how many of each type) + total equivalent value in local currency
- **Tabs:** Overview / Buy Artifacts / Send / Transaction History / Withdraw
- **Transaction history:** searchable, filterable by type (purchase / earning / tip sent / tip received / subscription payment / withdrawal)
- Each transaction: timestamp, amount, type, counterparty name, reference ID
- **Locked balance:** earnings in review (within 7-day clearance period before withdrawal is available)
- **Statement export:** downloadable CSV/PDF per date range

---

## 🧑‍💻 SECTION 8: TRAINER & PRACTITIONER FEATURES

### 8.1 Trainer Profile Extras

Beyond the standard profile (Section 2), verified trainers have:

- **Trainer Card:** pinned to top of profile — price range, availability indicator ("Available this week"), average rating, booking button
- **Specialties:** up to 10 from a predefined list (Strength / Hypertrophy / Weight Loss / Functional / Athletic Performance / Pre/Postnatal / Youth Training / Senior Fitness / Rehabilitation / Nutrition Coaching / Online Coaching)
- **Certifications list:** displayed with issuing body and year
- **Years of experience**
- **Languages they coach in**
- **Reviews:** aggregated star rating + individual client reviews (only from completed sessions)
- **Session types offered:** 1:1 Live / Group Live / Async (video programme) / Nutrition Consultation / In-Person (if they mark their location)

### 8.2 Session Booking (`/sessions`)

**For Clients:**
- Browse trainers → view trainer profile → "Book a Session"
- Session type selection (from what trainer offers)
- Date/time picker (shows trainer's real-time availability calendar)
- Duration: 30 min / 45 min / 60 min / 90 min
- Platform: BuddyUp Live (video) / In-Person (trainer's chosen location) / Async (submit questions, receive video response within 48 hours)
- Fee: displayed in artifact equivalent + local currency
- Payment: deducted from wallet on confirmation (held in escrow until session completes)
- Notes to trainer: special goals, injuries, preferences (up to 300 characters)
- Confirmation: added to both parties' calendars; reminder notifications at 24hr, 1hr, 15min before

**For Trainers:**
- **Availability calendar:** set available hours per day (drag-and-drop time blocks)
- **Buffer between sessions:** 0 / 5 / 10 / 15 / 30 min
- **Session caps:** max sessions per day
- **Pricing:** set per session type and duration (in artifact amounts)
- **Session history:** all past sessions with client ratings, notes, and payment records
- **Client management:** list of all clients who have ever booked; quick-rebook option
- **No-show policy:** configurable — charge partial fee, full fee, or waive for no-shows

**Escrow & Refund Policy:**
- Payment held in escrow from booking until 1 hour after session end
- If trainer cancels within 24 hours → full refund + 1 Dumbbell compensation to client
- If client cancels within 24 hours → 50% refund (50% to trainer as cancellation fee)
- If client cancels >24 hours before → full refund
- No-show by trainer → full refund + 2 Dumbbell compensation
- Disputes: either party can open a dispute within 48 hours of session end → admin review within 3 business days

### 8.3 Async Training Programmes

Trainers can create and sell **structured programmes**:

- Programme name + description
- Duration: 2 weeks / 4 weeks / 8 weeks / 12 weeks / Custom
- Delivery: week-by-week workout plan (video + PDF + text)
- Price: one-time artifact payment
- Client purchases → gains access to all weeks immediately (or unlocked week-by-week — configurable)
- Progress tracking: client logs each workout; trainer sees completion % per client
- Comments: client can comment on each workout; trainer receives notification and can reply

### 8.4 Health Practitioner Features

Verified health practitioners (dietitians, physios, psychologists, etc.) have:

- Same session booking system as trainers
- **Consultation type:** Nutrition Assessment / Injury Assessment / Mental Health Session / General Wellness Consultation / Prescription Review
- **Clinical notes:** private field (visible only to practitioner); never shared with platform or other users
- **Referral system:** practitioners can tag and refer users to other verified practitioners
- **Prescription / Recommendation generation:** practitioners can generate a structured recommendation doc (PDF) within the platform and share securely with the client — it appears in the client's health records section of their profile (private, only they can see)
- **Group sessions:** e.g., weekly nutrition webinar — same as Gym Scheduled Live but hosted by a practitioner
- **HIPAA/GDPR notes:** BuddyUp does not claim to be a medical platform. Practitioners are reminded at sign-up that the platform does not provide medical record storage compliant with full HIPAA; clinical documentation should use certified EHR systems. BuddyUp is a connection platform.

---

## 🛒 SECTION 9: MARKETPLACE

### 9.1 Marketplace Categories

The BuddyUp Marketplace at `/marketplace` has five storefronts:

1. **Meal Plans:** structured eating guides from verified nutritionists and dietitians
2. **Training Programmes:** full workout programmes from verified trainers (see Section 8.3)
3. **Supplements:** third-party supplement brands listed (affiliate model; no direct fulfilment by BuddyUp)
4. **Prescribed / Recommended Products:** products recommended by verified health practitioners (with "Recommended by [practitioner name]" badge)
5. **Equipment & Gear:** affiliate links to fitness equipment (no direct fulfilment)

### 9.2 Meal Plans

**A meal plan listing includes:**
- Title + description
- Created by: verified nutritionist / dietitian (badge shown)
- Duration: 1 week / 2 weeks / 4 weeks / custom
- Dietary type: Vegan / Keto / Balanced / High Protein / Weight Loss / Muscle Gain / Diabetic-friendly / etc.
- Calorie range per day
- Preview: day 1 sample (free)
- Full plan: locked behind purchase
- Price: artifact amount
- Includes: daily breakfast / lunch / dinner / snacks; shopping list; macro breakdown per meal; preparation instructions
- Reviews from purchasers (only verified buyers)
- "AI personalise this plan for me": sends the plan to the AI system with user's data to adjust portions and substitutes (see Section 9.3)

### 9.3 AI Meal Plan Personalisation

**Data collection (onboarding + profile update):**
- Height, weight, age (from DOB), biological sex (optional), activity level
- Dietary restrictions (allergies: nuts, dairy, gluten, etc.)
- Food preferences (dislikes)
- Health goals (weight loss, gain, maintenance)
- Medical conditions flagged (diabetes, hypertension, etc. — user self-reports; not verified medically)
- Budget per meal (optional)
- Country / region (for locally available foods)

**AI Pipeline:**
- Model: fine-tuned LLM (GPT-4 or Claude via API, or locally trained nutrition model) with a structured nutrition database (USDA FoodData Central or regional equivalent)
- Input: user profile data + selected meal plan
- Output: adjusted meal plan with:
  - Portion adjustments per meal (scaled to user's TDEE calculation)
  - Ingredient substitutions for restrictions/preferences
  - Alternative meals for each slot
  - Weekly macro summary
  - Shopping list updated with substitutions
- Output delivered as: in-app interactive plan view + downloadable PDF
- Disclaimer (always shown): "This personalised plan is generated by AI and is for general wellness purposes only. Consult a qualified dietitian before making significant dietary changes, especially if you have a medical condition."
- Optional: connect with the plan's creator for a consultation CTA

**Wearable/App Integration (optional, user-connected):**
- Apple Health, Google Fit, Fitbit, Garmin Connect, MyFitnessPal
- OAuth connection; pulls: daily steps, calories burned, sleep data, heart rate
- Used to: refine meal plan calorie targets dynamically, log workout calories automatically

### 9.4 Supplements & Products

- Third-party brands apply to list products via a partner application form
- Platform vets: no banned substances, no unapproved medical claims, no products harmful to minors
- Each product listing: image, name, brand, description, ingredients, serving suggestions, price (links to external store or in-app purchase with affiliate tracking)
- "Recommended by a practitioner" badge if at least one verified practitioner has tagged the product in a recommendation
- Reviews from platform users who purchased
- "Report this product" option

---

## 💬 SECTION 10: MESSAGING

### 10.1 Who Can Message Whom

- **DMs are only available between confirmed two-way buddies**
- Trainer → Client: once a session is booked, a dedicated session chat thread opens regardless of buddy status (auto-archived 7 days after session ends unless both parties buddy up)
- Gym group chat: available to all members of a gym (opt-in per member — can choose to participate or mute)

### 10.2 DM Features

Full real-time messaging (see BuddyUp's messaging architecture below):
- Text messages
- Photo sharing (from camera or gallery)
- Short video sharing (up to 2 minutes)
- Voice notes (up to 5 minutes)
- Document sharing (PDF, up to 20MB)
- Location sharing
- Workout log sharing (share a completed workout log as a card)
- Meal plan card (share a meal plan you purchased)
- Send an artifact tip (from within the DM)
- Accountability ping: "Did you work out today? 💪" — a quick-send action without typing
- Reply threading (1 level deep)
- Emoji reactions on messages
- Message deletion (own messages; soft delete — shows "Message deleted" to the other party)
- Message read receipts (✓ sent, ✓✓ read)
- Typing indicator
- Online/active status

### 10.3 Group Chat (Gym)

- Created automatically when a gym is created; owner can rename it
- Up to 1,000 members in one group chat
- Mentions (@username) trigger notifications
- Pin important messages (moderators)
- Admin can: slow mode, mute individual members, remove from chat, broadcast-only mode (only trainers/owners can post; members read-only)
- Sub-groups: gym can create up to 5 sub-channels (e.g., #announcements, #nutrition, #challenges, #general)

### 10.4 Message Safety

- End-to-end encrypted DMs (using Signal Protocol or equivalent)
- No DM content stored in readable form on servers (metadata only: who, when, read status)
- Reporting a DM: decryption of the reported message only (with user consent at report submission)
- Spam protection: new buddies (< 24 hours) have a 5-message/hour rate limit in DMs
- Media: all media in messages scanned for CSAM (PhotoDNA or equivalent) before delivery

---

## 🔔 SECTION 11: NOTIFICATIONS

### 11.1 Notification Types

| Trigger | Channel |
|---|---|
| New buddy request | Push + in-app bell |
| Buddy request accepted | Push + in-app bell |
| New DM message | Push + in-app bell |
| Live starting (followed/budied user) | Push |
| Gym live starting (member) | Push (15 min before) |
| Post reaction / comment | In-app bell (batched hourly) |
| Comment reply | Push + in-app bell |
| Post repost/quote | In-app bell |
| New follower | In-app bell |
| Session booking confirmed | Push + email |
| Session reminder | Push (24hr + 1hr before) |
| Session cancelled | Push + email |
| Payment/purchase | Email + in-app bell |
| Withdrawal processed | Email + in-app bell |
| Account: new login from new device | Email + push |
| Account: verification status update | Email + push |
| Streak milestone | Push + in-app celebration |
| Gym: new member joined | In-app bell (gym owners/mods) |
| Streak about to break | Push (if user has worked out yesterday but not today and it's evening) |

### 11.2 Notification Preferences

Users can configure per-category: Push ON/OFF, Email ON/OFF, In-app ON/OFF.
Quiet hours: set a time window where no push notifications are sent (e.g., 10 PM – 6 AM).

---

## 📋 SECTION 12: POLICIES, LEGAL & COMPLIANCE

### 12.1 Community Guidelines (Key Provisions)

BuddyUp's community guidelines exist to keep the platform safe, inclusive, and focused on health and wellness. The following are non-negotiable platform rules — violations result in content removal, warnings, suspension, or permanent bans.

**Health & Safety**
- No promotion of eating disorders (extreme restriction, purging, or other disordered eating)
- No promotion of unverified supplements, unlicensed drugs, or dangerous practices (e.g., dehydration for weight cutting without medical supervision)
- No medical or nutritional advice from unverified users presented as professional guidance. Users who are not verified practitioners must include a disclaimer when sharing health information.
- No promotion of performance-enhancing drugs (PEDs) except for factual educational content from verified practitioners
- Content depicting extreme self-harm in the context of fitness (dangerous stunts, misuse of equipment) → removed
- All advice posted by health practitioners in their capacity as practitioners must be factual and within their scope of practice

**Age Safety**
- Platform strictly 16+. Any accounts confirmed to belong to under-16s are permanently terminated
- No content sexualising minors or designed to appeal inappropriately to persons under 16
- No creation or sharing of any CSAM (zero tolerance → immediate account termination + report to relevant authorities)

**Respect & Inclusion**
- No hate speech targeting any person based on body size/shape, race, religion, gender, disability, sexual orientation, or nationality
- No body-shaming, fat-phobia, or diet-culture extremism
- No bullying, harassment, or targeted abuse
- No spam or coordinated inauthentic behaviour
- No impersonation of verified trainers, practitioners, or public figures

**Commercial Integrity**
- No fraudulent training services (claiming certifications not held, taking payment without delivering services)
- No fake reviews
- No artifical inflation of metrics (purchased followers, bot engagement)
- Promoted/sponsored content must be clearly disclosed with a "Sponsored" or "Paid Partnership" tag

**Privacy**
- No sharing of another person's private information without consent (doxxing)
- No recording or sharing of content from a private group or live without consent of all participants

**Consequences Matrix:**
- First violation (minor): Warning + content removal
- Second violation (minor) or First violation (moderate): 24-hour content posting suspension
- Third violation (minor) or Second violation (moderate) or First violation (severe): 7-day full suspension
- Fourth violation or Second violation (severe): 30-day suspension + mandatory account review
- Fifth violation or Any violation (critical): Permanent ban + potential law enforcement referral

### 12.2 Terms of Service (Key Provisions)

**Age Requirement:** Users must be 16 years of age or older. By creating an account, users confirm this. BuddyUp reserves the right to terminate any account where the user is found to be under 16, without refund.

**Account Ownership:** Accounts are personal and non-transferable. Users are responsible for all activity under their account.

**Content Licence:** By posting content on BuddyUp, users grant BuddyUp a non-exclusive, royalty-free, worldwide licence to display, distribute, and promote the content on and through the platform. Users retain full ownership of their content.

**Virtual Currency:** Fitness artifacts are virtual tokens with no cash value outside the platform. BuddyUp reserves the right to adjust the artifact economy. Unused artifact balances are non-refundable except as required by applicable law.

**Trainer & Practitioner Liability:** BuddyUp is a connection platform and does not employ trainers or practitioners. Users engage these professionals at their own risk. BuddyUp does not warrant the accuracy of trainer certifications (though we verify to the best of our ability) and is not liable for any harm arising from following advice obtained on the platform.

**Dispute Resolution:** All disputes must first go through BuddyUp's internal resolution process. If unresolved, binding arbitration applies (jurisdiction: Kenya, with users outside Kenya subject to international arbitration).

**Modification:** BuddyUp reserves the right to modify these terms with 30 days' notice. Continued use constitutes acceptance.

### 12.3 Privacy Policy (Key Provisions)

**Data Collected:**
- Identity data: name, username, email, phone, DOB (encrypted), profile photo
- Health data: fitness goals, activity level, dietary preferences, workout logs (user-provided)
- Device data: IP address, device type, OS, browser, approximate location (from IP)
- Usage data: pages visited, features used, session duration
- Payment data: payment method tokens (no raw card data stored; handled by payment processors)
- Biometric data: face detection used only for CSAM screening; no facial recognition or biometric profiles built

**How Data Is Used:**
- To provide and improve the platform
- To personalise content, recommendations, and the AI meal plan system
- To process payments and prevent fraud
- To enforce Community Guidelines
- To communicate service updates and account information
- To comply with legal obligations

**Data Sharing:**
- BuddyUp does not sell personal data to third parties
- Data shared with: payment processors (Stripe, M-Pesa, Flutterwave), cloud providers (AWS/GCP), content moderation services, verification services (Smile Identity/Onfido), analytics (privacy-compliant: Plausible or Fathom — not Google Analytics)
- All third parties are contractually bound to process data only per our instructions

**Data Retention:**
- Active accounts: retained for account lifetime
- Deleted accounts: PII deleted within 30 days of hard deletion; content anonymised; financial records retained 7 years (legal requirement)
- Logs: 90-day retention

**User Rights (GDPR / Kenya DPA):**
- Right to access: request a copy of all held data (fulfilled within 30 days)
- Right to rectification: update inaccurate data
- Right to erasure: request account and data deletion
- Right to portability: receive data in machine-readable format (JSON)
- Right to object: to processing for direct marketing (opt-out immediately honoured)
- Right to complain: to the Kenya Office of the Data Protection Commissioner (or applicable authority in user's jurisdiction)

**Cookies:** Strictly necessary cookies only by default. Analytics and optional cookies require explicit consent via a cookie banner on first visit.

### 12.4 Age Verification & COPPA/Children's Data

- BuddyUp does not knowingly collect data from persons under 16
- Age gate (DOB) at registration; confirmed buddies can report suspected underage accounts
- Parental requests to remove a child's data honoured within 72 hours
- Any CSAM discovered is reported immediately to NCMEC (US) and relevant local authorities

---

## 🌐 SECTION 13: LANDING PAGE

### 13.1 Purpose

The landing page converts visitors into registered users. It is public-facing, requires zero authentication, and must load in under 2 seconds on a 4G mobile connection.

### 13.2 Sections

**1 — Hero**
- Headline: "Find your fitness family." (Syne ExtraBold, large, white on dark)
- Sub-headline: "Train with buddies, join live workouts, eat better, and stay accountable — all in one place."
- Primary CTA: "Get Started — It's Free" (green button, prominent)
- Secondary CTA: "Watch how it works" (play button → inline modal video demo, 90 seconds)
- Hero visual: split-screen animation — left: someone in a Random Drop live workout; right: a nutrition progress chart and buddy activity feed
- Social proof strip: "Join 500,000+ people already training together" + logo strip of media mentions

**2 — Value Props (Three Pillars)**
Three large cards:
- 🤝 **Find Your Buddy** — "Connect with people who match your fitness level, goals, and schedule"
- 📡 **Live Workouts, Anytime** — "Drop into a live HIIT class, run a yoga session, or join a random workout at any time"
- 🏋️ **Gyms Built Around You** — "Create or join communities (gyms) that keep you accountable and motivated"

**3 — How Buddying Up Works (animated walkthrough)**
Step-by-step horizontal scroll (or vertical on mobile):
1. Create your profile & set your goals
2. Find buddies who match your vibe
3. Train together via live sessions or Random Drops
4. Build your gym community
5. Track progress and stay accountable

**4 — Feature Showcase (tabbed)**
Tabs: Live Sessions | Gyms | Trainers | Meal Plans | Buddy Feed
Each tab shows a device mockup with the actual feature UI

**5 — Social Proof / Testimonials**
4 testimonial cards: photo, name, goal achieved, quote. Rotating carousel.

**6 — Trainers & Practitioners CTA**
"Are you a trainer or health professional?"
- Sub-copy: "BuddyUp helps you reach clients, run live sessions, and build your fitness community. Verified profiles. Real revenue."
- CTA: "Join as a Trainer"

**7 — Gym Founders CTA**
"Start your own gym on BuddyUp"
- Sub-copy: "Build a paid or free fitness community. Set a schedule. Grow your tribe."
- CTA: "Create a Gym"

**8 — Pricing Overview**
- Free tier: what's included
- Premium tier: price + what's unlocked
- Simple comparison table (3 columns: Free / Premium / Trainer Pro)

**9 — App Store Download**
- "Train anytime, anywhere"
- App Store badge + Google Play badge
- QR code to download

**10 — Footer**
- Logo + tagline
- Navigation: Features / Trainers / For Gyms / Pricing / Blog / Careers / Help
- Social: Instagram, TikTok, YouTube, Twitter/X
- Legal: Terms / Privacy / Community Guidelines / Cookie Settings
- Copyright © 2025 BuddyUp. All rights reserved.

---

## 📱 SECTION 14: MAIN APP STRUCTURE & NAVIGATION

### 14.1 Bottom Navigation (Mobile — 5 Items)

```
┌──────┬──────┬──────┬──────┬──────┐
│ 🏠   │ 🔍   │ 📡+  │ 🔔   │ 👤   │
│ Home │ Find │ Live │Notif.│Profile│
└──────┴──────┴──────┴──────┴──────┘
```

- **Home (🏠):** Main feed with "For You / Following / Nearby" tabs
- **Find (🔍):** Discover — users, trainers, gyms, trending content, search
- **Live (📡 +):** Lives browser + "Start Live" button (centre, elevated, green — always visible)
- **Notifications (🔔):** Activity bell with unread count badge
- **Profile (👤):** Own profile shortcut

### 14.2 Sidebar Navigation (Desktop / Tablet)

```
BuddyUp logo
────────────
🏠 Home
🔍 Discover
📡 Lives
🏋️ Gyms
👥 Trainers & Practitioners
🛒 Marketplace
📅 Sessions
💬 Messages
🔔 Notifications
💰 Wallet
👤 Profile
────────────
⚙️ Settings
❓ Help & Safety
```

### 14.3 Discover Page (`/discover`)

**Search bar (top):** searches across users, gyms, trainers, content, meal plans

**Category tabs:** People | Gyms | Trainers | Practitioners | Lives | Trending

**Recommended for You** (based on onboarding data):
- "Buddies you might know" — users with mutual buddies or shared gym
- "Trainers in your area" — within 50km (if location shared)
- "Gyms matching your goals" — filtered by onboarding preferences
- "Trending BuddyClips" — short videos currently viral
- "Live right now" — lives matching interests

**Search Results:** ranked by relevance; filterable sidebar; support autocomplete

---

## ⚙️ SECTION 15: SETTINGS & ACCOUNT MANAGEMENT

### `/settings` Page Structure

**Account**
- Edit profile (redirects to /profile/edit)
- Change email / phone
- Change password
- Linked accounts (Google, Apple)
- Verified accounts management (certifications, documents)
- Deactivate account (30-day reversible)
- Delete account (permanent after 30-day grace)

**Privacy**
- Account visibility: Public / Friends of Friends / Buddies Only / Private
- Who can send buddy requests: Everyone / Followers / No one
- Who can message me: Everyone (no — only buddies is default) / Buddies Only
- Who sees my activity status: Everyone / Buddies / No one
- Who sees my gyms: Everyone / Buddies / Only me
- Data collection for personalisation: toggle
- Wearable/app connection management

**Notifications** (see Section 11.2)

**Security**
- Two-factor authentication (enable/disable TOTP or SMS)
- Active sessions (see all; sign out others)
- Login alerts
- App passwords (for wearable integrations)

**Blocked Users**
- List with "Unblock" option

**Content Preferences**
- Mature content toggle (sensitive health content — e.g., body transformation before/afters; off by default; age 18+ only)
- Profanity filter: Strict / Standard / Off
- Language of content in feed

**Subscription & Billing**
- Active gym subscriptions (with cancel option)
- PT subscription packages
- Billing history (redirects to wallet)

**Help & Safety**
- Report a problem
- Community Guidelines
- Safety Centre
- Contact Support
- Accessibility settings

---

## 🏗️ SECTION 16: TECHNICAL ARCHITECTURE

### 16.1 Tech Stack

---

#### FRONTEND: React 18 + TypeScript

The entire frontend is built with **React 18** and **TypeScript** (strict mode). Vite is the bundler for fast development and optimised production builds. There is no Next.js or any SSR framework — the app is a fully client-rendered SPA with the landing page served as a static HTML build from the same Vite project.

| Layer | Technology | Notes |
|---|---|---|
| **Language** | TypeScript 5 (strict mode) | `"strict": true` in tsconfig; no `any` escapes without explicit justification |
| **Framework** | React 18 | Concurrent features, `useTransition`, `Suspense` used throughout |
| **Bundler** | Vite 5 | Lightning-fast HMR in dev; code-split, tree-shaken production builds |
| **Routing** | React Router v6 | `createBrowserRouter` with lazy-loaded route modules; nested routes for portal/feed layouts |
| **Styling** | Tailwind CSS v3 | `tailwind.config.ts` extends design tokens (`buddy-green`, `buddy-electric`, etc.) as custom colours; dark mode via `class` strategy |
| **Animations** | Framer Motion | Page transitions, Rep Ring arc animation, live reaction float-up, artifact gift screen animations |
| **State — global** | Zustand | Auth store, theme store, notification store, presence store, artifact balance store |
| **State — server** | TanStack Query v5 | All API calls, cursor-based infinite scroll for feeds, 30s stale time for feed, 5s for live viewer counts |
| **Forms** | React Hook Form + Zod | All forms validated with Zod schemas; shared schema types between frontend and backend via a `shared-types` package |
| **HTTP client** | Axios | Interceptors for JWT injection (access token from memory) and silent token refresh on 401 |
| **WebSocket** | Custom `WsManager` class (TypeScript) | Singleton; manages all WS connections; exponential backoff reconnect; event emitter pattern |
| **Live streaming — client** | Agora Web SDK 4.x (TypeScript) | Low-latency WebRTC for Random Drop (≤15 users); CDN broadcast mode for Gym Lives |
| **Video player** | Mux Player React (`@mux/mux-player-react`) | Replays, long-form video; adaptive bitrate; subtitles; chapters |
| **Short video** | Custom `<BuddyClipPlayer>` component | Built on HTML5 `<video>`, auto-play on scroll (IntersectionObserver), loop, mute-on-load |
| **Maps** | `@vis.gl/react-google-maps` | Location sharing, trainer location tagging |
| **Camera / Media** | `getUserMedia` + `MediaRecorder` API | In-app camera for BuddyClips, voice notes, live stream preview |
| **Barcode scan** | `@zxing/browser` | Meal post barcode scanner (food products) |
| **PWA** | `vite-plugin-pwa` | Service worker (Workbox), offline shell, push notification subscription |
| **Push (client)** | Firebase Cloud Messaging JS SDK | Receives FCM push tokens; registers in backend on login |
| **Icons** | Lucide React | UI system icons |
| **Artifact icons** | Custom SVG React components | Dumbbell, Barbell, Burpee, Squat, Sprint, PR, Champion — each an animated SVG with `aria-label` |
| **Charts** | Recharts | Creator analytics, streak charts, macro breakdown |
| **Date/time** | `date-fns` | All date formatting, streak calculations, "last seen" logic |
| **Internationalisation** | `react-i18next` | English base; Swahili support in v2 |
| **Accessibility** | `@radix-ui/react-*` primitives | Dialog, Dropdown, Select, Tooltip — unstyled, accessible; styled with Tailwind |
| **Testing** | Vitest + React Testing Library + Playwright | Unit: Vitest + RTL; E2E: Playwright |
| **Linting** | ESLint (typescript-eslint) + Prettier | Enforced in CI |

#### Frontend Folder Structure

```
/frontend
├── public/
│   ├── icons/              # PWA icons (192, 512, maskable)
│   ├── manifest.webmanifest
│   └── robots.txt
│
├── src/
│   ├── api/                # Axios instance + per-resource typed API functions
│   │   ├── client.ts       # Axios instance, interceptors, token refresh logic
│   │   ├── auth.ts
│   │   ├── profiles.ts
│   │   ├── feed.ts
│   │   ├── gyms.ts
│   │   ├── lives.ts
│   │   ├── sessions.ts
│   │   ├── messaging.ts
│   │   ├── marketplace.ts
│   │   ├── wallet.ts
│   │   └── ...
│   │
│   ├── assets/             # Static: fonts, SVGs, brand images
│   │
│   ├── components/
│   │   ├── ui/             # Design system primitives
│   │   │   ├── Button.tsx
│   │   │   ├── Card.tsx
│   │   │   ├── Avatar.tsx        # Includes Rep Ring arc
│   │   │   ├── Badge.tsx         # Verified badges
│   │   │   ├── ArtifactIcon.tsx  # Animated SVG artifacts
│   │   │   ├── Skeleton.tsx
│   │   │   ├── Modal.tsx
│   │   │   ├── Toast.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── RepRing.tsx       # Circular progress arc component
│   │   │   └── ...
│   │   │
│   │   ├── layout/
│   │   │   ├── AppShell.tsx      # Bottom nav + sidebar wrapper
│   │   │   ├── BottomNav.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   ├── TopBar.tsx
│   │   │   └── LandingLayout.tsx
│   │   │
│   │   └── features/       # Feature-specific composite components
│   │       ├── feed/       # PostCard, CommentSheet, ReactionBar, RepostButton
│   │       ├── lives/      # LiveCard, LivePlayer, RandomDropWaiting, RepCounter
│   │       ├── gyms/       # GymCard, GymSchedule, MemberList
│   │       ├── profiles/   # ProfileHeader, BuddyButton, StatsRow
│   │       ├── messaging/  # ConversationList, MessageBubble, ComposeBar
│   │       ├── wallet/     # ArtifactBalance, TransactionRow, BuyArtifactsSheet
│   │       ├── marketplace/# MealPlanCard, SupplementCard, ProgrammeCard
│   │       └── ...
│   │
│   ├── hooks/              # Custom React hooks
│   │   ├── useAuth.ts
│   │   ├── usePresence.ts
│   │   ├── useConversation.ts
│   │   ├── useLive.ts
│   │   ├── useRandomDrop.ts
│   │   ├── useInfiniteScroll.ts
│   │   ├── useMediaCapture.ts    # getUserMedia wrapper
│   │   ├── useStreakNudge.ts
│   │   └── ...
│   │
│   ├── lib/
│   │   ├── wsManager.ts          # WebSocket singleton manager
│   │   ├── agora.ts              # Agora SDK wrapper (typed)
│   │   ├── fcm.ts                # FCM push subscription
│   │   ├── cloudinaryUpload.ts   # Direct signed upload helper
│   │   └── artifactCalc.ts       # Artifact amount formatters
│   │
│   ├── pages/              # Route-level page components (lazy loaded)
│   │   ├── Landing.tsx
│   │   ├── auth/
│   │   │   ├── Login.tsx
│   │   │   ├── Register.tsx
│   │   │   ├── VerifyAge.tsx
│   │   │   ├── Onboarding.tsx
│   │   │   └── ForgotPassword.tsx
│   │   ├── app/
│   │   │   ├── Feed.tsx
│   │   │   ├── Discover.tsx
│   │   │   ├── Lives.tsx
│   │   │   ├── Gyms.tsx
│   │   │   ├── GymDetail.tsx
│   │   │   ├── Trainers.tsx
│   │   │   ├── TrainerProfile.tsx
│   │   │   ├── Marketplace.tsx
│   │   │   ├── Sessions.tsx
│   │   │   ├── Messages.tsx
│   │   │   ├── Wallet.tsx
│   │   │   ├── Notifications.tsx
│   │   │   ├── Profile.tsx
│   │   │   ├── UserProfile.tsx   # /:username public profile
│   │   │   └── Settings.tsx
│   │   └── legal/
│   │       ├── Terms.tsx
│   │       ├── Privacy.tsx
│   │       ├── CommunityGuidelines.tsx
│   │       └── CookiePolicy.tsx
│   │
│   ├── store/              # Zustand stores
│   │   ├── authStore.ts
│   │   ├── themeStore.ts
│   │   ├── notificationStore.ts
│   │   ├── presenceStore.ts
│   │   └── artifactStore.ts
│   │
│   ├── types/              # Shared TypeScript interfaces
│   │   ├── user.ts
│   │   ├── post.ts
│   │   ├── gym.ts
│   │   ├── live.ts
│   │   ├── wallet.ts
│   │   ├── api.ts          # API response envelope types
│   │   └── index.ts        # Re-exports
│   │
│   ├── utils/
│   │   ├── dateFormat.ts
│   │   ├── artifactFormat.ts
│   │   ├── ageCheck.ts           # Client-side DOB validation (server is authoritative)
│   │   └── permissions.ts        # Role/permission check helpers
│   │
│   ├── styles/
│   │   └── globals.css           # Tailwind base + CSS variable definitions
│   │
│   ├── router.tsx                # createBrowserRouter with all routes + lazy imports
│   ├── App.tsx                   # Root: QueryClientProvider + Router + ThemeProvider
│   └── main.tsx                  # Vite entry; StrictMode
│
├── .env.example
├── .eslintrc.cjs
├── .prettierrc
├── tailwind.config.ts
├── tsconfig.json
├── tsconfig.node.json
├── vite.config.ts
└── Dockerfile                    # Frontend Docker image (see Section 16.7)
```

---

#### BACKEND: Django 5 + DRF

| Layer | Technology | Notes |
|---|---|---|
| **Framework** | Django 5 + DRF | Python 3.12+ |
| **Real-time** | Django Channels 4 + Daphne | ASGI; WebSocket consumers for chat, live, presence, random drop |
| **Task queue** | Celery 5 + Redis | Scheduled + event-driven async tasks |
| **Database** | PostgreSQL 16 | Primary datastore; `ArrayField`, `JSONField`, `UUIDField` throughout |
| **Cache** | Redis 7 | Channel layer, presence store, feed cache, rate limiting, artifact exchange rates |
| **Search** | PostgreSQL Full-Text Search (start); Elasticsearch 8 (phase 2 at scale) | pg FTS with `SearchVector` and `SearchRank` for users, gyms, posts |
| **File storage** | Cloudinary | Images, videos, documents; direct browser upload via signed tokens |
| **Live streaming** | Agora.io REST API + Web SDK | Token generation server-side; channel management |
| **Video (replays)** | Mux | Video encoding, HLS, captions, thumbnails, analytics |
| **Email** | SendGrid (via `django-sendgrid-v5`) | Transactional: OTPs, session confirmations, withdrawal receipts |
| **SMS / OTP** | Africa's Talking Python SDK | OTP SMS, M-Pesa STK integration |
| **Push** | Firebase Admin SDK | FCM server-side push dispatch |
| **Payments** | Stripe Python SDK / Daraja (M-Pesa) / Flutterwave API | Multi-provider; unified `ArtifactTransaction` model |
| **KYC** | Smile Identity Python SDK | Africa-optimised document + selfie verification |
| **Content mod** | AWS Rekognition (images/video) + custom spaCy model (text) | Pre-publish pipeline; async via Celery |
| **AI / LLM** | OpenAI Python SDK (GPT-4o) | Meal plan personalisation; buddy recommendation scoring |
| **Encryption** | `django-encrypted-model-fields` | Email, phone, DOB stored encrypted at rest |
| **Auth** | `djangorestframework-simplejwt` | JWT access (15 min) + refresh (7 or 30 days); HttpOnly cookie for refresh |
| **Social auth** | `social-auth-app-django` | Google + Apple OAuth |
| **TOTP (2FA)** | `django-otp` + `qrcode` | TOTP for trainer/practitioner accounts |
| **CORS** | `django-cors-headers` | Configured to allow frontend origin only |
| **Rate limiting** | `django-ratelimit` | Per-endpoint throttling; Redis-backed |
| **API docs** | `drf-spectacular` | Auto OpenAPI 3 schema; Swagger UI at `/api/schema/swagger/` |
| **Monitoring** | Sentry Python SDK | Error tracking, performance tracing |
| **Analytics** | Custom aggregation views (admin); Plausible for public landing page | No Google Analytics |

---

#### INFRASTRUCTURE & HOSTING

| Service | Technology / Provider | Notes |
|---|---|---|
| **Containerisation** | Docker + Docker Compose | All services containerised; see Section 16.7 for full spec |
| **Frontend** | Nginx (Docker) in production; `vite dev` in development | Nginx serves the Vite static build; proxies `/api/` and `/ws/` to backend |
| **Backend (HTTP)** | Gunicorn (WSGI) behind Nginx, OR Daphne (ASGI) directly | Use Daphne for unified HTTP + WebSocket; Gunicorn for HTTP-only workers |
| **Backend (WS)** | Daphne (ASGI) | Always Daphne for WebSocket support; runs alongside or instead of Gunicorn |
| **Database** | PostgreSQL 16 (Docker container in dev; managed instance in prod) | Prod: Railway PostgreSQL, Supabase, or AWS RDS |
| **Cache / Broker** | Redis 7 (Docker) | Single Redis for Channels layer + Celery broker + cache |
| **Celery workers** | Separate Docker container (`celery worker`) | Multiple queues: `default`, `high_priority`, `media`, `ai` |
| **Celery Beat** | Separate Docker container (`celery beat`) | Scheduled tasks (cron-equivalent) |
| **CDN** | Cloudflare | DNS, SSL termination, static asset caching, DDoS protection |
| **Video CDN** | Mux / Cloudflare Stream | Live stream delivery + replay HLS |
| **CI/CD** | GitHub Actions | On push to `main`: lint → type-check → test → Docker build → push to registry → deploy |
| **Container registry** | GitHub Container Registry (GHCR) | `ghcr.io/buddyup/frontend:latest`, `ghcr.io/buddyup/backend:latest` |
| **Production deploy** | Railway (managed containers) or self-hosted VPS (Ubuntu 24) | Both configurations supported; `docker-compose.prod.yml` provided |
| **Monitoring** | Sentry (errors) + Grafana + Prometheus (metrics) | Grafana dashboards: request latency, WebSocket connections, live viewer counts, Celery queue depth |
| **Domain** | `buddyup.app` | SSL via Cloudflare; `api.buddyup.app` for backend; `www.buddyup.app` redirects to apex |

---

### 16.7 Docker Configuration (Complete Specification)

The entire BuddyUp stack runs in Docker. There are two Compose files:
- `docker-compose.yml` — **development** (hot reload, debug mode, exposed ports, no SSL)
- `docker-compose.prod.yml` — **production** (built images, Nginx, secrets via environment, no exposed DB ports)

#### Service Map

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         BUDDYUP DOCKER SERVICES                         │
├───────────────────┬─────────────────────────────────────────────────────┤
│  frontend         │  React + TypeScript + Vite (dev) / Nginx (prod)     │
│  backend          │  Django 5 + DRF + Daphne (ASGI)                     │
│  celery-worker    │  Celery worker (multi-queue)                         │
│  celery-beat      │  Celery beat scheduler                               │
│  db               │  PostgreSQL 16                                       │
│  redis            │  Redis 7 (cache + channel layer + Celery broker)     │
│  nginx            │  Nginx reverse proxy (prod only)                     │
└───────────────────┴─────────────────────────────────────────────────────┘
```

#### `docker-compose.yml` (Development)

```yaml
version: "3.9"

services:

  # ── DATABASE ──────────────────────────────────────────────────────────
  db:
    image: postgres:16-alpine
    container_name: buddyup_db
    restart: unless-stopped
    environment:
      POSTGRES_DB: buddyup_dev
      POSTGRES_USER: buddyup
      POSTGRES_PASSWORD: ${DB_PASSWORD:-devpassword}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"   # Exposed for local DB tools (TablePlus, DBeaver)
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U buddyup -d buddyup_dev"]
      interval: 10s
      timeout: 5s
      retries: 5

  # ── REDIS ─────────────────────────────────────────────────────────────
  redis:
    image: redis:7-alpine
    container_name: buddyup_redis
    restart: unless-stopped
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"   # Exposed for local Redis tools (RedisInsight)
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # ── BACKEND (Django + Daphne) ─────────────────────────────────────────
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
      target: development
    container_name: buddyup_backend
    restart: unless-stopped
    command: >
      sh -c "python manage.py migrate --noinput &&
             python manage.py collectstatic --noinput &&
             daphne -b 0.0.0.0 -p 8000 config.asgi:application"
    environment:
      - DJANGO_SETTINGS_MODULE=config.settings.development
      - DATABASE_URL=postgresql://buddyup:${DB_PASSWORD:-devpassword}@db:5432/buddyup_dev
      - REDIS_URL=redis://redis:6379/0
      - SECRET_KEY=${SECRET_KEY:-dev-secret-key-change-in-prod}
      - DEBUG=True
      - ALLOWED_HOSTS=localhost,127.0.0.1,backend
      - CORS_ALLOWED_ORIGINS=http://localhost:5173,http://frontend:5173
    volumes:
      - ./backend:/app                    # Live code reload in dev
      - backend_static:/app/staticfiles
      - backend_media:/app/media
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/v1/health/"]
      interval: 30s
      timeout: 10s
      retries: 3

  # ── CELERY WORKER ─────────────────────────────────────────────────────
  celery-worker:
    build:
      context: ./backend
      dockerfile: Dockerfile
      target: development
    container_name: buddyup_celery_worker
    restart: unless-stopped
    command: >
      celery -A config.celery worker
        --loglevel=info
        --concurrency=4
        -Q default,high_priority,media,ai
    environment:
      - DJANGO_SETTINGS_MODULE=config.settings.development
      - DATABASE_URL=postgresql://buddyup:${DB_PASSWORD:-devpassword}@db:5432/buddyup_dev
      - REDIS_URL=redis://redis:6379/0
      - SECRET_KEY=${SECRET_KEY:-dev-secret-key-change-in-prod}
    volumes:
      - ./backend:/app
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy

  # ── CELERY BEAT (SCHEDULER) ───────────────────────────────────────────
  celery-beat:
    build:
      context: ./backend
      dockerfile: Dockerfile
      target: development
    container_name: buddyup_celery_beat
    restart: unless-stopped
    command: >
      celery -A config.celery beat
        --loglevel=info
        --scheduler django_celery_beat.schedulers:DatabaseScheduler
    environment:
      - DJANGO_SETTINGS_MODULE=config.settings.development
      - DATABASE_URL=postgresql://buddyup:${DB_PASSWORD:-devpassword}@db:5432/buddyup_dev
      - REDIS_URL=redis://redis:6379/0
      - SECRET_KEY=${SECRET_KEY:-dev-secret-key-change-in-prod}
    volumes:
      - ./backend:/app
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy

  # ── FRONTEND (Vite Dev Server) ────────────────────────────────────────
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      target: development
    container_name: buddyup_frontend
    restart: unless-stopped
    command: npm run dev -- --host 0.0.0.0 --port 5173
    environment:
      - VITE_API_BASE_URL=http://localhost:8000/api/v1
      - VITE_WS_BASE_URL=ws://localhost:8000
      - VITE_AGORA_APP_ID=${AGORA_APP_ID}
      - VITE_GOOGLE_MAPS_KEY=${GOOGLE_MAPS_KEY}
      - VITE_FIREBASE_CONFIG=${FIREBASE_CONFIG_JSON}
      - VITE_CLOUDINARY_CLOUD_NAME=${CLOUDINARY_CLOUD_NAME}
    volumes:
      - ./frontend:/app                   # Live code reload (HMR)
      - /app/node_modules                 # Preserve node_modules inside container
    ports:
      - "5173:5173"
    depends_on:
      - backend

volumes:
  postgres_data:
  redis_data:
  backend_static:
  backend_media:
```

#### `docker-compose.prod.yml` (Production Override)

```yaml
version: "3.9"

services:

  db:
    image: postgres:16-alpine
    restart: always
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    # NOTE: ports NOT exposed in prod — only internal network access
    networks:
      - buddyup_internal

  redis:
    image: redis:7-alpine
    restart: always
    command: >
      redis-server
        --appendonly yes
        --requirepass ${REDIS_PASSWORD}
        --maxmemory 512mb
        --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    networks:
      - buddyup_internal

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
      target: production
    restart: always
    command: >
      sh -c "python manage.py migrate --noinput &&
             python manage.py collectstatic --noinput &&
             daphne -b 0.0.0.0 -p 8000 config.asgi:application"
    environment:
      - DJANGO_SETTINGS_MODULE=config.settings.production
      - DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
      - REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379/0
      - SECRET_KEY=${SECRET_KEY}
      - DEBUG=False
      - ALLOWED_HOSTS=${ALLOWED_HOSTS}
      - CORS_ALLOWED_ORIGINS=${CORS_ALLOWED_ORIGINS}
      # Third-party keys
      - CLOUDINARY_URL=${CLOUDINARY_URL}
      - SENDGRID_API_KEY=${SENDGRID_API_KEY}
      - AFRICASTALKING_API_KEY=${AFRICASTALKING_API_KEY}
      - STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}
      - STRIPE_WEBHOOK_SECRET=${STRIPE_WEBHOOK_SECRET}
      - MPESA_CONSUMER_KEY=${MPESA_CONSUMER_KEY}
      - MPESA_CONSUMER_SECRET=${MPESA_CONSUMER_SECRET}
      - MPESA_SHORTCODE=${MPESA_SHORTCODE}
      - MPESA_PASSKEY=${MPESA_PASSKEY}
      - FLUTTERWAVE_SECRET_KEY=${FLUTTERWAVE_SECRET_KEY}
      - AGORA_APP_ID=${AGORA_APP_ID}
      - AGORA_APP_CERTIFICATE=${AGORA_APP_CERTIFICATE}
      - MUX_TOKEN_ID=${MUX_TOKEN_ID}
      - MUX_TOKEN_SECRET=${MUX_TOKEN_SECRET}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - FIREBASE_SERVICE_ACCOUNT_JSON=${FIREBASE_SERVICE_ACCOUNT_JSON}
      - SENTRY_DSN=${SENTRY_DSN}
    volumes:
      - backend_static:/app/staticfiles
    networks:
      - buddyup_internal
    depends_on:
      - db
      - redis

  celery-worker:
    build:
      context: ./backend
      dockerfile: Dockerfile
      target: production
    restart: always
    command: >
      celery -A config.celery worker
        --loglevel=warning
        --concurrency=8
        -Q default,high_priority,media,ai
        --max-tasks-per-child=1000
    env_file: .env.prod
    networks:
      - buddyup_internal
    depends_on:
      - db
      - redis

  celery-beat:
    build:
      context: ./backend
      dockerfile: Dockerfile
      target: production
    restart: always
    command: >
      celery -A config.celery beat
        --loglevel=warning
        --scheduler django_celery_beat.schedulers:DatabaseScheduler
    env_file: .env.prod
    networks:
      - buddyup_internal
    depends_on:
      - db
      - redis

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      target: production    # Builds static files, served by nginx
    restart: always
    networks:
      - buddyup_internal

  nginx:
    image: nginx:1.25-alpine
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro          # SSL certs (Let's Encrypt via Certbot)
      - backend_static:/var/www/static:ro
      - frontend_build:/var/www/frontend:ro    # Served from frontend container build
    networks:
      - buddyup_internal
    depends_on:
      - backend
      - frontend

volumes:
  postgres_data:
  redis_data:
  backend_static:
  frontend_build:

networks:
  buddyup_internal:
    driver: bridge
```

#### `nginx/nginx.conf`

```nginx
events {
    worker_connections 1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile      on;
    gzip          on;
    gzip_types    text/plain text/css application/javascript application/json;

    # Rate limiting zones
    limit_req_zone $binary_remote_addr zone=api:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=auth:10m rate=10r/m;

    upstream backend {
        server backend:8000;
    }

    server {
        listen 80;
        server_name buddyup.app www.buddyup.app;
        return 301 https://$host$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name buddyup.app www.buddyup.app;

        ssl_certificate     /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;
        ssl_protocols       TLSv1.2 TLSv1.3;
        ssl_ciphers         HIGH:!aNULL:!MD5;

        # Security headers
        add_header X-Frame-Options           "SAMEORIGIN" always;
        add_header X-Content-Type-Options    "nosniff" always;
        add_header X-XSS-Protection          "1; mode=block" always;
        add_header Referrer-Policy           "strict-origin-when-cross-origin" always;
        add_header Content-Security-Policy   "default-src 'self'; script-src 'self' 'unsafe-inline' https://www.gstatic.com; img-src 'self' data: https://res.cloudinary.com; connect-src 'self' wss://buddyup.app https://api.agora.io;" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # ── Frontend (React SPA) ──────────────────────────────────────
        root /var/www/frontend;
        index index.html;

        location / {
            try_files $uri $uri/ /index.html;   # SPA fallback
            expires 1h;
            add_header Cache-Control "public, no-transform";
        }

        # Cache static assets aggressively (Vite uses content hashing)
        location /assets/ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # ── Backend API ───────────────────────────────────────────────
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            proxy_pass         http://backend;
            proxy_set_header   Host              $host;
            proxy_set_header   X-Real-IP         $remote_addr;
            proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
            proxy_set_header   X-Forwarded-Proto $scheme;
            proxy_read_timeout 60s;
        }

        # Stricter rate limit for auth endpoints
        location /api/v1/auth/ {
            limit_req zone=auth burst=5 nodelay;
            proxy_pass         http://backend;
            proxy_set_header   Host              $host;
            proxy_set_header   X-Real-IP         $remote_addr;
            proxy_set_header   X-Forwarded-Proto $scheme;
        }

        # ── Django Admin ──────────────────────────────────────────────
        location /admin/ {
            allow  <admin_ip_whitelist>;
            deny   all;
            proxy_pass         http://backend;
            proxy_set_header   Host              $host;
            proxy_set_header   X-Real-IP         $remote_addr;
        }

        # ── Static files (Django) ─────────────────────────────────────
        location /static/ {
            alias  /var/www/static/;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # ── WebSocket (Django Channels / Agora signalling) ────────────
        location /ws/ {
            proxy_pass             http://backend;
            proxy_http_version     1.1;
            proxy_set_header       Upgrade    $http_upgrade;
            proxy_set_header       Connection "upgrade";
            proxy_set_header       Host       $host;
            proxy_read_timeout     86400s;    # Keep WS alive (24hr max)
            proxy_send_timeout     86400s;
        }
    }
}
```

#### `backend/Dockerfile`

```dockerfile
# ── Base ──────────────────────────────────────────────────────────────
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ── Dependencies ───────────────────────────────────────────────────────
FROM base AS deps

COPY requirements/base.txt ./requirements/base.txt
RUN pip install --no-cache-dir -r requirements/base.txt

# ── Development ────────────────────────────────────────────────────────
FROM deps AS development

COPY requirements/development.txt ./requirements/development.txt
RUN pip install --no-cache-dir -r requirements/development.txt

COPY . .
EXPOSE 8000

# ── Production ─────────────────────────────────────────────────────────
FROM deps AS production

COPY requirements/production.txt ./requirements/production.txt
RUN pip install --no-cache-dir -r requirements/production.txt

COPY . .

# Create non-root user for security
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser && \
    chown -R appuser:appgroup /app

USER appuser
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1/health/ || exit 1
```

#### `frontend/Dockerfile`

```dockerfile
# ── Base ──────────────────────────────────────────────────────────────
FROM node:20-alpine AS base

WORKDIR /app
ENV NODE_ENV=development

# ── Development ────────────────────────────────────────────────────────
FROM base AS development

COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 5173
# CMD overridden by docker-compose command

# ── Build ─────────────────────────────────────────────────────────────
FROM base AS builder

ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --only=production

COPY . .

# Build args injected at build time (Vite VITE_ prefix)
ARG VITE_API_BASE_URL
ARG VITE_WS_BASE_URL
ARG VITE_AGORA_APP_ID
ARG VITE_GOOGLE_MAPS_KEY
ARG VITE_CLOUDINARY_CLOUD_NAME

RUN npm run build          # Outputs to /app/dist

# ── Production (Nginx serves static files) ────────────────────────────
FROM nginx:1.25-alpine AS production

# Copy Vite build output into Nginx's serve directory
COPY --from=builder /app/dist /var/www/frontend

# Nginx config is provided externally (mounted or inline)
COPY nginx.frontend.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
```

#### `frontend/nginx.frontend.conf` (within the frontend container for standalone testing)

```nginx
server {
    listen 80;
    root /var/www/frontend;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### `.env.example` (Root — shared across services)

```bash
# ── Database ──────────────────────────────────────────────────────────
DB_NAME=buddyup
DB_USER=buddyup
DB_PASSWORD=changeme

# ── Django ────────────────────────────────────────────────────────────
SECRET_KEY=change-me-to-a-long-random-string
DEBUG=False
ALLOWED_HOSTS=buddyup.app,api.buddyup.app
CORS_ALLOWED_ORIGINS=https://buddyup.app

# ── Redis ─────────────────────────────────────────────────────────────
REDIS_PASSWORD=changeme

# ── Cloudinary ────────────────────────────────────────────────────────
CLOUDINARY_URL=cloudinary://api_key:api_secret@cloud_name

# ── Email ─────────────────────────────────────────────────────────────
SENDGRID_API_KEY=SG.xxxxx

# ── SMS / M-Pesa ──────────────────────────────────────────────────────
AFRICASTALKING_USERNAME=buddyup
AFRICASTALKING_API_KEY=atsk_xxxxx
MPESA_CONSUMER_KEY=xxxxx
MPESA_CONSUMER_SECRET=xxxxx
MPESA_SHORTCODE=174379
MPESA_PASSKEY=xxxxx
MPESA_CALLBACK_URL=https://api.buddyup.app/api/v1/payments/mpesa/callback/

# ── Payments ──────────────────────────────────────────────────────────
STRIPE_SECRET_KEY=sk_live_xxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxx
FLUTTERWAVE_SECRET_KEY=FLWSECK_xxxxx

# ── Live Streaming ────────────────────────────────────────────────────
AGORA_APP_ID=xxxxx
AGORA_APP_CERTIFICATE=xxxxx
MUX_TOKEN_ID=xxxxx
MUX_TOKEN_SECRET=xxxxx

# ── AI ────────────────────────────────────────────────────────────────
OPENAI_API_KEY=sk-xxxxx

# ── AWS (Content Moderation) ──────────────────────────────────────────
AWS_ACCESS_KEY_ID=xxxxx
AWS_SECRET_ACCESS_KEY=xxxxx
AWS_DEFAULT_REGION=us-east-1

# ── Firebase (Push Notifications) ────────────────────────────────────
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account",...}

# ── KYC ───────────────────────────────────────────────────────────────
SMILE_IDENTITY_API_KEY=xxxxx
SMILE_IDENTITY_PARTNER_ID=xxxxx

# ── Monitoring ────────────────────────────────────────────────────────
SENTRY_DSN=https://xxxxx@sentry.io/xxxxx

# ── Frontend (Vite — prefix VITE_ for client exposure) ───────────────
VITE_API_BASE_URL=https://api.buddyup.app/api/v1
VITE_WS_BASE_URL=wss://api.buddyup.app
VITE_AGORA_APP_ID=xxxxx
VITE_GOOGLE_MAPS_KEY=xxxxx
VITE_CLOUDINARY_CLOUD_NAME=xxxxx
VITE_FIREBASE_CONFIG={"apiKey":"...","projectId":"...",...}
```

#### `Makefile` (Root — developer convenience commands)

```makefile
.PHONY: dev prod build logs shell-backend shell-frontend migrate seed test lint

# ── Development ───────────────────────────────────────────────────────
dev:
	docker compose up --build

dev-d:
	docker compose up --build -d

# ── Production ────────────────────────────────────────────────────────
prod:
	docker compose -f docker-compose.prod.yml up --build -d

prod-down:
	docker compose -f docker-compose.prod.yml down

# ── Build ─────────────────────────────────────────────────────────────
build:
	docker compose build --no-cache

# ── Logs ──────────────────────────────────────────────────────────────
logs:
	docker compose logs -f

logs-backend:
	docker compose logs -f backend

logs-celery:
	docker compose logs -f celery-worker celery-beat

# ── Shell access ──────────────────────────────────────────────────────
shell-backend:
	docker compose exec backend python manage.py shell_plus

shell-db:
	docker compose exec db psql -U buddyup -d buddyup_dev

shell-redis:
	docker compose exec redis redis-cli

# ── Django management ─────────────────────────────────────────────────
migrate:
	docker compose exec backend python manage.py migrate

migrations:
	docker compose exec backend python manage.py makemigrations

seed:
	docker compose exec backend python manage.py seed_dev_data

superuser:
	docker compose exec backend python manage.py createsuperuser

collectstatic:
	docker compose exec backend python manage.py collectstatic --noinput

# ── Testing ───────────────────────────────────────────────────────────
test-backend:
	docker compose exec backend pytest --reuse-db -v

test-frontend:
	docker compose exec frontend npm run test

test-e2e:
	docker compose exec frontend npm run test:e2e

# ── Linting ───────────────────────────────────────────────────────────
lint-backend:
	docker compose exec backend ruff check . && mypy .

lint-frontend:
	docker compose exec frontend npm run lint && npm run type-check

lint: lint-backend lint-frontend

# ── Cleanup ───────────────────────────────────────────────────────────
down:
	docker compose down

clean:
	docker compose down -v --remove-orphans
	docker system prune -f
```

#### Project Root Structure

```
buddyup/                          ← C:\Users\Imani\Documents\Buddy-Up\
├── backend/                      ← Django project
│   ├── apps/
│   ├── config/
│   ├── common/
│   ├── requirements/
│   │   ├── base.txt
│   │   ├── development.txt
│   │   └── production.txt
│   ├── manage.py
│   ├── Dockerfile
│   └── .env.example
│
├── frontend/                     ← React + TypeScript + Vite
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   ├── nginx.frontend.conf
│   ├── vite.config.ts
│   ├── tailwind.config.ts
│   ├── tsconfig.json
│   └── package.json
│
├── nginx/                        ← Reverse proxy config (prod)
│   ├── nginx.conf
│   └── ssl/                      ← SSL certs (gitignored)
│
├── docker-compose.yml            ← Development stack
├── docker-compose.prod.yml       ← Production stack
├── Makefile                      ← Developer convenience commands
├── .env.example                  ← All environment variable templates
├── .env                          ← Local dev secrets (gitignored)
├── .env.prod                     ← Production secrets (gitignored)
├── .gitignore
└── README.md                     ← Full setup instructions
```

#### `README.md` Requirements

The README must include:
1. Project overview and architecture diagram (ASCII)
2. Prerequisites: Docker Desktop 24+, Docker Compose v2, Node 20 (for local frontend without Docker), Python 3.12 (for local backend without Docker)
3. **Quick start:** `git clone → cp .env.example .env → make dev` — platform running in 3 commands
4. Full environment variable documentation (what each variable is, where to get it)
5. How to run tests (backend + frontend + E2E)
6. How to create a superuser and access Django admin (`/admin/`)
7. Database migrations workflow
8. How to seed development data (`make seed`)
9. Production deployment guide (Railway and VPS options)
10. Troubleshooting: common Docker issues, port conflicts, Redis connection errors

### 16.2 Backend App Structure

```
/backend
├── config/
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   ├── urls.py
│   ├── asgi.py
│   └── wsgi.py
│
├── apps/
│   ├── accounts/         # User model, auth, JWT, KYC, age verification
│   ├── profiles/         # Profile model, buddy relationships, follows, blocks
│   ├── feed/             # Post model, reactions, comments, reposts, stories/moments
│   ├── gyms/             # Gym model, membership, roles, gym feed, gym wallet
│   ├── lives/            # Live session model, Random Drop matching, scheduling, replays
│   ├── sessions/         # PT session booking, escrow, trainer availability
│   ├── messaging/        # DMs, group chats, Django Channels consumers
│   ├── marketplace/      # Meal plans, programmes, supplements, products
│   ├── wallet/           # Artifacts, transactions, withdrawals, revenue splits
│   ├── notifications/    # Notification model, push dispatch, email dispatch
│   ├── moderation/       # Reports, content flags, moderation queue, audit logs
│   ├── verification/     # KYC queue, document review, badge management
│   ├── ai/               # Meal plan personalisation pipeline, recommendation engine
│   └── analytics/        # Creator analytics, platform metrics (admin)
│
├── common/
│   ├── models.py         # Abstract base models (TimestampedModel, SoftDeleteModel)
│   ├── permissions.py    # IsVerifiedTrainer, IsGymOwner, IsBuddy, IsAdult etc.
│   ├── pagination.py     # CursorPagination (feed), PageNumberPagination (lists)
│   ├── exceptions.py     # Consistent error envelope
│   └── utils.py          # Phone formatter, artifact calculator, age checker
│
├── requirements/
│   ├── base.txt
│   ├── development.txt
│   └── production.txt
│
├── manage.py
├── Dockerfile
├── docker-compose.yml
└── .env.example
```

### 16.3 Core Models (Key Schema)

```python
# accounts/models.py
class User(AbstractBaseUser, PermissionsMixin):
    id = UUIDField(primary_key=True, default=uuid4)
    email = EncryptedEmailField(unique=True)
    phone = EncryptedCharField(max_length=20, null=True, blank=True)
    phone_verified = BooleanField(default=False)
    email_verified = BooleanField(default=False)
    dob_hash = CharField(max_length=64)       # SHA-256 of YYYY-MM-DD
    is_adult = BooleanField(default=False)    # Set on registration after age check
    is_active = BooleanField(default=True)
    is_staff = BooleanField(default=False)
    deleted_at = DateTimeField(null=True)
    deletion_type = CharField(choices=['user','moderation'], null=True)
    created_at = DateTimeField(auto_now_add=True)
    last_login_ip = GenericIPAddressField(null=True)
    consent_log = JSONField(default=dict)     # {tos_v: "2.1", consented_at: ISO}

class Profile(TimestampedModel):
    user = OneToOneField(User, primary_key=True)
    username = CharField(max_length=30, unique=True)
    display_name = CharField(max_length=50)
    bio = CharField(max_length=200, blank=True)
    avatar_url = CharField(blank=True)
    cover_url = CharField(blank=True)
    pronouns = CharField(max_length=30, blank=True)
    location_city = CharField(max_length=100, blank=True)
    location_country = CharField(max_length=100, blank=True)
    role = CharField(choices=['user','trainer','practitioner'], default='user')
    is_anonymous_posting = BooleanField(default=False)
    show_active_status = BooleanField(default=True)
    streak_days = IntegerField(default=0)
    streak_last_activity = DateField(null=True)
    artifact_balance = JSONField(default=dict)  # {"dumbbell": 5, "barbell": 2, ...}
    verification_status = CharField(choices=['none','id','trainer','practitioner'])
    privacy_level = CharField(choices=['public','private'], default='public')

# profiles/models.py
class BuddyRelationship(TimestampedModel):
    from_user = ForeignKey(Profile, related_name='buddy_sent')
    to_user = ForeignKey(Profile, related_name='buddy_received')
    status = CharField(choices=['pending','confirmed','declined'])
    class Meta:
        unique_together = ('from_user', 'to_user')

class FollowRelationship(TimestampedModel):
    follower = ForeignKey(Profile, related_name='following')
    followee = ForeignKey(Profile, related_name='followers')
    class Meta:
        unique_together = ('follower', 'followee')

# feed/models.py
class Post(TimestampedModel, SoftDeleteModel):
    id = UUIDField(primary_key=True, default=uuid4)
    author = ForeignKey(Profile, on_delete=CASCADE)
    post_type = CharField(choices=['text','photo','short_video','long_video',
                                   'workout_log','meal','progress','moment'])
    body = TextField(blank=True)
    is_anonymous = BooleanField(default=False)
    gym_tag = ForeignKey('gyms.Gym', null=True, blank=True)
    visibility = CharField(choices=['public','buddies','gym_members','private'])
    is_repost = BooleanField(default=False)
    original_post = ForeignKey('self', null=True, blank=True)
    quote_body = TextField(blank=True)  # for quote reposts
    location_label = CharField(blank=True)
    workout_log_data = JSONField(null=True)
    meal_data = JSONField(null=True)
    media_urls = ArrayField(CharField(), default=list)
    tags = ArrayField(CharField(), default=list)
    view_count = IntegerField(default=0)
    moderation_status = CharField(choices=['clean','flagged','removed','reviewed'])

# gyms/models.py
class Gym(TimestampedModel, SoftDeleteModel):
    id = UUIDField(primary_key=True, default=uuid4)
    name = CharField(max_length=60, unique=True)
    handle = CharField(max_length=60, unique=True)
    description = TextField(blank=True)
    logo_url = CharField(blank=True)
    cover_url = CharField(blank=True)
    category = CharField(max_length=50)
    access_type = CharField(choices=['public','private','secret'])
    subscription_type = CharField(choices=['free','members_free','paid','tiered'])
    monthly_fee_artifacts = JSONField(null=True)  # {artifact_type: amount}
    join_fee_artifacts = JSONField(null=True)
    wallet_balance = JSONField(default=dict)
    is_verified = BooleanField(default=False)
    rules = ArrayField(TextField(), default=list)
    tags = ArrayField(CharField(), default=list)
    member_count = IntegerField(default=0)

class GymMembership(TimestampedModel):
    gym = ForeignKey(Gym, on_delete=CASCADE)
    member = ForeignKey(Profile, on_delete=CASCADE)
    role = CharField(choices=['owner','co_owner','trainer','moderator','member','guest'])
    subscription_active = BooleanField(default=True)
    subscription_expires_at = DateTimeField(null=True)
    class Meta:
        unique_together = ('gym', 'member')

# lives/models.py
class BuddyLive(TimestampedModel):
    id = UUIDField(primary_key=True, default=uuid4)
    host = ForeignKey(Profile, on_delete=CASCADE)
    title = CharField(max_length=80)
    live_type = CharField(choices=['open_sweat','buddy_circle','gym_live',
                                   'pt_session_live','random_drop','practitioner_live'])
    category = CharField(max_length=50)
    access = CharField(choices=['public','buddies','gym_members'])
    artifact_fee = JSONField(null=True)
    gym = ForeignKey(Gym, null=True, blank=True)
    status = CharField(choices=['scheduled','live','ended'])
    started_at = DateTimeField(null=True)
    ended_at = DateTimeField(null=True)
    viewer_peak = IntegerField(default=0)
    replay_url = CharField(blank=True)
    replay_saved = BooleanField(default=False)
    agora_channel = CharField(max_length=100, blank=True)
    mux_asset_id = CharField(blank=True)
    co_hosts = ManyToManyField(Profile, blank=True, related_name='co_hosted_lives')
    scheduled_for = DateTimeField(null=True)
    is_recurring = BooleanField(default=False)
    recurrence_rule = CharField(blank=True)  # RRULE format

# wallet/models.py
class ArtifactTransaction(TimestampedModel):
    id = UUIDField(primary_key=True, default=uuid4)
    user = ForeignKey(Profile, on_delete=CASCADE)
    transaction_type = CharField(choices=['purchase','tip_sent','tip_received',
                                          'live_fee','gym_subscription','session_fee',
                                          'marketplace','withdrawal','platform_cut',
                                          'refund','bonus'])
    artifact_type = CharField(max_length=30)
    quantity = IntegerField()
    direction = CharField(choices=['credit','debit'])
    counterparty = ForeignKey(Profile, null=True, blank=True, related_name='tx_counterparty')
    reference_id = CharField(max_length=100, blank=True)  # session ID, live ID, etc.
    status = CharField(choices=['pending','completed','failed','refunded'])
    fiat_amount = DecimalField(max_digits=10, decimal_places=2, null=True)
    fiat_currency = CharField(max_length=5, default='KES')
    payment_provider = CharField(blank=True)  # stripe, mpesa, flutterwave
    clearance_at = DateTimeField(null=True)  # when earnings become withdrawable
```

### 16.4 API Design

All endpoints: `/api/v1/` prefix. JSON response envelope:
```json
{
  "success": true,
  "data": { ... },
  "message": "OK",
  "errors": null,
  "pagination": { "count": 100, "next": "...", "previous": null }
}
```

**Key API Groups:**
```
AUTH:         /api/v1/auth/ (register, login, refresh, verify-otp, logout)
PROFILES:     /api/v1/profiles/ (search, retrieve, update, follow, buddy, block)
FEED:         /api/v1/feed/ (home, following, nearby, post CRUD, reactions, comments, reposts, saves)
STORIES:      /api/v1/moments/ (create, view, expire, highlights)
GYMS:         /api/v1/gyms/ (CRUD, join, leave, membership, schedule, roles)
LIVES:        /api/v1/lives/ (start, end, join, schedule, replay, random-drop-match)
SESSIONS:     /api/v1/sessions/ (book, cancel, reschedule, availability, review)
MESSAGING:    /api/v1/messaging/ (conversations, messages — REST fallback; WS primary)
MARKETPLACE:  /api/v1/marketplace/ (meal-plans, programmes, supplements, products, purchase)
WALLET:       /api/v1/wallet/ (balance, buy-artifacts, send, withdraw, transactions)
NOTIFICATIONS:/api/v1/notifications/ (list, mark-read, preferences)
MODERATION:   /api/v1/moderation/ (report, appeal)
VERIFICATION: /api/v1/verification/ (submit, status)
ANALYTICS:    /api/v1/analytics/ (creator dashboard data)
AI:           /api/v1/ai/ (personalise-meal-plan, recommend-buddies)
```

### 16.5 WebSocket Channels

```
ws/user/{user_id}/          → Global user channel (notifications, presence, DM alerts)
ws/conversation/{id}/       → DM thread (messages, read receipts, typing)
ws/typing/{convo_id}/       → Typing indicator (separate, lightweight)
ws/live/{live_id}/          → Live session events (viewer count, reactions, chat, rep counter)
ws/gym-chat/{gym_id}/       → Gym group chat
ws/random-drop/             → Random drop matching pool (connect → receive "room found" event)
```

### 16.6 Celery Background Tasks

```python
# Scheduled
generate_feed_cache.delay()                  # Every 5 min: pre-compute For You feeds
expire_moments.delay()                       # Every hour: remove 24h-old moments
check_streaks.delay()                        # Daily midnight: update streak counts
send_streak_reminder.delay()                 # Daily 6 PM: ping users who haven't logged yet
clear_expired_sessions.delay()               # Hourly: release held escrow for no-shows
generate_gym_schedule_notifications.delay()  # Daily: prepare 15-min-before live notifications
refresh_artifact_exchange_rates.delay()      # Weekly: update fiat equivalents

# Event-triggered
send_otp.delay(user_id, channel)
process_payment.delay(transaction_id)
process_withdrawal.delay(withdrawal_id)
export_user_data.delay(user_id)              # On data export request
delete_user_data.delay(user_id)              # On hard deletion (30 days after request)
notify_buddy_request.delay(from_id, to_id)
personalise_meal_plan.delay(user_id, plan_id) # Calls AI pipeline
process_live_replay.delay(live_id)           # After live ends, if saved
send_verification_decision.delay(user_id)    # After admin reviews KYC
```

---

## ✅ SECTION 17: FINAL AGENT INSTRUCTIONS

1. **Age gate is absolute.** The DOB check must be server-side enforced, not just client-side. Store the hashed DOB. Any user with a confirmed age under 16 must be permanently blocked with no recovery path, no "try again", no alternative.

2. **The Buddy system is the social graph.** Build `BuddyRelationship` and `FollowRelationship` as separate models from day one. Do not conflate following and buddying — they have different permission implications (DMs, shared accountability) and different UI states.

3. **Artifact economy is the payment layer.** Never store raw artifact balances as a single number. Use `JSONField` (`{"dumbbell": 5, "barbell": 2}`) so each artifact type is tracked separately and can be displayed with its icon. All financial transactions go through the `ArtifactTransaction` model — no direct balance mutations.

4. **Lives architecture is two-tier.** Random Drop (up to 15 people) uses WebRTC peer-to-peer (Agora's low-latency mode). Large Gym Lives and PT Sessions use Agora's CDN broadcasting mode (RTMP → HLS) for scale. The frontend must detect which mode to use based on the `live_type` field.

5. **Random Drop matching is time-windowed.** The matching pool is a Redis sorted set keyed by `activity_type:timestamp`. The Celery worker runs every 30 seconds to scan the pool, group compatible users, create a `BuddyLive` record with `live_type=random_drop`, assign them to an Agora channel, and broadcast the channel name to each matched user via their personal WebSocket channel. The frontend listens on `ws/random-drop/` and auto-navigates to the live when the match is found.

6. **Content moderation before publish.** All image and video uploads must pass through the NSFW classifier before being marked `published`. Set a `moderation_status` field with values: `pending` (in queue) → `clean` (auto-pass) / `flagged` (human review queue) / `removed`. The post is visible to the author in "pending" state but not to others until `clean`.

7. **Moments (Stories) must expire cleanly.** Implement a Celery periodic task (`expire_moments`) that runs every hour. Expired moments are soft-deleted from the feed but their media URLs remain accessible for 7 days (for highlights). Hard delete media from Cloudinary after 7 days via another Celery task.

8. **Escrow is non-negotiable for sessions.** The artifact deduction at booking must be stored in a `status=held` transaction, not credited to the trainer until 1 hour after session end. If a dispute is opened, the held funds are frozen until resolution. Never credit the trainer at booking time.

9. **AI meal plan personalisation is a background job.** Never call the LLM synchronously in a request cycle. When a user requests personalisation, create a task record (`status=processing`), return immediately, and process via Celery. Push the result to the user via WebSocket when complete. Show a "Personalising your plan…" state on the frontend.

10. **Verified badges are profile-level, not post-level.** The badge is shown on the profile and alongside usernames in the feed, live sessions, and comments — but it is stored on the `Profile.verification_status` field and propagated via serialisation. Do not duplicate badge logic in each feature.

11. **Privacy defaults are conservative.** New accounts are `private` by default for the first 24 hours, then auto-switch to `public` unless the user set it themselves. Buddy requests are accepted manually (no auto-accept). DMs are buddy-only (no overrides in the free tier).

12. **Gym revenue split is automated.** When a gym subscription payment is made, the platform's 20% cut is immediately taken and logged as a separate `platform_cut` transaction. The 80% is credited to the gym wallet. Co-owner distribution is only processed when a withdrawal is requested — not at payment time.

13. **The landing page is independent.** The landing page at `/` is a standalone React component tree (or separate Next.js micro-frontend if separate SEO domain is desired) — it should not depend on auth state or any authenticated API. It must load in < 2 seconds on 4G mobile. Use a CDN-hosted static export.

14. **The Community Guidelines, Terms of Service, and Privacy Policy must be real documents** — not placeholder text. Write them in full using the key provisions in Section 12 as the source. They must be versioned (e.g., v1.0), with a `last_updated` date. Store the version number; log which version a user consented to at registration.

15. **Accessibility is non-negotiable.** WCAG AA minimum everywhere. All fitness artifact icons must have descriptive `aria-label` attributes (e.g., "Dumbbell token — 1 token = $0.10 USD"). All live sessions must have a live caption option (real-time speech-to-text overlay). All videos must support subtitles.

---

*End of Prompt — BuddyUp Platform*
*Version 1.0*
*Target directory: C:\Users\Imani\Documents\Buddy-Up\buddyup_platform_prompt.md*
*Stack: React 18 + TypeScript + Vite | Django 5 + DRF | Django Channels | PostgreSQL | Redis | Celery | Agora.io | Mux | Cloudinary | Stripe + M-Pesa + Flutterwave*
*Age restriction: 16+ strictly enforced*














AI Models Needed (8 identified):
1. Workout Form Analyzer — computer vision for exercise form feedback (HIGH priority)
2. Food Recognition & Nutrition AI — photo-to-calories/macros (HIGH)
3. Content Moderation AI — NSFW + hate speech detection (MEDIUM)
4. Feed Ranking Engine — ML-powered personalisation (MEDIUM)
5. Trainer-Buddy Matching — recommendation algorithm (MEDIUM)
6. Meal Plan Personalisation (LLM) — GPT-4o integration (MEDIUM)
7. Workout Log Analysis — progression + plateau detection (LOW-MEDIUM)
8. Health Insights Engine — cross-domain NLG summaries (LOW)
