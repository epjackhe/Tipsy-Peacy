# Product North Star

Help a guest walk into any bar, **understand what a drink tastes like**, and get **confident, personalized recommendations**—while giving bars tools to publish accurate specs and learn what guests actually enjoy.

# Taste Model (the foundation)

* **6 radar axes (0–5):**
  **Sweet, Sour, Spirit (boozy), Umami** + **Bitter, Aroma**.

  * *Why these two:* Bitter disambiguates amaro/tonic/peel/bitters-heavy builds; Aroma captures nose-driven experiences from citrus oils, herbs, smoke, barrel notes—huge for perceived flavor without bumping sweetness.
* Optional alternates if you want 8 later: **Fruitiness** and **Body/Richness**.

# Data Ingestion & Menu Parsing

1. **Capture sources**

   * Camera: on-device OCR (Vision) → LLM parsing (drink name, price, ingredients, descriptors).
   * Links/PDFs/screenshots: server OCR + parser.
   * Crowdsource: users upload menus; dup-detector merges to venue canonical.
   * Bar Portal: owners maintain live specs.
2. **Normalize ingredients**

   * Map to canonical db (e.g., “Lime” → “Fresh lime juice”, “Cynar 70” → “Cynar (ABV 35%)”).
   * Store method (shake/stir/flash), glass, ice, garnish.
3. **Confidence scoring**

   * Each field tagged `source` + `confidence` (OCR|LLM|Owner|Staff-verified).

# Turning Recipes into Taste Profiles (math, not vibes)

* **Base contributions table** per ingredient with expected deltas on each axis (0–5), scaled by **amount**, **ABV**, **sugar g/oz**, **acid g/oz**, **bittering index**, **glossary flags** (aromatic, smoked, herbal).
* **Technique modifiers**: Shake (+aroma lift, -spirit perception), Stir (+clarity, +spirit), Carbonation (+aroma, -perceived sweetness).
* **Normalization**: final vector ∈ \[0,5]^6.
* **ABV-in-glass** computed from volumes/dilution to inform the **Spirit** axis.
* **Classic cocktails**: curated specs = gold standard vectors (higher weight).

# “Closest Classic” Matching

* Compute similarity using **cosine similarity** (default) with optional **weighted Euclidean** (user-weighted axes).
* Show top-3 classics; one-tap **overlay** toggle on the radar chart.
* Expose “why” chip: “Close to **Daiquiri** due to high Sour/medium Sweet/low Bitter.”

# Personalization & Recommendations

* **User taste vector** learned from: favorites, skips, dwell, check-ins, thumbs-up on axes (“less bitter”, “more aroma”).
* **Cold start**: 60‑second quiz with mini-radars (“Pick your vibe”).
* **At a new bar**: match menu vectors to user vector → **ranked recommendations**; explainability chips (“Because you liked Paper Plane”).
* **Context-aware**: time of day, weather, party size; optional constraints (low-ABV, no egg, dairy-free).

# For Bar Owners / Bartenders

* **Owner Portal**

  * Manage menus, precise specs, batch/prep notes, glassware, pricing, 86’d status.
  * Set the official radar (override or tweak computed).
  * **Variant management** (spec v1 vs v2; seasonal).
  * **Insights**: what guests with X profile order, conversion vs rival drinks, heatmaps by axis.
* **Bar Page in app**

  * Signature list with radars, bartender credits (your “star bartender” concept), events (pop-ups, collabs).
  * QR on printed menu → “Preview taste” + private feedback to bar.
* **Verification workflow**: staff-verified specs get a badge; boosts confidence in recommendations.

# Core UX Flows

* **Scan Menu → Parsed List → Tap Drink → Radar (+overlay toggle) → “Closest Classic” → Save/Favorite.**
* **At New Bar → Recommended Tab** (cards with mini‑radars + two‑sentence tasting note).
* **Classic Library**: browse by family (Sours, Old Fashioned variants, Highballs); each has canonical spec + radar.
* **Filter chips**: Low-ABV, Zero‑proof, Sweetness ≤ 2, Bitter ≥ 3, Price ≤ \$\$.
* **Map view**: nearby bars with “your-match score.”

