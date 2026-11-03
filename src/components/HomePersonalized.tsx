"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import StreakFlame from "@/components/StreakFlame";
import { FLAG_CODES } from "@/lib/flag-codes";
import { hasTravelPhrasebook } from "@/lib/travel-phrases";
import { useI18n } from "@/components/I18nProvider";
import { getLocalizedLanguageName } from "@/lib/i18n";

// CEFR labels inlined here (vs. imported from learn.ts) because learn.ts
// pulls in supabase/server which only runs in Server Components. This
// file is "use client", so it needs its own copy of the constant.
type CEFRLevel = "A1" | "A2" | "B1" | "B2" | "C1";
const CEFR_LABEL: Record<CEFRLevel, string> = {
  A1: "Beginner",
  A2: "Elementary",
  B1: "Intermediate",
  B2: "Upper-Intermediate",
  C1: "Advanced",
};

// Everything the personalized homepage needs, resolved server-side and
// handed in as a single prop. Kept as plain data (no live DB clients)
// so this component stays a pure client/server component shell.
export interface ActiveLanguageEntry {
  slug: string;
  name: string; // already localized
  countryCode: string;
  currentLevel: CEFRLevel;
  levelCompleted: number;
  levelTotal: number;
  levelPct: number;
  totalCompleted: number;
  totalLessons: number;
  totalXp: number;
  continueHref: string; // deep link to the next Fluency Course lesson
  lastLessonTitle: string | null;
  // Completed Traveler's Course lessons for this language. Drives the
  // Start/Continue Journey CTA copy on the mini-section attached to the
  // bottom of each active language card.
  travelerCompletedCount: number;
}

export interface ExploreLanguageEntry {
  slug: string;
  name: string;
  countryCode: string;
  lessonsTotal: number;
}

// A city the user is in the middle of — used by the "Continue your
// trip" strip at the top of the signed-in homepage.
export interface StartedTripEntry {
  languageSlug: string;
  city: string;
  country: string;
  citySlug: string;
  coverImageUrl: string;
  lessonsTotal: number;
  lessonsCompleted: number;
  nextLessonId: number | null;
  nextLessonTitle: string | null;
  nextLessonLocation: string | null;
}

// Every traveler_courses row the user has NOT started yet, used by
// the "Explore more trips" strip. `lessonsTotal === 0` means content
// isn't seeded yet — the card renders a "Coming soon" badge instead
// of a Start button so users don't land on empty lessons.
export interface ExploreCityEntry {
  languageSlug: string;
  city: string;
  country: string;
  citySlug: string;
  coverImageUrl: string;
  lessonsTotal: number;
  freePreviewCount: number;
}

export interface HomePersonalizedProps {
  displayName: string;
  totalXp: number;
  currentStreak: number;
  longestStreak: number;
  weeklyCount: number;
  weeklyGoal: number;
  trips: StartedTripEntry[];
  exploreCities: ExploreCityEntry[];
  active: ActiveLanguageEntry[];
  explore: ExploreLanguageEntry[];
}

const LEVEL_PILL: Record<CEFRLevel, string> = {
  A1: "bg-emerald-50 text-emerald-700 ring-emerald-200",
  A2: "bg-teal-light text-teal-dark ring-teal/30",
  B1: "bg-amber-50 text-amber-800 ring-amber-200",
  B2: "bg-orange-50 text-orange-800 ring-orange-200",
  C1: "bg-rose-50 text-rose-800 ring-rose-200",
};

function motivationalMessage(streak: number, weekly: number): string {
  if (streak >= 7 && weekly >= 5) return "You're on fire this week — keep it going.";
  if (streak >= 3) return "You're building a real habit. Nice work.";
  if (weekly >= 3) return "Great pace this week. One more today?";
  if (weekly >= 1) return "You've made progress this week — keep the momentum.";
  return "A short session today keeps your streak alive.";
}

