# Movie Recommendation Platform — Unified Specification and Data Model Blueprint

## 1. Functional Specification (Translated Technical Brief)

### 1.1 Goal and Scope
- Aggregate user taste signals to produce personalised movie recommendations.
- Signals: 1–10 ratings, likes/dislikes, user & system tags, genres, views, list membership, clicks, card dwell time.
- Deliverables: personalised feeds, faceted search, movie detail pages, user profiles, social taste graph.
- Out of scope: push notifications, mini-games, data export workflows.

### 1.2 Registration & Authentication
- Support email/password (minimum 12 chars), OAuth (Google, GitHub, Apple) and guest mode promoted to full accounts via cookie upgrade.
- Email verification & password reset flows guarded by rate limiting and Turnstile/ReCAPTCHA.
- Profile fields: nickname, avatar, country, interface language, time zone, favourite genres (multi-select).

### 1.3 Taste Onboarding (Cold Start)
- Step 1: pick 3–5 favourite genres.
- Step 2: rapid-fire scoring of ~30 popular films (score 1–10 or skip).
- Output: initialise preference vector (genres, tags, latent factors) and candidate pool.

### 1.4 Data Model (Minimum Viable Entities)
- `users(id, email, hash, nick, locale, tz, country, created_at, ...)`
- `films(id, title, original_title, year, countries[], languages[], runtime, synopsis, poster_url, trailer_url, release_date, credits(json: directors[], writers[], cast[]), providers(json), external_ids(imdb, tmdb,...), created_at, ...)`
- `genres(id, slug, name_i18n_json)`; `film_genre(film_id, genre_id)`
- `tags(id, slug, name_i18n_json, type ENUM[user,system])`; `film_tag(film_id, tag_id, user_id NULLABLE, weight)`
- `ratings(user_id, film_id, rating INT 1..10, liked BOOL, rated_at)`
- `interactions(user_id, film_id, event ENUM[view,click,wishlist], value FLOAT, ts)`
- `lists(id, user_id, title, public BOOL, description, cover_url, created_at)`; `list_items(list_id, film_id, position)`
- `follows(follower_id, followee_id, created_at)`
- `recommendations(user_id, algo, film_id, score, rerank_reason JSON, generated_at)`
- Indices: unique `(user_id, film_id)` for `ratings` and `list_items`; full-text search on titles/synopsis/people; filtering facets (year, countries, genres).
- Audit fields: `hidden BOOL`, `flag_reason`, `updated_by`.

### 1.5 Movie Ingestion & Quality
- Import from TMDb/OMDb/CSV with person normalisation (ISO country/language codes).
- Deduplicate by external IDs and fuzzy "title + year" heuristics.
- Poster/trailer fallbacks.
- Validation: year in `1888..current+1`; runtime in `1..600` minutes.
- Card & tag moderation surfaces.

### 1.6 Scores, Reviews, Tags, Lists
- Ratings 1–10 plus like/dislike (mapped to pseudo-ratings).
- Reviews up to 10k characters with anti-spam, reporting, moderator hide.
- Tags: autocomplete, merge duplicates, fully localised labels.
- Lists: public/private, ordered positions, subscription to other users' lists.

### 1.7 Search & Filtering
- Quick search on title/original title/person names.
- Advanced filters: years, genres (multi), countries, languages, runtime, aggregate rating, streaming providers, "not watched", "coming soon".
- Sorting: relevance, recommended, year, popularity, average rating, novelty.
- Suggest popular queries and remember recent local queries.

### 1.8 Movie Detail Page
- Poster, trailer, metadata (genres/countries/runtime/release), synopsis, cast/crew, "where to watch", site-wide aggregate rating, similar titles, reviews, tags.
- Actions: rate, like, add to list, mark as watched.
- Similarity via embeddings + shared tags/genres.
- Optimistic UI updates.

### 1.9 Social Layer
- Follow users; profile shows ratings, lists, favourite genres/tags, taste overlap.
- Taste match = Pearson correlation of overlapping ratings (clipped to `[0, 100]`).
- Comments, reporting, moderator hiding.

