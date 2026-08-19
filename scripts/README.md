# Scripts

## `regenerate-exercises.mjs`

Regenerates lesson exercises for Spanish + French (A1–C1) via Claude Sonnet
4.6, constraining every generated exercise to use only the vocabulary
already taught in that lesson (or earlier lessons in the same section, as
review). Never crosses topic boundaries.

Defaults to **dry-run**. Live writes require `--live` AND
`SUPABASE_SERVICE_ROLE_KEY` in the environment.

### Prerequisites

`.env.local` must contain:

```
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
ANTHROPIC_API_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...   # only required for --live
```

### Dry-run a single section

```
node --env-file=.env.local scripts/regenerate-exercises.mjs \
  --language spanish --level A1 --section greetings --verbose
```

Calls the Anthropic API and prints what would be written. Nothing hits the
database.

### Live regeneration

```
node --env-file=.env.local scripts/regenerate-exercises.mjs \
  --language spanish --level A1 --live
```

Deletes existing exercises per lesson and inserts the newly generated
ones. Progress is logged to `scripts/.regeneration-progress.json` after
every successful lesson — re-running with the same flags picks up where
the last run left off.

### Full flag list

See the header comment at the top of `regenerate-exercises.mjs`.

### Cost + rate notes

- One Sonnet-4.6 call per lesson. System prompt is cached (5-minute TTL,
  refreshed by every hit), so the batch cost is dominated by per-lesson
  input + output tokens.
- Runs one lesson at a time with a 400ms pause between calls (`--sleep-ms`
  to tune). No parallelism yet — bump later if needed.
- On 429 / 5xx / 529 the script backs off exponentially (up to 5
  attempts) before giving up on that lesson.
