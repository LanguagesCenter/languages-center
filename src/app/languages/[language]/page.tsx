import Link from "next/link";
import Image from "next/image";
import { notFound } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import PremiumLockedOverlay from "@/components/PremiumLockedOverlay";
import { createClient } from "@/lib/supabase/server";
import {
  getOverview,
  getAllOverviewSlugs,
  type LanguageOverview,
} from "@/lib/language-overviews";
import type { Difficulty } from "@/lib/languages";
import {
  getLanguageBySlug,
  getCEFRTreeForLanguage,
  getPodcastsForLanguage,
  getVideosForLanguage,
  isCurrentUserPremium,
  CEFR_LABEL,
  CEFR_LEVELS,
  type CEFRLevel,
  type DbPodcast,
  type DbVideo,
} from "@/lib/learn";
import { getServerT } from "@/lib/i18n-server";
import { hasTravelPhrasebook } from "@/lib/travel-phrases";
import { getTravelerCoursesForLanguage } from "@/lib/traveler";

export function generateStaticParams() {
  return getAllOverviewSlugs().map((language) => ({ language }));
}

export async function generateMetadata(
  props: PageProps<"/languages/[language]">,
) {
  const { language } = await props.params;
  const overview = getOverview(language);
  if (!overview) return { title: "Language — Languages Center" };
  const hasTraveler = overview.slug === "spanish" || overview.slug === "french";
  return {
    title: hasTraveler
      ? `${overview.name} on the ground — Languages Center`
      : `${overview.name} Fluency Course — Languages Center`,
    description: hasTraveler
      ? `Simulate a real trip in ${overview.name} — city by city, airport to departure gate. Plus the full A1 → C1 Fluency Course.`
      : overview.about,
  };
}

function DifficultyBadge({ label, level }: { label: string; level: Difficulty }) {
  const colors: Record<Difficulty, string> = {
    Easy: "bg-teal-light text-teal-dark border-teal/30",
    Medium: "bg-peach-light text-amber-700 border-peach-dark/40",
    Hard: "bg-red-50 text-red-700 border-red-200",
  };
  return (
    <div className="flex flex-col items-center gap-1">
      <span className="text-xs text-navy/50 uppercase tracking-wider font-medium">
        {label}
      </span>
      <span
        className={`inline-block px-3 py-1 text-sm font-semibold rounded-full border ${colors[level]}`}
      >
        {level}
      </span>
    </div>
  );
}

const LEVEL_PILL: Record<CEFRLevel, string> = {
  A1: "bg-emerald-50 text-emerald-700 ring-emerald-200",
  A2: "bg-teal-light text-teal-dark ring-teal/30",
  B1: "bg-amber-50 text-amber-800 ring-amber-200",
  B2: "bg-orange-50 text-orange-800 ring-orange-200",
  C1: "bg-rose-50 text-rose-800 ring-rose-200",
};

function CefrLevelCard({
  level,
  sectionCount,
  lessonCount,
}: {
  level: CEFRLevel;
  sectionCount: number;
  lessonCount: number;
}) {
  const pill = LEVEL_PILL[level];
  return (
    <div className="bg-white border border-border rounded-2xl p-5">
      <span className={`inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ${pill}`}>
        {level}
      </span>
      <p className="text-base font-semibold text-navy mt-3">{CEFR_LABEL[level]}</p>
      <p className="text-xs text-navy/50 mt-1">
        {sectionCount} {sectionCount === 1 ? "section" : "sections"} · {lessonCount} lessons
      </p>
    </div>
  );
}

function RelatedCard({ slug }: { slug: string }) {
  const related = getOverview(slug);
  if (!related) return null;
  return (
    <Link
      href={`/languages/${related.slug}`}
      className="group bg-white border border-border rounded-2xl p-5 hover:shadow-md hover:border-teal/40 hover:scale-[1.02] transition-all"
    >
      <div className="flex items-center gap-3 mb-2">
        <Image
          src={`https://flagcdn.com/w80/${related.countryCode}.png`}
          alt={`${related.name} flag`}
          width={32}
          height={24}
          className="rounded-sm object-cover shadow-sm"
        />
      </div>
      <p className="font-semibold text-navy group-hover:text-teal transition-colors">
        {related.name}
      </p>
      <p className="text-xs text-navy/50 mt-0.5">{related.nativeName}</p>
    </Link>
  );
}