### 1.10 Recommendation Algorithms (Condensed)
1. **Signal Normalisation**
   ```
   R*_{u,i} = \begin{cases}
      r_{u,i} \\
      \tilde r_{u,i} \\
      \mu_u + b_i & \text{if only implicit view}
   \end{cases}
   ```
   Likes ≈ 8.5, dislikes ≈ 3.0, views weighted by dwell time.
2. **User-kNN**
   ```
   \hat r_{u,i}= \mu_u + \frac{\sum sim(u,v) (R*_{v,i}-\mu_v)}{\sum |sim(u,v)|}
   ```
3. **Item-kNN**
   ```
   \hat r_{u,i}= \mu_i + \frac{\sum sim(i,j) (R*_{u,j}-\mu_j)}{\sum |sim(i,j)|}
   ```
4. **Bias Terms** solved via regularised MSE.
5. **Taste Match**: Pearson `\rho(A,B)` over shared ratings, `match = max(0, \rho) * 100%`.
6. **Content Model**: `e_i = [TFIDF(tags)||TFIDF(genres)||d_i(sentence)||persons]`, `p_u = normalize(\sum w_{u,i} e_i)`, score via cosine.
7. **Matrix Factorisation (ALS/SGD)** with implicit confidences `c_{u,i}=1+\alpha\cdot n_{u,i}`.
8. **Hybrid Score**: `s_0 = \sum w_k s_k` tuned by NDCG/Recall.
9. **Genre Calibration**: penalty `KL(dist_{TopN∪{i}} || dist_u)`.
10. **Diversification**: `MMR(i)=\lambda rel - (1-\lambda) \max sim(i,S)`.
11. **Fatigue/Novelty**: `score = s_0 - \alpha_1 penalty_{calib} - \alpha_2 penalty_{fatigue}`.
12. **Cold Start Film**: Bayesian rating shrinkage + content similarity.
13. **Cold Start User**: onboarding genres + popular-in-genre + content expansion.
14. **Online Updates**: event log, incremental kNN, periodic MF retraining, fast warm start for new users.

### 1.11 Feeds
- "Recommended" feed caches `recommendations` per user with 1–6 hour TTL, invalidated on new ratings.
- "Trending" = 7/30 day popular lists with Bayesian correction.
- "New Releases" sorted by release date.
- "Similar" leverages item-item similarity.

### 1.12 Search Relevance
- BM25/full-text with boosts (exact title, popularity, novelty).
- Personalisation: rerank top-M by personalised score while honouring filters.
- Snippets/highlighting, facets for genres/countries/years.

### 1.13 Admin Panel
- CRUD for films/genres/tags/persons/providers.
- Moderate reviews/comments, action log.
- Merge duplicate tags, manage localisation.
- Batch imports with quality reports.
- Monitor NDCG/Recall, recommendation CTR, complaint rates.

### 1.14 UI/UX
- Optimistic updates, 1–10 scale + heart, collapsible filters, quick chips.
- Accessibility compliance, dark/light modes, full i18n.

### 1.15 Performance & Caching
- Cache film cards, similar films, popularity, personalised feeds (short TTL).
- Batch rebuild with priority for active users.
- Index top queries, favour keyset pagination.

### 1.16 Quality & Anti-Spam
- Review scoring, auto-hide, moderation queue.
- Rate limiting for ratings/comments.
- Deduplicate content/tags.

### 1.17 Privacy & Legal
- Private lists excluded from indexing.
- Account deletion: soft delete, async log scrubbing.
- Consent logging.

### 1.18 Quality Metrics
- Offline: RMSE/MAE, Recall@K, NDCG@K.
- Online: CTR, watch-through, rating conversion, dwell time.
- Stability: share of new titles, genre calibration, diversity (Gini/coverage@K).

### 1.19 Testing
- Unit: rating/list/tag logic.
- Integration: film imports, feed assembly.
- Search regression suite with fixed corpus.
- A/B: hybrid weights, MMR λ, Bayesian `C`.

---