# Visual/Interaction Details

* **Hex radar** (0–5 rings), crisp labels; overlay uses two contrasting fills, opacity 40%.
* Axis tooltips with examples (“Bitter = Campari, gentian, peels”).
* **Haptics** when toggling overlays; smooth spring animation on radar morph.
* **Accessibility**: numeric badges under radar for color‑blind users.

# Technical Architecture (iOS + Backend)

**iOS**

* **SwiftUI** + **Combine**; **CoreData** for offline menu cache.
* **Vision** for OCR; **Core ML** for on-device menu parsing (light LLM distill) & taste inference fallback.
* **MapKit** + **CoreLocation**; **BackgroundTasks** to refresh nearby bar data.
* **Sign in with Apple**; **Keychain** for tokens.
* Chart: custom SwiftUI radar or **Charts**-based polygon.

**Backend**

* **API**: FastAPI or Node (TypeScript) + GraphQL for flexible queries.
* **DB**: Postgres (+ **pgvector** for embeddings & similarity).
* **Search**: Meilisearch/Opensearch for venue/menu text search.
* **Workers**: menu OCR→parse pipeline, dedupe, geocoding, quality checks.
* **Vector store**: store taste vectors + user vectors.
* **Auth**: JWT; rate limiting with Redis.
* **Storage**: S3-compatible for menus/images.
* **LLM jobs**: menu parsing & ingredient normalization; prompt templates + guardrails.
* **Owner Portal**: Next.js + tRPC/GraphQL; role-based access, venue-claim flow.

# Data Model (high level)

* **Venue**(id, name, address, geo, hours, claimed\_by, tags)
* **Menu**(id, venue\_id, date, src\_type, confidence)
* **Drink**(id, menu\_id?, venue\_id, name, price, method, glass, status)
* **Spec**(id, drink\_id, version, ingredients\[list], ml/oz per component, garnish, technique)
* **TasteProfile**(id, owner\_type: system|owner, vector\[6], source, confidence)
* **Classic**(id, family, canonical\_spec\_id, vector\[6])
* **User**(id, prefs, restrictions)
* **UserAction**(user\_id, drink\_id, action: fav|skip|rate, axis\_feedback?)
* **Bartender**(id, name, socials) ↔ **Drink** (credits)

# Algorithms & Evaluation

* **Taste Inference**: Σ(ingredient\_i \* weight\_i) + technique modifiers → clamp to 0–5.
* **Similarity**: cosine; allow per-axis weights from user/profile.
* **RecSys**: hybrid of content-based (taste vectors) + popularity priors; later add collaborative filtering.
* **Quality metrics**: menu parse accuracy, spec completeness, match CTR, “kept drinking” rate, user satisfaction per axis.

# Privacy & Safety

* Location only on “near me” screens; no sale of data; differential privacy for analytics.
* UGC moderation on photos/notes; report flow.
* Clear labeling when a radar is **computed** vs **bar-verified**.

# MVP Scope (8–10 weeks)

1. **Classics library** with accurate specs + radars.
2. **Manual bar entries** (no OCR yet) + computed radars.
3. **Closest Classic** overlay + favorite/save.
4. **Basic Rec at one venue** from favorites-derived taste vector.
5. **Owner Portal v0**: claim venue, set specs, tweak radar.

# Phase 2

* OCR + LLM menu pipeline, PDF/url ingest.
* Map + nearby bars; push “Tonight’s best matches.”
* Bartender pages + events; trending cocktails.
* Wine/beer sliders (dryness/IBU) if you want that section.

# What AI tools will do (explicit requirements)

* **OCR stage**: detect drink blocks, price, descriptors; emit JSON.
* **Parser LLM**: normalize ingredients to canonical ids, infer method/glass, produce uncertainty.
* **Taste Estimator**: given normalized spec, output the 6‑axis vector with per‑axis explanation tokens (“lime→+Sour 2.0”).
* **Similarity Service**: given vector, return closest classics w/ distances.
* **Rec Engine**: given user vector + venue menu vectors, return ranked list; include “because” reasons.

Keep this format and update.
