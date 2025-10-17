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
The snippets below assume the existing Laravel 12 + MySQL stack from `goleaf/omdbapibt.prus.dev`. The migrations, models, seeders, and indexes are structured to minimise disruption—existing core user/auth tables remain intact while new recommendation-specific structures are additive.

### 2.1 Migrations
#### `database/migrations/2024_05_15_000100_create_films_table.php`
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('films', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('original_title')->nullable();
            $table->unsignedSmallInteger('year')->nullable()->index();
            $table->json('countries')->nullable();
            $table->json('languages')->nullable();
            $table->unsignedSmallInteger('runtime')->nullable();
            $table->text('synopsis')->nullable();
            $table->string('poster_url')->nullable();
            $table->string('trailer_url')->nullable();
            $table->date('release_date')->nullable()->index();
            $table->json('credits')->nullable();
            $table->json('providers')->nullable();
            $table->json('external_ids')->nullable();
            $table->boolean('hidden')->default(false);
            $table->string('flag_reason')->nullable();
            $table->foreignId('updated_by')->nullable()->constrained('users');
            $table->timestamps();

            $table->fullText(['title', 'original_title', 'synopsis'], 'films_ft_title_synopsis');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('films');
    }
};
```

#### `database/migrations/2024_05_15_000200_create_genres_and_pivot.php`
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('genres', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->unique();
            $table->json('name_i18n')->nullable();
            $table->timestamps();
        });

        Schema::create('film_genre', function (Blueprint $table) {
            $table->foreignId('film_id')->constrained('films')->cascadeOnDelete();
            $table->foreignId('genre_id')->constrained('genres')->cascadeOnDelete();
            $table->primary(['film_id', 'genre_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('film_genre');
        Schema::dropIfExists('genres');
    }
};
```

#### `database/migrations/2024_05_15_000300_create_tags_and_pivot.php`
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tags', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->unique();
            $table->json('name_i18n')->nullable();
            $table->enum('type', ['user', 'system'])->default('system');
            $table->boolean('hidden')->default(false);
            $table->string('flag_reason')->nullable();
            $table->foreignId('updated_by')->nullable()->constrained('users');
            $table->timestamps();
        });

        Schema::create('film_tag', function (Blueprint $table) {
            $table->id();
            $table->foreignId('film_id')->constrained('films')->cascadeOnDelete();
            $table->foreignId('tag_id')->constrained('tags')->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->float('weight')->default(1.0);
            $table->timestamps();

            $table->unique(['film_id', 'tag_id', 'user_id'], 'film_tag_unique_assignment');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('film_tag');
        Schema::dropIfExists('tags');
    }
};
```

#### `database/migrations/2024_05_15_000400_create_ratings_table.php`
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ratings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('film_id')->constrained('films')->cascadeOnDelete();
            $table->unsignedTinyInteger('rating')->nullable();
            $table->boolean('liked')->nullable();
            $table->timestamp('rated_at')->useCurrent();
            $table->timestamps();

            $table->unique(['user_id', 'film_id']);
            $table->index(['film_id', 'rated_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ratings');
    }
};
```

#### `database/migrations/2024_05_15_000500_create_interactions_table.php`
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('interactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('film_id')->constrained('films')->cascadeOnDelete();
            $table->enum('event', ['view', 'click', 'wishlist']);
            $table->float('value')->default(1.0);
            $table->timestamp('occurred_at')->useCurrent();
            $table->timestamps();

            $table->index(['user_id', 'occurred_at']);
            $table->index(['film_id', 'event']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('interactions');
    }
};
```

#### `database/migrations/2024_05_15_000600_create_lists_tables.php`
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('lists', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->boolean('public')->default(true);
            $table->text('description')->nullable();
            $table->string('cover_url')->nullable();
            $table->boolean('hidden')->default(false);
            $table->string('flag_reason')->nullable();
            $table->foreignId('updated_by')->nullable()->constrained('users');
            $table->timestamps();

            $table->index(['user_id', 'public']);
        });

        Schema::create('list_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('list_id')->constrained('lists')->cascadeOnDelete();
            $table->foreignId('film_id')->constrained('films')->cascadeOnDelete();
            $table->unsignedInteger('position')->default(0);
            $table->timestamps();

            $table->unique(['list_id', 'film_id']);
            $table->index(['list_id', 'position']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('list_items');
        Schema::dropIfExists('lists');
    }
};
```