function StartLearningCTA({
  overview,
  isLoggedIn,
}: {
  overview: LanguageOverview;
  isLoggedIn: boolean;
}) {
  const hasTraveler =
    overview.slug === "spanish" || overview.slug === "french";
  // Spanish/French lead with the trip. Signed-in users go through the
  // smart-routing endpoint so Fluency-only learners don't get yanked
  // off their current track. Anon users jump to the city grid section
  // on this same page (the trip hero rendered just below).
  const primaryHref = hasTraveler
    ? isLoggedIn
      ? `/learn/${overview.slug}/start`
      : "#cities"
    : `/learn/${overview.slug}`;
  const primaryLabel = hasTraveler
    ? "Start your trip"
    : `Start learning ${overview.name}`;
  const primaryClasses = hasTraveler
    ? "inline-flex items-center gap-2 px-7 py-3.5 text-base font-semibold text-white bg-gradient-to-br from-orange-500 to-red-600 rounded-full hover:from-orange-600 hover:to-red-700 hover:shadow-lg transition-all"
    : "inline-flex items-center gap-2 px-7 py-3.5 text-base font-semibold text-white bg-teal rounded-full hover:bg-teal-dark hover:shadow-lg transition-all";

  if (isLoggedIn) {
    return (
      <Link href={primaryHref} className={primaryClasses}>
        {hasTraveler && (
          <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24" aria-hidden>
            <path d="M21 16v-2l-8-5V3.5a1.5 1.5 0 00-3 0V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1L15 22v-1.5L13 19v-5.5L21 16z" />
          </svg>
        )}
        {primaryLabel}
        <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </Link>
    );
  }
  return (
    <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
      <Link href={primaryHref} className={primaryClasses}>
        {hasTraveler && (
          <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24" aria-hidden>
            <path d="M21 16v-2l-8-5V3.5a1.5 1.5 0 00-3 0V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1L15 22v-1.5L13 19v-5.5L21 16z" />
          </svg>
        )}
        {primaryLabel}
      </Link>
      <Link
        href="/login"
        className="inline-flex items-center justify-center gap-2 px-5 py-3.5 text-base font-medium text-teal-dark hover:text-teal transition-colors"
      >
        Already a member? Log in
      </Link>
    </div>
  );
}

function PodcastCard({
  podcast,
  locked,
}: {
  podcast: DbPodcast;
  locked: boolean;
}) {
  const pill = LEVEL_PILL[podcast.level];
  return (
    <div className="relative bg-white border border-border rounded-2xl p-5 overflow-hidden">
      <div className={locked ? "blur-sm select-none" : ""}>
        <div className="flex items-center justify-between mb-3">
          <span className={`inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ${pill}`}>
            {podcast.level}
          </span>
          <span className="inline-flex items-center gap-1 text-xs text-navy/50">
            <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
            </svg>
            {podcast.duration_minutes} min
          </span>
        </div>
        <div className="flex items-center gap-3 mb-3">
          <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-teal to-teal-dark text-white flex items-center justify-center shadow">
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 14a3 3 0 003-3V5a3 3 0 10-6 0v6a3 3 0 003 3zm5-3a5 5 0 11-10 0H5a7 7 0 006 6.92V21h2v-3.08A7 7 0 0019 11h-2z" />
            </svg>
          </div>
          <div className="min-w-0">
            <p className="font-semibold text-navy text-sm truncate">{podcast.title}</p>
            <p className="text-[11px] text-navy/50 uppercase tracking-wider">Podcast episode</p>
          </div>
        </div>
        <p className="text-xs text-navy/60 leading-relaxed line-clamp-3">
          {podcast.description}
        </p>
      </div>
      {locked && <PremiumLockedOverlay />}
    </div>
  );
}