## 2. Laravel 12 Data Model Implementation (goleaf/omdbapibt.prus.dev)
The implementation below assumes the existing Laravel 12 + MySQL stack from `goleaf/omdbapibt.prus.dev`. The migrations, models, seeders, and indexes are structured to minimise disruption—existing core user/auth tables remain intact while new recommendation-specific structures are additive.

### 2.1 Database Schema Design

#### Films Table
- Primary entity storing movie metadata
- Fields: id, title, original_title, year, countries (JSON), languages (JSON), runtime, synopsis, poster_url, trailer_url, release_date, credits (JSON), providers (JSON), external_ids (JSON)
- Audit fields: hidden, flag_reason, updated_by
- Full-text index on title, original_title, synopsis for search functionality

#### Genres and Film-Genre Relationship
- Genres table: id, slug, name_i18n (JSON for multilingual support)
- Many-to-many relationship via film_genre pivot table
- Enables faceted filtering and genre-based recommendations

#### Tags and Film-Tag Relationship
- Tags table: id, slug, name_i18n (JSON), type (user/system), audit fields
- Film-tag pivot with user_id (nullable) and weight for user-generated vs system tags
- Supports collaborative tagging and content-based filtering

#### Ratings Table
- User-film ratings with 1-10 scale and boolean like/dislike
- Unique constraint on (user_id, film_id)
- Indexed for efficient recommendation algorithm queries

#### Interactions Table
- Tracks implicit feedback: views, clicks, wishlist additions
- Event type enum with configurable value weights
- Time-series data for temporal recommendation patterns

#### Lists and List Items
- User-created movie lists with public/private visibility
- Ordered list items with position field
- Supports social discovery and curation features

#### Social Features
- Follows table for user-to-user relationships
- Enables taste matching and social recommendations

#### Recommendations Cache
- Pre-computed recommendations per user and algorithm
- Includes score and rerank_reason (JSON) for explainability
- TTL-based invalidation on user activity changes

### 2.2 Model Relationships and Data Access Patterns

#### Film Model
- Relationships to genres, tags, ratings, interactions
- JSON casting for complex fields (countries, languages, credits, providers, external_ids)
- Scopes for filtering by visibility and content flags

#### User Extensions
- Relationships to ratings, lists, follows, recommendations
- Taste profile computation from rating history
- Social graph navigation methods

#### Rating and Interaction Models
- Efficient querying for recommendation algorithms
- Aggregation methods for user and item statistics
- Temporal filtering for recency-based features

### 2.3 Indexing Strategy

#### Search Optimization
- Full-text indexes on film titles and synopsis
- Composite indexes for faceted filtering (year, genre, country)
- JSON path indexes for complex field queries

#### Recommendation Performance
- User-film composite indexes for rating lookups
- Film-genre indexes for content-based filtering
- Temporal indexes on interactions for trend analysis

#### Social Features
- Follow relationship indexes for graph traversal
- List membership indexes for discovery features

### 2.4 Data Validation and Constraints

#### Content Validation
- Year range validation (1888 to current+1)
- Runtime constraints (1-600 minutes)
- ISO country and language code validation
- Rating scale enforcement (1-10)

#### Data Quality
- Duplicate detection via external IDs and fuzzy matching
- Content moderation flags and audit trails
- User-generated content validation and filtering

### 2.5 Caching and Performance Considerations

#### Recommendation Caching
- Pre-computed recommendations with configurable TTL
- Incremental updates on user activity
- Batch processing for inactive users

#### Search Performance
- Query result caching with facet-aware keys
- Popular query suggestion caching
- Search result pagination optimization

#### Content Delivery
- Film metadata caching with CDN integration
- Image and trailer URL optimization
- Localized content serving

### 2.6 Integration Points

#### External Data Sources
- TMDb/OMDb API integration for film metadata
- Streaming provider availability updates
- Person and crew information normalization

#### Queue Processing
- Asynchronous recommendation updates
- Batch import processing
- User activity event processing

#### Monitoring and Analytics
- Recommendation quality metrics tracking
- User engagement analytics
- Content performance monitoring

This data model provides a solid foundation for the movie recommendation platform while maintaining flexibility for future enhancements and optimizations.