export default function HomePersonalized({
  displayName,
  totalXp,
  currentStreak,
  longestStreak,
  weeklyCount,
  weeklyGoal,
  trips,
  exploreCities,
  active,
  explore,
}: HomePersonalizedProps) {
  const { t } = useI18n();
  const dailyPct = Math.min(100, Math.round((weeklyCount / weeklyGoal) * 100));
  return (
    <main className="flex-1">
      {/* Personalized welcome — unchanged. Warm, low-key palette so it
          feels like a continuation. */}
      <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 sm:pt-12 pb-4">
        <div className="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-4">
          <div>
            <p className="text-xs sm:text-sm font-semibold uppercase tracking-[0.15em] text-teal-dark">
              Welcome back
            </p>
            <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-navy tracking-tight mt-1">
              {displayName}
            </h1>
            <p className="text-sm sm:text-base text-navy/60 mt-2 max-w-xl">
              {motivationalMessage(currentStreak, weeklyCount)}
            </p>
          </div>
          <Link
            href="/profile"
            className="inline-flex items-center gap-2 self-start px-4 py-2 text-sm font-medium text-teal-dark bg-white border border-border rounded-full hover:border-teal/40 transition-colors"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.5 20.12a7.5 7.5 0 0115 0" />
            </svg>
            View profile
          </Link>
        </div>
      </section>

      {/* Stats + daily goal — unchanged. */}
      <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-4 pb-6">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
          <div className="bg-white border border-border rounded-2xl px-4 py-4 sm:py-5 shadow-sm">
            <div className="flex items-center gap-3">
              <StreakFlame streak={currentStreak} size="md" iconOnly />
              <div className="min-w-0">
                <p className="text-lg sm:text-2xl font-bold text-navy tabular-nums leading-tight">
                  {currentStreak}
                </p>
                <p className="text-[10px] sm:text-xs uppercase tracking-wider text-navy/50">
                  Day streak
                </p>
              </div>
            </div>
            {longestStreak > currentStreak && (
              <p className="hidden sm:block text-[11px] text-navy/40 mt-2">
                Longest: {longestStreak}
              </p>
            )}
          </div>
          <div className="bg-white border border-border rounded-2xl px-4 py-4 sm:py-5 shadow-sm">
            <div className="flex items-center gap-3">
              <span className="shrink-0 w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-teal-light text-teal-dark flex items-center justify-center">
                <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 16.9 5.8 21.3l2.4-7.4L2 9.4h7.6z" />
                </svg>
              </span>
              <div className="min-w-0">
                <p className="text-lg sm:text-2xl font-bold text-navy tabular-nums leading-tight">
                  {totalXp.toLocaleString()}
                </p>
                <p className="text-[10px] sm:text-xs uppercase tracking-wider text-navy/50">
                  Total XP
                </p>
              </div>
            </div>
          </div>
          <div className="bg-white border border-border rounded-2xl px-4 py-4 sm:py-5 shadow-sm">
            <div className="flex items-center gap-3">
              <span className="shrink-0 w-9 h-9 sm:w-10 sm:h-10 rounded-full bg-peach-light text-amber-700 flex items-center justify-center">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </span>
              <div className="min-w-0">
                <p className="text-lg sm:text-2xl font-bold text-navy tabular-nums leading-tight">
                  {weeklyCount}
                </p>
                <p className="text-[10px] sm:text-xs uppercase tracking-wider text-navy/50">
                  Lessons this week
                </p>
              </div>
            </div>
          </div>
          <div className="bg-gradient-to-br from-teal to-teal-dark text-white rounded-2xl px-4 py-4 sm:py-5 shadow-sm">
            <div className="flex items-center justify-between gap-2">
              <p className="text-[10px] sm:text-xs uppercase tracking-wider text-white/80">
                Weekly lesson goal
              </p>
              <p className="text-xs tabular-nums text-white/80">
                {Math.min(weeklyCount, weeklyGoal)} / {weeklyGoal} lessons
              </p>
            </div>
            <div className="mt-2 w-full h-2 bg-white/25 rounded-full overflow-hidden">
              <div
                className="h-full bg-white rounded-full transition-all duration-500"
                style={{ width: `${dailyPct}%` }}
              />
            </div>
            <p className="mt-2 text-xs sm:text-sm text-white/90">
              {weeklyCount >= weeklyGoal
                ? "Weekly goal reached — nice one!"
                : `${weeklyGoal - weeklyCount} more ${weeklyGoal - weeklyCount === 1 ? "lesson" : "lessons"} to reach your goal this week`}
            </p>
          </div>
        </div>
      </section>

      {/* Continue your trip — top content block for signed-in users
          who have started at least one city. One card per started
          city with a direct Continue link to their next lesson. */}
      {trips.length > 0 && (
        <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-2 pb-6 sm:pb-8">
          <h2 className="text-xl sm:text-2xl font-bold text-navy tracking-tight mb-4 flex items-center gap-2">
            <svg className="w-5 h-5 text-orange-600" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24" aria-hidden>
              <path strokeLinecap="round" strokeLinejoin="round" d="M17.657 16.657L13.414 20.9a2 2 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            {t("home.continueTrip")}
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5">
            {trips.map((trip) => (
              <TripCard key={`${trip.languageSlug}-${trip.citySlug}`} trip={trip} />
            ))}
          </div>
        </section>
      )}

      {/* Explore more trips — ALWAYS rendered when there are unstarted
          cities. Lets users jump into any city they haven't begun yet
          and surfaces newly-added traveler_courses rows automatically.
          Tabs toggle between Spanish and French so a user studying
          both can see every option without hunting around. */}
      {exploreCities.length > 0 && (
        <ExploreTripsSection cities={exploreCities} />
      )}

      {/* Fluency Course — smaller than before, now sits below trips. */}
      {active.length > 0 && (
        <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-2 pb-10">
          <h2 className="text-lg sm:text-xl font-bold text-navy tracking-tight mb-4 flex items-center gap-2">
            <svg className="w-4 h-4 text-teal-dark" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24" aria-hidden>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
            </svg>
            {t("card.fluencyCourse")}
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-5">
            {active.map((lang) => (
              <ActiveLanguageCard key={lang.slug} lang={lang} />
            ))}
          </div>
        </section>
      )}

      {/* Explore row for anything the learner hasn't touched yet. */}
      <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pb-14">
        <div className="flex items-baseline justify-between mb-3">
          <h2 className="text-base sm:text-lg font-bold text-navy tracking-tight">
            Explore more languages
          </h2>
          {explore.length > 0 && (
            <span className="text-xs text-navy/40 tabular-nums">
              {explore.length} available
            </span>
          )}
        </div>
        {explore.length === 0 ? (
          <div className="rounded-2xl border border-dashed border-border bg-white/60 p-6 sm:p-8 text-center">
            <p className="text-2xl sm:text-3xl mb-2" aria-hidden>🌍</p>
            <p className="text-sm sm:text-base font-semibold text-navy">
              You&rsquo;re studying every available language.
            </p>
            <p className="text-xs sm:text-sm text-navy/60 mt-1">
              More coming soon — check back for new courses.
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3 sm:gap-4">
            {explore.map((l) => (
              <Link
                key={l.slug}
                href={`/languages/${l.slug}`}
                className="group flex items-center gap-3 bg-white border border-border rounded-xl p-3 sm:p-4 hover:border-teal/40 hover:shadow-md transition-all"
              >
                <Image
                  src={`https://flagcdn.com/w80/${l.countryCode}.png`}
                  alt={`${l.name} flag`}
                  width={36}
                  height={27}
                  className="rounded-sm object-cover shadow-sm ring-1 ring-black/5 shrink-0"
                />
                <div className="min-w-0 flex-1">
                  <p className="text-sm sm:text-base font-semibold text-navy truncate group-hover:text-teal transition-colors">
                    {l.name}
                  </p>
                  <p className="text-[11px] sm:text-xs text-navy/40">
                    {l.lessonsTotal} lessons
                  </p>
                </div>
                <svg className="w-4 h-4 text-teal/0 group-hover:text-teal transition-colors" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                </svg>
              </Link>
            ))}
          </div>
        )}
      </section>
    </main>
  );
}