function VideoCard({
  video,
  locked,
}: {
  video: DbVideo;
  locked: boolean;
}) {
  const pill = LEVEL_PILL[video.level];
  return (
    <div className="relative bg-white border border-border rounded-2xl overflow-hidden">
      <div className={locked ? "blur-sm select-none" : ""}>
        <div className="relative aspect-video bg-gradient-to-br from-navy/90 to-navy/70 flex items-center justify-center">
          <svg className="w-12 h-12 text-white/90" fill="currentColor" viewBox="0 0 24 24">
            <path d="M8 5v14l11-7z" />
          </svg>
          <span className="absolute bottom-2 right-2 text-[11px] text-white/90 bg-black/40 rounded-full px-2 py-0.5">
            {video.duration_minutes} min
          </span>
        </div>
        <div className="p-5">
          <div className="flex items-center justify-between mb-2">
            <span className={`inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ${pill}`}>
              {video.level}
            </span>
            <span className="text-[11px] text-navy/50 uppercase tracking-wider">Video</span>
          </div>
          <p className="font-semibold text-navy text-sm mb-1">{video.title}</p>
          <p className="text-xs text-navy/60 leading-relaxed line-clamp-3">
            {video.description}
          </p>
        </div>
      </div>
      {locked && <PremiumLockedOverlay />}
    </div>
  );
}