#### `database/migrations/2024_05_15_000700_create_follows_table.php`
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('follows', function (Blueprint $table) {
            $table->id();
            $table->foreignId('follower_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('followee_id')->constrained('users')->cascadeOnDelete();
            $table->timestamp('created_at')->useCurrent();

            $table->unique(['follower_id', 'followee_id']);
            $table->index('followee_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('follows');
    }
};
```

#### `database/migrations/2024_05_15_000800_create_recommendations_table.php`
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('recommendations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('algo');
            $table->foreignId('film_id')->constrained('films')->cascadeOnDelete();
            $table->float('score');
            $table->json('rerank_reason')->nullable();
            $table->timestamp('generated_at')->useCurrent();
            $table->timestamps();

            $table->unique(['user_id', 'algo', 'film_id'], 'recommendations_unique_triplet');
            $table->index(['user_id', 'algo', 'generated_at'], 'recommendations_user_algo_generated');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('recommendations');
    }
};
```

### 2.2 Eloquent Models
Each model keeps relationships tight while relying on casts for JSON fields.

#### `app/Models/Film.php`
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Film extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'original_title',
        'year',
        'countries',
        'languages',
        'runtime',
        'synopsis',
        'poster_url',
        'trailer_url',
        'release_date',
        'credits',
        'providers',
        'external_ids',
        'hidden',
        'flag_reason',
        'updated_by',
    ];

    protected $casts = [
        'countries' => 'array',
        'languages' => 'array',
        'credits' => 'array',
        'providers' => 'array',
        'external_ids' => 'array',
        'hidden' => 'boolean',
        'release_date' => 'date',
    ];

    public function genres()
    {
        return $this->belongsToMany(Genre::class);
    }

    public function tags()
    {
        return $this->belongsToMany(Tag::class)->withPivot(['user_id', 'weight'])->withTimestamps();
    }

    public function ratings()
    {
        return $this->hasMany(Rating::class);
    }
}
```

#### `app/Models/Genre.php`
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Genre extends Model
{
    use HasFactory;

    protected $fillable = ['slug', 'name_i18n'];

    protected $casts = [
        'name_i18n' => 'array',
    ];

    public function films()
    {
        return $this->belongsToMany(Film::class);
    }
}
```

#### `app/Models/Tag.php`
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Tag extends Model
{
    use HasFactory;

    protected $fillable = [
        'slug',
        'name_i18n',
        'type',
        'hidden',
        'flag_reason',
        'updated_by',
    ];

    protected $casts = [
        'name_i18n' => 'array',
        'hidden' => 'boolean',
    ];

    public function films()
    {
        return $this->belongsToMany(Film::class)->withPivot(['user_id', 'weight'])->withTimestamps();
    }
}
```

#### `app/Models/Rating.php`
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rating extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'film_id',
        'rating',
        'liked',
        'rated_at',
    ];

    protected $casts = [
        'liked' => 'boolean',
        'rated_at' => 'datetime',
    ];

    public function film()
    {
        return $this->belongsTo(Film::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
```

#### Additional Models
`Interaction`, `MovieList` (for `lists`), `ListItem`, `Follow`, and `Recommendation` follow the same pattern—fillable properties and relationships that connect to `Film` and `User`.

### 2.3 Seeders
Provide deterministic bootstrap data for genres, tags, and a demo list.