// "Explore more trips" strip. Groups unstarted cities by language,
// shows a Spanish/French tab bar when both are present, and includes a
// "See all trips" link that follows the active tab. Cities whose
// lesson count is 0 render a "Coming soon" badge instead of a Start
// button so users can't land in an empty course.
function ExploreTripsSection({ cities }: { cities: ExploreCityEntry[] }) {
  const { t, lang: uiLang } = useI18n();

  // Which languages are represented in the unstarted set. Preserve
  // Spanish → French order; if a new language is added later it slots
  // in alphabetically after the known two.
  const languages = useMemo(() => {
    const seen = new Set<string>();
    const order = ["spanish", "french"];
    const extras: string[] = [];
    for (const c of cities) {
      if (seen.has(c.languageSlug)) continue;
      seen.add(c.languageSlug);
      if (!order.includes(c.languageSlug)) extras.push(c.languageSlug);
    }
    return [
      ...order.filter((s) => seen.has(s)),
      ...extras.sort(),
    ];
  }, [cities]);

  const [activeLang, setActiveLang] = useState<string>(languages[0] ?? "spanish");
  // Guard against the active tab disappearing (e.g. user starts the
  // last Spanish city, now only French remains).
  const effectiveLang = languages.includes(activeLang)
    ? activeLang
    : languages[0] ?? "spanish";

  const visible = cities.filter((c) => c.languageSlug === effectiveLang);
  const seeAllHref = `/learn/${effectiveLang}/travel`;

  return (
    <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-2 pb-10">
      <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-3 mb-4">
        <div className="min-w-0">
          <h2 className="text-xl sm:text-2xl font-bold text-navy tracking-tight flex items-center gap-2">
            <svg className="w-5 h-5 text-orange-600" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24" aria-hidden>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            {t("home.exploreMoreTrips")}
          </h2>
        </div>
        <Link
          href={seeAllHref}
          className="inline-flex items-center gap-1.5 self-start sm:self-auto text-sm font-semibold text-orange-700 hover:text-orange-800 transition-colors whitespace-nowrap"
        >
          {t("home.seeAllTrips")}
          <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
          </svg>
        </Link>
      </div>

      {/* Language tabs — only rendered when more than one language has
          an unstarted city. With just one, the tab bar is dead weight. */}
      {languages.length > 1 && (
        <div className="mb-5 inline-flex items-center bg-white border border-border rounded-full p-1 shadow-sm" role="tablist">
          {languages.map((slug) => {
            const label = getLocalizedLanguageName(
              slug,
              uiLang,
              slug.charAt(0).toUpperCase() + slug.slice(1),
            );
            const flag = FLAG_CODES[slug] ?? slug;
            const isActive = slug === effectiveLang;
            return (
              <button
                key={slug}
                type="button"
                role="tab"
                aria-selected={isActive}
                onClick={() => setActiveLang(slug)}
                className={`inline-flex items-center gap-2 px-4 py-1.5 text-sm font-semibold rounded-full transition-colors ${
                  isActive
                    ? "bg-gradient-to-br from-orange-500 to-red-600 text-white shadow-sm"
                    : "text-navy/60 hover:text-navy"
                }`}
              >
                <Image
                  src={`https://flagcdn.com/w40/${flag}.png`}
                  alt=""
                  width={18}
                  height={13}
                  className="rounded-sm shadow-sm ring-1 ring-black/5"
                  unoptimized
                />
                {label}
              </button>
            );
          })}
        </div>
      )}

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5">
        {visible.map((c) => (
          <ExploreCityCard key={`${c.languageSlug}-${c.citySlug}`} city={c} />
        ))}
      </div>
    </section>
  );
}

