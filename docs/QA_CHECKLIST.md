# QA Checklist

## Table of contents

* [Home `/`](#home-)
* [Movies index `/movies`](#movies-index-movies)
* [Series index `/series`](#series-index-series)
* [Search `/search?q=`](#search-searchq)
* [Movie details `/movie/:id`](#movie-details-movieid)
* [Series details `/tv/:id`](#series-details-tvid)
* [People hub `/people`](#people-hub-people)
* [Person profile `/person/:id`](#person-profile-personid)
* [Companies hub `/companies`](#companies-hub-companies)
* [Company page `/company/:id`](#company-page-companyid)
* [Favorites `/favorites` and Watchlist `/watchlist` *(if present)*](#favorites-favorites-and-watchlist-watchlist-if-present)
* [Settings `/settings`](#settings-settings)
* [Certifications](#certifications)
* [Countries & Regions](#countries--regions)
* [Global behaviors (nav, language, theme, errors, a11y, perf)](#global-behaviors)

> **Test data prep (suggested):**
>
> * Create fixtures for: a popular movie with trailer, a movie without trailer, a series with 3 seasons and mixed missing images, a person with long biography, a person with no biography, a company with 20+ titles, and at least one 404-style missing entity.
> * Include genres, countries, images (poster/backdrop/profile), and a few titles with future/invalid dates for validation.

---

## Home `/`

**Blocks:** "of the moment" movies, "of the moment" series, carousels/rows

**Happy path**

* [ ] Movies rail shows at least 10 cards; each card: poster, title, rating/year visible.
* [ ] Series rail shows at least 10 cards; same visual guarantees.
* [ ] Clicking any card opens the correct details page.
* [ ] Horizontal scroll works with mouse, touch, and keyboard.
* [ ] Reaching rail end shows next batch or disables navigation affordances.

**Filtering & toggles**

* [ ] Switching sections (movies ↔ series) updates content without layout jump.
* [ ] Remembered section after navigation away/back (scroll and tab state persist).

**Edge cases**

* [ ] When results < rail size: arrows hidden and no empty gaps.
* [ ] When API returns empty set: friendly empty state with retry link.
* [ ] Missing poster: placeholder image + title text still readable.

**Loading & errors**

* [ ] Skeletons appear while fetching and disappear cleanly.
* [ ] Temporary network error: non-blocking banner + retry works.
* [ ] Fatal error: compact error state; header/footer remain usable.

**A11y**

* [ ] Cards reachable via keyboard; visible focus; Enter opens details.
* [ ] Announce section headings for screen readers.
* [ ] Images have useful alternative text or are marked decorative.

**Perf**

* [ ] First content appears within acceptable time on slow connection.
* [ ] Rail scrolling does not stutter with 50+ items loaded.

---

## Movies index `/movies`

**Blocks:** filter bar, sort, grid, pagination/infinite

**Happy path**

* [ ] Default list shows popular or recent items with consistent card layout.
* [ ] Filters (genre, year, country, rating) apply cumulatively.
* [ ] Sort toggles between release date, popularity, rating.

**Interactions**

* [ ] Changing filters doesn't reset scroll unexpectedly.
* [ ] Clearing filters returns to default results.
* [ ] "Show more" or infinite scroll loads next batch exactly once per threshold.

**Edge cases**

* [ ] No results for filter combo → clear empty state + "Reset filters".
* [ ] Invalid year input (future/past extremes) handled gracefully.
* [ ] Items with missing poster/title still render accessible cards.

**Loading & errors**

* [ ] Filter updates show compact, non-blocking loading state inside grid.
* [ ] Network error during paging → inline retry at the end of list.

**A11y & Perf**

* [ ] Filter controls operable by keyboard, labeled, and grouped.
* [ ] Long lists (200+ items paged) remain responsive; images load lazily.

---

## Series index `/series`

(Repeat the checklist from Movies index with TV-specific data.)

* [ ] Filters and sorts reflect TV attributes (first air date, etc.).
* [ ] Long-running and limited series display correctly.

---

## Search `/search?q=`

**Blocks:** search input, suggestions (if present), grouped results

**Happy path**

* [ ] Typing a query shows suggestions (if present) within reasonable delay.
* [ ] Submitting searches returns grouped results: movies, series, people, companies.
* [ ] "View all" per group navigates to scoped lists (or extends the group).

**Edge cases**

* [ ] Empty query → prompt user to type; no crash.
* [ ] No results → clear empty state + hints (e.g., try other keywords).
* [ ] Special characters, multi-word queries, mixed case → consistent behavior.

**Loading & errors**

* [ ] Progress feedback while searching; results don't flicker.
* [ ] Network failure → preserved query, retry affordance.

**A11y & Perf**

* [ ] Input has accessible label and announcement for result counts.
* [ ] Debounced typing avoids excessive calls while staying responsive.

---

## Movie details `/movie/:id`

**Blocks:** hero, core facts, overview, genres/countries, cast, crew, trailers, gallery, recommendations, productions

**Happy path**

* [ ] Hero shows poster/backdrop; title, release year, rating, runtime appear.
* [ ] Overview visible and doesn't exceed max lines on small screens.
* [ ] Genres and countries rendered as chips/badges.
* [ ] Cast carousel shows headshots and roles; clicking opens person page.
* [ ] Crew highlights include director/writer when available.
* [ ] Trailer section shows at least one playable link if provided.
* [ ] Productions block shows logos/names; clicking opens company page.
* [ ] Recommendations/similar titles present; cards link correctly.

**Edge cases**

* [ ] No trailer → section omitted or note shown, no dead controls.
* [ ] No cast/crew → hide section headings to avoid empty blocks.
* [ ] Missing images → placeholders without layout shift.
* [ ] Long titles/taglines → wrap without overlap; tooltips optional.
* [ ] Budget/revenue present or absent without breaking layout.

**Loading & errors**

* [ ] Progressive load: base details first, then secondary blocks.
* [ ] Individual block error (e.g., gallery) isolated; page remains usable.

**A11y & Perf**

* [ ] Logical heading order; landmarks for main/content.
* [ ] Carousels operable via keyboard.
* [ ] Media thumbnails lazy-load; trailer click doesn't block back navigation.

---

## Series details `/tv/:id`

**Additional blocks:** seasons, episodes per season

**Happy path**

* [ ] Seasons list: poster, season name/number, year, episode count.
* [ ] Selecting a season reveals episodes with name, number, runtime, air date.
* [ ] Cast/crew, trailers, gallery, recommendations work as on movies.

**Edge cases**

* [ ] Missing episode runtimes/stills → display gracefully.
* [ ] Specials/season 0 appear correctly if present.
* [ ] Long series (10+ seasons) render with stable performance.

---

## People hub `/people`

**Blocks:** grid of trending people, basic filters

**Happy path**

* [ ] Grid shows at least 20 people with portrait, name, known-for items.
* [ ] Clicking card opens person profile.

**Edge cases**

* [ ] Missing portrait → placeholder silhouette.
* [ ] Name truncation on small screens remains readable.

**A11y & Perf**

* [ ] Cards focusable with Enter to open profile.
* [ ] Scrolling remains smooth with 100+ entries via paging.

---

## Person profile `/person/:id`

**Blocks:** portrait, biography, vitals, credits (movies/series), photos

**Happy path**

* [ ] Portrait present; name prominent.
* [ ] Biography collapses/expands if long; default to readable length.
* [ ] Vitals (birthday, place of birth) shown when available.
* [ ] Credits grouped by role and media type; cards link back to details.
* [ ] Photos gallery opens full-size view or dedicated gallery screen.

**Edge cases**

* [ ] No biography → omit section/title; page still feels complete.
* [ ] Mixed roles (actor, director) → groups labeled clearly.
* [ ] Duplicate credit entries are merged/deduped visually.

**A11y & Perf**

* [ ] Biography section labeled; "Show more/less" buttons accessible.
* [ ] Large credit lists paginate or virtualize to stay responsive.

---

## Companies hub `/companies`

**Blocks:** grid of companies, filters (name, country)

**Happy path**

* [ ] Grid shows logos, names, origin country.
* [ ] Clicking opens company page.

**Edge cases**

* [ ] No logo → neutral placeholder.
* [ ] Filters narrow results and can be cleared quickly.

---

## Company page `/company/:id`

**Blocks:** header (logo, name, origin), description, produced titles

**Happy path**

* [ ] Header shows logo or placeholder plus company name.
* [ ] Description renders (if available) with safe line length.
* [ ] Produced titles include both movies and series, with filters (genre/year).

**Edge cases**

* [ ] No description → header flows directly into produced list.
* [ ] Very large catalogs (200+ titles) remain usable via paging/infinite.

---

## Favorites `/favorites` and Watchlist `/watchlist` *(if present)*

**Blocks:** local collections, bulk actions, sorting

**Happy path**

* [ ] Mark/unmark from cards and details updates the collections instantly.
* [ ] Collections show poster, title, type (movie/series), and quick actions.
* [ ] Sorting by date added, title, year.

**Edge cases**

* [ ] Empty collection → friendly prompt explaining how to add items.
* [ ] Cross-device: if local only, collections are device-specific and this is communicated.

**Resilience**

* [ ] Data persists across reloads.
* [ ] Removing items is immediate and reversible (undo or confirm).

---

## Settings `/settings`

**Blocks:** language, theme

**Happy path**

* [ ] Changing language updates all visible text without reload.
* [ ] Theme switch updates visuals; preference persists across sessions.

**Edge cases**

* [ ] Localized fields missing from content → fallback text (e.g., English) used seamlessly.
* [ ] Returning to app later preserves selections.

**A11y**

* [ ] Controls labeled and reachable; state changes are announced.

---

## Certifications

**Blocks:** locale selector, certification badges, explanations, filters, warnings

**Happy path**

* [ ] Movie certification badges display the correct rating for the active country (e.g., US: G, PG, PG-13, R, NC-17).
* [ ] TV content ratings surface the expected set (TV-Y, TV-G, TV-PG, TV-14, TV-MA) and match the title metadata.
* [ ] Selecting or focusing a certification reveals an explanation with clear age guidance.

**Filtering**

* [ ] Certification filters appear on applicable movie/series listings and narrow results to matching titles.
* [ ] Clearing a certification filter restores the previous list without dropping other active filters.

**Edge cases**

* [ ] Titles missing certification display a neutral fallback (e.g., "NR") without breaking layout or interactions.
* [ ] Changing country/localization swaps the certification set while preserving equivalent selections when possible.
* [ ] Conflicting certification data (multiple regions, movie vs. TV) resolves predictably or prompts for a choice.

**Warnings & A11y**

* [ ] Age-appropriate content warnings (violence, language, etc.) accompany restrictive certifications with icon + text.
* [ ] Certification badges, warnings, and explanations expose accessible names/labels and are not color-only indicators.
* [ ] Closing an explanation modal/sheet returns focus to the trigger element.

---

## External links

**General behavior**

* [ ] External link chips/buttons appear only when the corresponding URL exists; no empty placeholders.
* [ ] Links open in the platform-appropriate browser/web view with HTTPS enforced; failures surface a retry/toast without leaving the screen.
* [ ] Icons and labels match the destination (IMDb, TVDB, etc.) and expose accessible names.
* [ ] Share/deep-link flows include the canonical route and append external IDs when required.

**IMDb integration**

* [ ] Movie and series details surface an IMDb chip or badge when `imdb_id` exists, displaying rating when provided.
* [ ] Tapping the IMDb link opens the correct title/person page; fallback copy states when the ID is missing.

**Official website**

* [ ] Official site link shows the readable domain and opens in a new tab/web view.
* [ ] Malformed or http-only URLs are sanitized or rejected gracefully.

**Social profiles**

* [ ] Facebook, Twitter, and Instagram links use branded icons, open the native app when available, and otherwise open in browser.
* [ ] Links with locale/path suffixes remain valid; missing profiles are hidden without leaving gaps.

**TV-specific directories**

* [ ] TV detail pages surface TVDB and TVRage chips when IDs exist, linking to the correct show page.
* [ ] Requests for missing or deprecated IDs fail silently without blocking other links.

**Wikidata integration**

* [ ] Wikidata link points to the correct entity ID and opens in browser.
* [ ] Long entity labels truncate with tooltip/title attribute for desktop readers.

**Deep link sharing**

* [ ] "Share" exposes app-specific deep links (e.g., `allmovies://movie/:id`) plus web fallback.
* [ ] Opening a deep link lands on the expected screen with preloaded data.
* [ ] Invalid deep links surface an error state without crashing the app.

---

## Countries & Regions

**Blocks:** production country directory, regional filters, release schedules, watch providers, localized certifications, timezone awareness

**Production countries list**

* [ ] Country directory enumerates 195+ production countries with localized names and ISO codes for searching/filtering.
* [ ] Search, quick-jump, and keyboard navigation work across the full list without lag or skipped entries.
* [ ] Each country shows a flag or neutral badge; missing assets fall back cleanly without broken icons.

**Regional content filtering**

* [ ] Movie/series indexes expose a region filter that limits results to titles available or produced in the selected country/region.
* [ ] Applying a region filter preserves other active filters and sorts, and updates counts without layout jump.
* [ ] Clearing the region filter restores the prior dataset while keeping scroll position intact.

**Country-specific releases**

* [ ] Release timelines highlight theatrical/digital dates per country, grouped chronologically with timezone-adjusted labels.
* [ ] Switching countries refreshes release data and clearly indicates when information is unavailable.
* [ ] Staggered releases surface the next upcoming date for the selected region with fallback messaging for past events.

**Regional watch providers**

* [ ] Watch provider lists reflect the providers available in the chosen country with correct logos and plan types (stream/rent/buy).
* [ ] Provider links deep-link to country-specific destinations; providers not operating in the region are hidden.
* [ ] Changing the country triggers a fresh fetch to avoid mixing provider data between regions.

**Regional certifications**

* [ ] Certification pickers load the rating sets associated with the active country and keep equivalent choices when swapping locales (e.g., US ↔ CA).
* [ ] Detail cards and filters display the correct badge/description for the selected region; unsupported regions show a neutral fallback.
* [ ] Multi-region views label which certification belongs to which territory to avoid ambiguity.

**Timezone support**

* [ ] Release countdowns and "available now" badges respect the viewer's local timezone while showing the origin region (e.g., "Premieres in 5h (Tokyo)").
* [ ] Date/time strings format according to the active locale and handle daylight saving transitions correctly.
* [ ] Cache updates or retries never show stale times after the user changes timezone or locale.

---

## Global behaviors

**Navigation & layout**

* [ ] Header links always reachable; current section highlighted.
* [ ] Back/forward browser navigation restores scroll and filter states.
* [ ] Deep links (copy/paste a details URL) render the correct page fully.

**Language & translations**

* [ ] Language selector lists 40+ options; current locale is highlighted and persists across sessions.
* [ ] Switching language updates interface chrome plus localized titles, taglines, synopses, and other translatable content.
* [ ] Details pages surface the original language when it differs from the selected locale.
* [ ] Video player (or equivalent) advertises accurate subtitle language availability with counts matching the API.
* [ ] Audio track selector exposes all delivered languages, defaults sensibly, and falls back gracefully when missing.
* [ ] Browsing and search views offer a language filter that scopes results and resets cleanly.

**Errors**

* [ ] 404 unknown route → branded "not found" page with navigation back.
* [ ] Entity missing (movie/person/company) → targeted not-found state.

**Accessibility (core)**

* [ ] Pages have unique titles; landmarks used consistently.
* [ ] Contrast meets recommended ratios in both themes.
* [ ] Focus is visible and not trapped; modals/galleries return focus on close.
* [ ] Extended accessibility checklist reviewed (`docs/ACCESSIBILITY_GUIDE.md`).

**Performance**

* [ ] Images lazy-load; no layout shift when they appear.
* [ ] Lists load incrementally; memory stays stable after prolonged browsing.
* [ ] Repeated navigation benefits from cached data without stale content surprises.

---

### Bonus: Acceptance criteria template (reuse per test)

* [ ] **Pre-conditions:** describe test data and route.
* [ ] **Action:** user steps.
* [ ] **Expectation:** exact UI outcome (text, counts, visibility).
* [ ] **Visuals:** no overlap/wrap issues on small screens.
* [ ] **A11y:** keyboard/screen reader behavior verified.
* [ ] **Perf:** interaction completes within acceptable time on slow connection.

---

If you want, I can convert this into:

* a **GitHub issue set** (one issue per route with the checklists prefilled), or
* a **CSV/Excel** test plan you can hand to QA with owner/severity columns.