export default async function LanguageOverviewPage(
  props: PageProps<"/languages/[language]">,
) {
  const { language: slug } = await props.params;
  const overview = getOverview(slug);
  if (!overview) notFound();

  const supabase = await createClient();
  const t = await getServerT();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  // The overview page is now a hub for signed-in users too — Traveler's
  // Course hero at top, Fluency Course second, Phrase Lookup third.
  // Users can still deep-link into either track from here. The old
  // "has-progress → redirect to /learn/[slug]" shortcut is gone; the
  // signed-in navbar + homepage already give returning learners a
  // direct Continue link, so this page is strictly discovery now.

  // Fetch DB-backed content (returns empty arrays if not yet seeded)
  const dbLanguage = await getLanguageBySlug(slug);
  const hasTraveler = slug === "spanish" || slug === "french";
  const [tree, podcasts, videos, isPremium, travelerCourses] = await Promise.all([
    dbLanguage ? getCEFRTreeForLanguage(dbLanguage.id) : Promise.resolve([]),
    dbLanguage ? getPodcastsForLanguage(dbLanguage.id) : Promise.resolve([]),
    dbLanguage ? getVideosForLanguage(dbLanguage.id) : Promise.resolve([]),
    isCurrentUserPremium(),
    hasTraveler
      ? getTravelerCoursesForLanguage(slug)
      : Promise.resolve(
          [] as Awaited<ReturnType<typeof getTravelerCoursesForLanguage>>,
        ),
  ]);

  // Build CEFR summary (sections + lessons per level)
  const cefrSummary = CEFR_LEVELS.map((level) => {
    const group = tree.find((g) => g.level === level);
    return {
      level,
      sectionCount: group?.sections.length ?? 0,
      lessonCount: group?.lessonsTotal ?? 0,
    };
  });

  return (
    <>
      <Navbar />
      <main className="flex-1">
        {/* Hero */}
        <section className="bg-gradient-to-b from-peach-light/60 to-background border-b border-border">
          <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-14 sm:py-20">
            <Link
              href="/"
              className="inline-flex items-center gap-1.5 text-sm text-navy/60 hover:text-teal transition-colors mb-6"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
              </svg>
              {t("overview.allLanguages")}
            </Link>
            <div className="grid grid-cols-1 md:grid-cols-[1fr_auto] gap-8 items-center">
              <div>
                <div className="flex items-center gap-4 mb-5">
                  <Image
                    src={`https://flagcdn.com/w160/${overview.countryCode}.png`}
                    alt={`${overview.name} flag`}
                    width={72}
                    height={54}
                    className="rounded-md object-cover shadow-sm"
                  />
                </div>
                <h1 className="text-4xl sm:text-5xl font-bold text-navy tracking-tight mb-2">
                  {hasTraveler
                    ? `${overview.name} on the ground`
                    : `Learn ${overview.name}`}
                </h1>
                <p className="text-lg text-navy/60 mb-6">
                  <span className="italic">{overview.nativeName}</span> · {overview.speakers}
                </p>
                <div className="flex gap-6 mb-8">
                  <DifficultyBadge label={t("card.grammar")} level={overview.grammar} />
                  <DifficultyBadge label={t("card.pronunciation")} level={overview.pronunciation} />
                </div>
                <StartLearningCTA overview={overview} isLoggedIn={!!user} />
              </div>
            </div>
          </div>
        </section>

        {/* Traveler's Course hero — the primary track for Spanish and
            French. Big map-themed card with a city grid preview below,
            followed by a smaller Fluency Course card and an even
            smaller Phrase Lookup card. Only rendered for Spanish /
            French (languages with a Traveler's Course today). */}
        {hasTraveler && (
          <section id="cities" className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 sm:pt-10 scroll-mt-20">
            <div className="relative overflow-hidden rounded-3xl border-2 border-orange-300/70 bg-gradient-to-br from-orange-100 via-amber-50 to-orange-50 p-6 sm:p-8 shadow-md">
              <div className="pointer-events-none absolute -top-16 -right-16 opacity-10">
                <svg className="w-80 h-80 text-orange-700" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M17.657 16.657L13.414 20.9a2 2 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                  <path strokeLinecap="round" strokeLinejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
              </div>
              <div className="relative flex flex-col sm:flex-row sm:items-start sm:justify-between gap-5 mb-6 sm:mb-8">
                <div className="min-w-0">
                  <span className="inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-bold uppercase tracking-[0.14em] bg-orange-600 text-white shadow-sm mb-3">
                    <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24" aria-hidden>
                      <path strokeLinecap="round" strokeLinejoin="round" d="M17.657 16.657L13.414 20.9a2 2 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                      <path strokeLinecap="round" strokeLinejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    {t("overview.travelerHero.eyebrow")}
                  </span>
                  <h2 className="text-2xl sm:text-3xl font-bold text-orange-950 tracking-tight leading-tight">
                    {t("overview.travelerHero.title", { language: overview.name })}
                  </h2>
                  <p className="text-sm sm:text-base text-orange-900/80 mt-2 leading-relaxed max-w-xl">
                    {t("overview.travelerHero.body")}
                  </p>
                </div>
              </div>

              {/* Mini city grid — all cities for this language with a
                  cover thumbnail. Clicking a city jumps straight to its
                  course page. Keeps the hero visually anchored to the
                  "map/trip" theme without needing a real map library. */}
              {travelerCourses.length > 0 && (
                <div className="relative grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
                  {travelerCourses.map((c) => (
                    <Link
                      key={c.id}
                      href={`/learn/${slug}/travel/${c.slug}`}
                      className="group relative overflow-hidden rounded-xl aspect-[4/3] bg-navy/10 shadow-sm hover:shadow-md hover:-translate-y-0.5 transition-all"
                    >
                      {c.coverImageUrl && (
                        <Image
                          src={c.coverImageUrl}
                          alt={`${c.city}, ${c.country}`}
                          fill
                          sizes="(max-width: 640px) 50vw, (max-width: 1024px) 33vw, 25vw"
                          className="object-cover group-hover:scale-[1.05] transition-transform duration-500"
                        />
                      )}
                      <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />
                      <div className="absolute inset-x-0 bottom-0 p-2.5">
                        <p className="text-[9px] font-semibold uppercase tracking-[0.1em] text-white/80">
                          {c.country}
                        </p>
                        <p className="text-sm font-bold text-white leading-tight drop-shadow-sm truncate">
                          {c.city}
                        </p>
                      </div>
                    </Link>
                  ))}
                </div>
              )}

              <div className="relative mt-6 flex items-center justify-between gap-3 flex-wrap">
                <p className="text-xs text-orange-900/70">
                  {travelerCourses.length} {travelerCourses.length === 1 ? "city" : "cities"} · 50 lessons each · first 5 free
                </p>
                <Link
                  href={user ? `/learn/${slug}/start` : `/learn/${slug}/travel`}
                  className="inline-flex items-center gap-2 px-5 py-2.5 text-sm font-bold text-white bg-orange-600 rounded-full shadow-md hover:bg-orange-700 hover:shadow-lg transition-all whitespace-nowrap"
                >
                  {t("overview.travelerHero.cta")}
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                  </svg>
                </Link>
              </div>
            </div>
          </section>
        )}

        {/* Fluency Course card — secondary. Smaller than the Traveler's
            Course hero above. Rendered for every language that has a
            Fluency Course (every language). */}
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pt-5 sm:pt-6">
          <Link
            href={`/learn/${slug}`}
            className="group relative flex flex-col sm:flex-row sm:items-center overflow-hidden rounded-2xl border border-teal/30 bg-gradient-to-br from-teal-light/60 to-white p-5 sm:p-6 shadow-sm hover:shadow-md hover:border-teal/50 transition-all gap-4"
          >
            <div className="shrink-0 w-12 h-12 sm:w-14 sm:h-14 rounded-xl bg-teal text-white flex items-center justify-center shadow-sm ring-2 ring-white">
              <svg className="w-6 h-6 sm:w-7 sm:h-7" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
              </svg>
            </div>
            <div className="min-w-0 flex-1">
              <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-teal-dark mb-1">
                {t("overview.fluency.eyebrow")} · A1 → C1
              </p>
              <h3 className="text-lg sm:text-xl font-bold text-navy leading-tight">
                {t("overview.fluency.title")}
              </h3>
              <p className="text-sm text-navy/60 mt-1 leading-relaxed">
                {t("overview.fluency.body")}
              </p>
            </div>
            <span className="shrink-0 inline-flex items-center gap-1.5 px-4 py-2 text-sm font-bold text-white bg-teal rounded-full shadow-sm group-hover:bg-teal-dark group-hover:shadow-md transition-all whitespace-nowrap">
              {t("overview.fluency.cta")}
              <svg className="w-3.5 h-3.5 group-hover:translate-x-0.5 transition-transform" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </span>
          </Link>
        </section>

        {/* Phrase Lookup — tertiary. Smallest. */}
        {hasTravelPhrasebook(slug) && (
          <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pt-3 sm:pt-4">
            <Link
              href={`/languages/${slug}/travel-guide`}
              className="group flex items-center justify-between gap-4 rounded-xl border border-blue-200 bg-blue-50/50 p-4 hover:bg-blue-50 hover:border-blue-300 transition-all"
            >
              <div className="flex items-center gap-3 min-w-0">
                <span className="shrink-0 w-9 h-9 rounded-lg bg-blue-700 text-white flex items-center justify-center">
                  <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24" aria-hidden>
                    <path d="M5 3a2 2 0 00-2 2v16l7-4 7 4V5a2 2 0 00-2-2H5z" />
                  </svg>
                </span>
                <div className="min-w-0">
                  <p className="text-sm font-bold text-blue-900 leading-tight">
                    {t("nav.phraseLookup")}
                  </p>
                  <p className="text-xs text-blue-800/70 leading-relaxed mt-0.5">
                    {t("overview.phraseLookup.body")}
                  </p>
                </div>
              </div>
              <svg className="w-4 h-4 text-blue-700 group-hover:translate-x-0.5 transition-transform shrink-0" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </Link>
          </section>
        )}

        {/* About */}
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-10">
            <div className="lg:col-span-2">
              <h2 className="text-2xl font-bold text-navy mb-3">
                {t("overview.about", { language: overview.name })}
              </h2>
              <p className="text-navy/70 leading-relaxed mb-6">{overview.about}</p>
              <div className="bg-white border border-border rounded-2xl p-5">
                <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-2">
                  {t("overview.whereSpoken")}
                </p>
                <p className="text-sm text-navy/70 leading-relaxed">{overview.regions}</p>
              </div>
            </div>
            <div className="bg-white border border-border rounded-2xl p-6">
              <h3 className="text-sm font-semibold text-teal-dark uppercase tracking-wider mb-4">
                {t("overview.interestingFacts")}
              </h3>
              <ul className="space-y-4">
                {overview.facts.map((fact, idx) => (
                  <li key={idx} className="flex gap-3">
                    <span className="flex-shrink-0 w-6 h-6 rounded-full bg-teal-light text-teal-dark text-xs font-bold flex items-center justify-center">
                      {idx + 1}
                    </span>
                    <span className="text-sm text-navy/70 leading-relaxed">{fact}</span>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </section>

        {/* Why learn */}
        <section className="bg-white border-y border-border">
          <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
            <h2 className="text-2xl font-bold text-navy mb-2">
              {t("overview.whyLearn", { language: overview.name })}
            </h2>
            <p className="text-navy/60 mb-8">
              {t("overview.threeReasons", { language: overview.name })}
            </p>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
              {overview.whyLearn.map((reason, idx) => (
                <div
                  key={idx}
                  className="border border-border rounded-2xl p-6 hover:border-teal/40 transition-colors"
                >
                  <div className="w-10 h-10 rounded-full bg-teal-light text-teal-dark font-bold flex items-center justify-center mb-4">
                    {idx + 1}
                  </div>
                  <h3 className="font-semibold text-navy mb-2">{reason.title}</h3>
                  <p className="text-sm text-navy/60 leading-relaxed">
                    {reason.description}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* CEFR Learning Path */}
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
          <h2 className="text-2xl font-bold text-navy mb-2">{t("overview.learningPath")}</h2>
          <p className="text-navy/60 mb-8">
            {t("overview.cefrPath", { language: overview.name })}
          </p>
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
            {cefrSummary.map((entry) => (
              <CefrLevelCard
                key={entry.level}
                level={entry.level}
                sectionCount={entry.sectionCount}
                lessonCount={entry.lessonCount}
              />
            ))}
          </div>
          <div className="mt-10 flex justify-center">
            <StartLearningCTA overview={overview} isLoggedIn={!!user} />
          </div>
        </section>

        {/* Articles teaser */}
        <section className="bg-white border-y border-border">
          <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-6">
              <div className="max-w-xl">
                <h2 className="text-2xl font-bold text-navy mb-2">{t("overview.readArticlesHeading")}</h2>
                <p className="text-navy/60 leading-relaxed">
                  {t("overview.readArticlesDesc", { language: overview.name })}
                </p>
              </div>
              <Link
                href={`/languages/${slug}/articles`}
                className="inline-flex items-center gap-2 px-6 py-3 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark transition-colors self-start md:self-center whitespace-nowrap"
              >
                {t("overview.browseArticles")}
                <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                </svg>
              </Link>
            </div>
          </div>
        </section>

        {/* Podcasts (premium) */}
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
          <div className="flex items-end justify-between gap-4 mb-6">
            <div>
              <div className="flex items-center gap-2 mb-1">
                <h2 className="text-2xl font-bold text-navy">{t("overview.podcasts")}</h2>
                <span className="inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider bg-peach-light text-amber-800 ring-1 ring-peach-dark/40">
                  {t("overview.premium")}
                </span>
              </div>
              <p className="text-sm text-navy/60">
                {t("overview.podcastsDesc")}
              </p>
            </div>
          </div>
          {podcasts.length === 0 ? (
            <p className="text-sm text-navy/50">{t("overview.podcastsSoon")}</p>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {podcasts.slice(0, 3).map((p) => (
                <PodcastCard key={p.id} podcast={p} locked={!isPremium && p.is_premium} />
              ))}
            </div>
          )}
        </section>

        {/* Videos (premium) */}
        <section className="bg-white border-y border-border">
          <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
            <div className="flex items-end justify-between gap-4 mb-6">
              <div>
                <div className="flex items-center gap-2 mb-1">
                  <h2 className="text-2xl font-bold text-navy">{t("overview.videos")}</h2>
                  <span className="inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider bg-peach-light text-amber-800 ring-1 ring-peach-dark/40">
                    {t("overview.premium")}
                  </span>
                </div>
                <p className="text-sm text-navy/60">
                  {t("overview.videosDesc")}
                </p>
              </div>
            </div>
            {videos.length === 0 ? (
              <p className="text-sm text-navy/50">{t("overview.videosSoon")}</p>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {videos.slice(0, 3).map((v) => (
                  <VideoCard key={v.id} video={v} locked={!isPremium && v.is_premium} />
                ))}
              </div>
            )}
          </div>
        </section>

        {/* Related */}
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
          <h2 className="text-2xl font-bold text-navy mb-2">{t("overview.relatedLanguages")}</h2>
          <p className="text-navy/60 mb-8">
            {t("overview.relatedDesc", { language: overview.name })}
          </p>
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
            {overview.related.map((slug) => (
              <RelatedCard key={slug} slug={slug} />
            ))}
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