// Card for one unstarted city. Shows "Coming soon" when lessonsTotal
// is 0 — the whole card becomes non-interactive so users can see the
// city is in the roadmap without being able to open a hollow course.
function ExploreCityCard({ city }: { city: ExploreCityEntry }) {
  const { t } = useI18n();
  const comingSoon = city.lessonsTotal === 0;
  const href = `/learn/${city.languageSlug}/travel/${city.citySlug}`;

  const body = (
    <>
      <div className="relative w-full aspect-[16/10] bg-navy/5">
        {city.coverImageUrl && (
          <Image
            src={city.coverImageUrl}
            alt={`${city.city}, ${city.country}`}
            fill
            sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
            className={`object-cover transition-transform duration-500 ${
              comingSoon ? "" : "group-hover:scale-[1.02]"
            }`}
          />
        )}
        <div className="absolute top-3 left-3">
          {comingSoon ? (
            <span className="inline-flex items-center gap-1.5 rounded-full bg-navy/80 text-white backdrop-blur px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider shadow-sm">
              <svg className="w-3 h-3" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24" aria-hidden>
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              {t("home.comingSoon")}
            </span>
          ) : (
            <span className="inline-flex items-center gap-1.5 rounded-full bg-white/95 backdrop-blur px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider text-amber-800 shadow-sm">
              <span aria-hidden>✈</span>
              {t("card.firstLessonsFree", {
                count: String(city.freePreviewCount),
              })}
            </span>
          )}
        </div>
        <div className="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-black/60 to-transparent pointer-events-none" />
        <div className="absolute bottom-3 left-3 right-3">
          <p className="text-[11px] font-semibold uppercase tracking-[0.14em] text-white/80">
            {city.country}
          </p>
          <h3 className="text-2xl font-bold text-white leading-tight drop-shadow-sm truncate">
            {city.city}
          </h3>
        </div>
      </div>
      <div className="flex items-center justify-between gap-3 px-4 sm:px-5 py-3 sm:py-4">
        <p className="text-xs text-navy/60">
          {comingSoon
            ? t("home.comingSoonBody")
            : t("card.cityLessons", { count: String(city.lessonsTotal) })}
        </p>
        {!comingSoon && (
          <span className="inline-flex items-center gap-1 text-xs font-bold text-orange-700 group-hover:text-orange-800 transition-colors whitespace-nowrap">
            {t("card.startTrip")}
            <svg className="w-3.5 h-3.5 group-hover:translate-x-0.5 transition-transform" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
            </svg>
          </span>
        )}
      </div>
    </>
  );

  if (comingSoon) {
    // Non-interactive placeholder — no Link, no hover state. The card
    // reads as "we know about this city; it's not ready yet".
    return (
      <div
        aria-disabled
        className="relative flex flex-col overflow-hidden bg-white border border-border rounded-2xl opacity-85 cursor-default"
      >
        {body}
      </div>
    );
  }

  return (
    <Link
      href={href}
      className="group relative flex flex-col overflow-hidden bg-white border border-border rounded-2xl hover:border-orange-400/40 hover:shadow-lg sm:hover:-translate-y-0.5 transition-all"
    >
      {body}
    </Link>
  );
}

