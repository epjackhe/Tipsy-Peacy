# First Sip – Technical Design Document

## Product North Star

Help guests walk into any bar, understand what a drink tastes like, and get confident, personalized recommendations—while giving bars tools to publish accurate specs and learn what guests actually enjoy.

## Taste Model

We represent each drink with a 6-axis radar (0–5) capturing:
- Sweet, Sour, Spirit (boozy), Umami, Bitter, Aroma
We selected Bitter and Aroma to disambiguate amaro- or tonic-forward drinks and capture nose-driven perception. Future versions may add Fruitiness or Body.

## Data Ingestion & Menu Parsing

1. Capture sources:
   - OCR on device (e.g., Vision framework) then LLM parsing for name, price, ingredients, descriptors.
   - Server OCR for PDFs/links/screenshots.
   - Crowdsourcing via user-submitted menus.
   - Direct entry via bar owner portal.

2. Normalize ingredients:
   - Map to canonical database entries (e.g., “Lime” → “Fresh lime juice”, “Cynar 70” → “Cynar (ABV 35%)”).
   - Store method, glassware, ice, garnish.

3. Confidence scoring:
   - Each field includes a source and confidence flag (OCR / LLM / Owner / Staff-verified).

## Turning Recipes into Taste Profiles

- Build a base contribution table per ingredient with expected deltas for each axis, scaled by volume, ABV, sugar, acid, bitter index, and aromatic or smoked flags.
- Apply technique modifiers (Shake increases aroma, decreases perceived spirit; Stir preserves clarity and spirit; Carbonation lifts aroma and reduces perceived sweetness).
- Normalize the resulting vector to [0,5]^6.
- Calculate ABV in glass and map to the Spirit axis.
- Classic cocktails serve as curated gold standards with higher weight.

## Closest Classic Matching

- Use cosine similarity between vectors to identify top 3 classic cocktails.
- Present these in the UI with an overlay radar chart and a “why” explanation chip (e.g., “Close to Daiquiri due to high Sour/medium Sweet/low Bitter”).

## Personalization & Recommendations

- Build a user taste vector from favorites, skips, check-ins, and explicit feedback (“less bitter”, “more aroma”).
- Cold start onboarding quiz uses mini radars to gauge preferences.
- When at a new venue, rank menu items by similarity to the user vector and show explanatory chips.
- Context-aware suggestions consider time of day, weather, party size, and optional constraints like low-ABV or dietary restrictions.

## Bar Owner & Bartender Portal

- Manage menus, specs, batch notes, glassware, pricing, and 86’d status.
- Define the official taste vector and override computed values if needed.
- Manage variants (e.g., spec v1 vs spec v2).
- View insights about guest ordering patterns and axis heatmaps.
- Each bar page lists signature cocktails with radars, bartender credits, and events; printed menus include QR codes linking to taste previews and feedback forms.
- Staff-verified specs earn a badge to inspire confidence.

## User Experience Flows

- Scan a menu → parse items → tap drink → view radar → toggle overlay → see closest classic → save/favorite.
- “Recommendations” tab shows ranked menu items at a new bar, with mini-radars and tasting notes.
- Classic library organized by family (Sours, Old Fashioned, Highballs) includes canonical specs and radars.
- Users can filter by low-ABV, zero-proof, sweetness ≤ 2, bitterness ≥ 3, price ≤ $.
- Map view highlights nearby bars with a match score.

## Technical Architecture

### iOS

- SwiftUI + Combine; CoreData for offline cache.
- Vision for on-device OCR; Core ML for on-device parsing and fallback taste inference.
- MapKit + CoreLocation; background tasks refresh nearby bar data.
- Sign in with Apple; Keychain for tokens.
- Custom radar chart built with SwiftUI.

### Backend

- API built with FastAPI or Node/TypeScript, exposing GraphQL endpoints.
- PostgreSQL with pgvector to store taste and user embeddings.
- Meilisearch or OpenSearch for full-text search across venues and menus.
- Worker pipeline handles OCR, parsing, deduping, geocoding, and quality checks.
- Vector store for taste and user vectors.
- JWT authentication with rate limiting via Redis.
- S3 for storing menus and images.
- LLM jobs for parsing and normalization with prompt templates and guardrails.
- Owner portal built with Next.js and tRPC/GraphQL.

## Data Model (High Level)

- Venue(id, name, address, geo, hours, claimed_by, tags)
- Menu(id, venue_id, date, src_type, confidence)
- Drink(id, menu_id?, venue_id, name, price, method, glass, status)
- Spec(id, drink_id, version, ingredients list, ml/oz per component, garnish, technique)
- TasteProfile(id, owner_type: system|owner, vector[6], source, confidence)
- Classic(id, family, canonical_spec_id, vector[6])
- User(id, prefs, restrictions)
- UserAction(user_id, drink_id, action: fav|skip|rate, axis_feedback?)
- Bartender(id, name, socials) ↔ Drink (credits)

## Algorithms & Evaluation

- Taste inference: Sum of ingredient contributions plus technique modifiers, clamp to 0–5.
- Similarity: Use cosine similarity, optionally allow user-weighted axes.
- Recommendation: Hybrid of content-based (taste vectors) and popularity priors; expand with collaborative filtering later.
- Quality metrics include menu parse accuracy, spec completeness, match click-through rate, return rate (“kept drinking”), and axis-level user satisfaction.

## Privacy & Safety

- Use location only when necessary; no sale of data.
- Apply differential privacy to analytics.
- Moderate user-generated content and provide reporting flows.
- Clearly label whether a radar is computed or bar-verified.

## MVP Scope (8–10 weeks)

1. Launch a classics library with accurate specs and radars.
2. Support manual bar entries without OCR.
3. Implement closest classic overlay and favorites saving.
4. Offer basic recommendations at one venue using the favorites-derived taste vector.
5. Provide a simple owner portal where venues can claim their page, set specs, and tweak taste vectors.

## Phase 2

- Add OCR + LLM pipeline to ingest menus.
- Display map and nearby bars, with push notifications for best matches tonight.
- Create bartender pages with events and trending cocktails.
- Add wine and beer modules with dryness and IBU axes.

## AI Tool Responsibilities

- OCR module: Detect drink blocks, price, descriptors and output JSON.
- Parser LLM: Normalize ingredients to canonical IDs, infer method and glass, output confidence.
- Taste estimator: Compute the 6-axis vector and per-axis explanations (e.g., “lime → +2.0 Sour”).
- Similarity service: Accept vector, return closest classics with distances.
- Recommendation engine: Accept user and venue vectors, return a ranked list with “because” reasons.