#### `database/seeders/GenreSeeder.php`
```php
<?php

namespace Database\Seeders;

use App\Models\Genre;
use Illuminate\Database\Seeder;

class GenreSeeder extends Seeder
{
    public function run(): void
    {
        $genres = [
            ['slug' => 'action', 'name_i18n' => ['en' => 'Action', 'ru' => 'Боевик']],
            ['slug' => 'drama', 'name_i18n' => ['en' => 'Drama', 'ru' => 'Драма']],
            ['slug' => 'sci-fi', 'name_i18n' => ['en' => 'Science Fiction', 'ru' => 'Научная фантастика']],
        ];

        foreach ($genres as $genre) {
            Genre::updateOrCreate(['slug' => $genre['slug']], $genre);
        }
    }
}
```

#### `database/seeders/TagSeeder.php`
```php
<?php

namespace Database\Seeders;

use App\Models\Tag;
use Illuminate\Database\Seeder;

class TagSeeder extends Seeder
{
    public function run(): void
    {
        $tags = [
            ['slug' => 'must-watch', 'name_i18n' => ['en' => 'Must Watch', 'ru' => 'Обязательно к просмотру'], 'type' => 'system'],
            ['slug' => 'family', 'name_i18n' => ['en' => 'Family', 'ru' => 'Семейный'], 'type' => 'system'],
        ];

        foreach ($tags as $tag) {
            Tag::updateOrCreate(['slug' => $tag['slug']], $tag);
        }
    }
}
```

#### `database/seeders/RecommendationDemoSeeder.php`
```php
<?php

namespace Database\Seeders;

use App\Models\Film;
use App\Models\Recommendation;
use App\Models\User;
use Illuminate\Database\Seeder;

class RecommendationDemoSeeder extends Seeder
{
    public function run(): void
    {
        $user = User::first();
        $film = Film::first();

        if ($user && $film) {
            Recommendation::updateOrCreate(
                ['user_id' => $user->id, 'algo' => 'hybrid', 'film_id' => $film->id],
                ['score' => 0.95, 'rerank_reason' => ['novelty' => 0.1]]
            );
        }
    }
}
```

Update the project `DatabaseSeeder` to call the new seeders:
```php
public function run(): void
{
    $this->call([
        GenreSeeder::class,
        TagSeeder::class,
        RecommendationDemoSeeder::class,
    ]);
}
```

### 2.4 Indexing and Query Optimisation Notes
- `films` full-text index (`films_ft_title_synopsis`) powers BM25-style search.
- Composite indices for `ratings`, `list_items`, `recommendations` enforce uniqueness and speed up dashboard queries.
- Faceted filtering uses `year`, `release_date`, JSON path queries (`countries`, `languages`) with generated columns if needed.
- Consider MySQL 8.0 virtual columns such as `generated column \\`primary_country\\`` for frequent facets; add after initial rollout to keep migration minimal.

### 2.5 Data Validation Rules (Laravel Form Requests)
```php
'rating' => ['nullable', 'integer', 'between:1,10'],
'liked' => ['nullable', 'boolean'],
'year' => ['nullable', 'integer', 'between:1888,' . (now()->year + 1)],
'runtime' => ['nullable', 'integer', 'between:1,600'],
'countries' => ['nullable', 'array'],
'countries.*' => ['string', 'size:2'],
'languages' => ['nullable', 'array'],
'languages.*' => ['string', 'size:2'],
```

### 2.6 Horizon & Queue Touchpoints
- Rating/list/tag mutations dispatch jobs to update hybrid recommendation caches stored in `recommendations`.
- Queue workers refresh user embeddings and item similarities; results hydrate the `score` and `rerank_reason` payloads.

### 2.7 Minimal Integration Steps
1. Drop the snippets into the Laravel project (migrations, models, seeders).
2. Run `php artisan migrate` then `php artisan db:seed`.
3. Point the recommendation engine jobs to read/write against the defined tables.
4. Add Nova/Filament/Horizon dashboards for moderation toggles using the `hidden` & `flag_reason` audit fields.

This single document now couples the end-to-end product specification with a concrete Laravel data model ready to be merged into `goleaf/omdbapibt.prus.dev`.