// A city-progress card for the "Continue your trip" strip. Deep-links
// to the user's next incomplete lesson so one click puts them back in
// the flow.
function TripCard({ trip }: { trip: StartedTripEntry }) {
  const { t } = useI18n();
  const pct =
    trip.lessonsTotal === 0
      ? 0
      : Math.round((trip.lessonsCompleted / trip.lessonsTotal) * 100);
  const continueHref =
    trip.nextLessonId != null
      ? `/learn/${trip.languageSlug}/travel/${trip.citySlug}/${trip.nextLessonId}`
      : `/learn/${trip.languageSlug}/travel/${trip.citySlug}`;
  return (
    <Link
      href={continueHref}
      className="group relative flex flex-col overflow-hidden bg-white border border-border rounded-2xl hover:border-orange-400/50 hover:shadow-lg sm:hover:-translate-y-0.5 transition-all"
    >
      <div className="relative w-full aspect-[16/10] bg-navy/5">
        {trip.coverImageUrl && (
          <Image
            src={trip.coverImageUrl}
            alt={`${trip.city}, ${trip.country}`}
            fill
            sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
            className="object-cover group-hover:scale-[1.02] transition-transform duration-500"
          />
        )}
        <div className="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-black/70 to-transparent pointer-events-none" />
        <div className="absolute bottom-3 left-3 right-3">
          <p className="text-[11px] font-semibold uppercase tracking-[0.14em] text-white/80">
            {trip.country}
          </p>
          <h3 className="text-2xl font-bold text-white leading-tight drop-shadow-sm truncate">
            {trip.city}
          </h3>
        </div>
      </div>
      <div className="p-4 sm:p-5">
        {trip.nextLessonTitle && (
          <p className="text-xs text-navy/50 mb-2">
            <span className="uppercase tracking-wider text-navy/40">{t("home.nextUp")}</span>{" "}
            <span className="text-navy/70 font-medium">{trip.nextLessonTitle}</span>
          </p>
        )}
        <div className="flex items-center justify-between text-xs text-navy/50 mb-1.5">
          <span>
            {trip.lessonsCompleted} / {trip.lessonsTotal} lessons
          </span>
          <span className="font-semibold text-navy/70 tabular-nums">{pct}%</span>
        </div>
        <div className="w-full h-2 bg-navy/5 rounded-full overflow-hidden mb-3">
          <div
            className="h-full bg-gradient-to-r from-orange-500 to-red-600 rounded-full transition-all duration-500"
            style={{ width: `${pct}%` }}
          />
        </div>
        <span className="inline-flex items-center justify-center w-full gap-1.5 py-2.5 text-sm font-semibold text-white bg-gradient-to-br from-orange-500 to-red-600 rounded-xl group-hover:from-orange-600 group-hover:to-red-700 active:scale-[0.98] transition-all">
          {t("home.continueCity")}
          <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
          </svg>
        </span>
      </div>
    </Link>
  );
}

function ActiveLanguageCard({ lang }: { lang: ActiveLanguageEntry }) {
  const { t } = useI18n();
  const pill = LEVEL_PILL[lang.currentLevel];
  const flag = FLAG_CODES[lang.slug] ?? lang.countryCode;
  const showTravel = hasTravelPhrasebook(lang.slug);
  return (
    <div className="group relative flex flex-col bg-white border border-border rounded-2xl p-5 sm:p-6 hover:shadow-lg hover:border-teal/40 transition-all">
      {showTravel && (
        <Link
          href={`/languages/${lang.slug}/travel-guide`}
          className="absolute top-3 right-3 z-10 inline-flex items-center gap-1 rounded-full bg-blue-100 text-blue-900 text-[10px] font-bold px-2 py-1 border border-blue-300 hover:bg-blue-200 transition-colors"
          aria-label={`Open ${lang.name} Phrase Lookup`}
        >
          <span aria-hidden>✈</span>
          {t("nav.phraseLookup")}
        </Link>
      )}
      <div className="flex items-start gap-4">
        <Image
          src={`https://flagcdn.com/w160/${flag}.png`}
          alt={`${lang.name} flag`}
          width={64}
          height={48}
          className="rounded-md object-cover shadow-sm ring-1 ring-black/5 shrink-0"
        />
        <div className="min-w-0 flex-1 pr-24">
          <div className="flex items-center gap-2 mb-1">
            <h3 className="text-xl sm:text-2xl font-bold text-navy tracking-tight truncate">
              {lang.name}
            </h3>
            <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-bold ring-1 ${pill}`}>
              {lang.currentLevel}
            </span>
          </div>
          <p className="text-xs sm:text-sm text-navy/50">
            {CEFR_LABEL[lang.currentLevel]} · {lang.totalXp.toLocaleString()} XP earned
          </p>
        </div>
      </div>

      <div className="mt-5">
        <div className="flex items-center justify-between text-xs text-navy/60 mb-1.5">
          <span>
            {lang.currentLevel} progress · {lang.levelCompleted} / {lang.levelTotal} lessons
          </span>
          <span className="font-semibold text-navy/70 tabular-nums">{lang.levelPct}%</span>
        </div>
        <div className="w-full h-2.5 bg-navy/5 rounded-full overflow-hidden">
          <div
            className="h-full bg-gradient-to-r from-teal to-teal-dark rounded-full transition-all duration-500"
            style={{ width: `${lang.levelPct}%` }}
          />
        </div>
      </div>

      {lang.lastLessonTitle && (
        <p className="mt-4 text-xs text-navy/50">
          <span className="uppercase tracking-wider text-navy/40">{t("home.lastLesson")}:</span>{" "}
          <span className="text-navy/70 font-medium">{lang.lastLessonTitle}</span>
        </p>
      )}

      <Link
        href={lang.continueHref}
        className="mt-5 inline-flex items-center justify-center w-full gap-1.5 py-3 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark active:scale-[0.98] transition-all"
      >
        {lang.totalCompleted > 0
          ? t("card.fluencyContinue")
          : t("card.fluencyStart")}
        <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </Link>
    </div>
  );
}
