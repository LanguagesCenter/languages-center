import Link from "next/link";
import Image from "next/image";
import { notFound, redirect } from "next/navigation";
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
  userHasProgressInLanguage,
  CEFR_LABEL,
  CEFR_LEVELS,
  type CEFRLevel,
  type DbPodcast,
  type DbVideo,
} from "@/lib/learn";
import { getServerT } from "@/lib/i18n-server";
import { hasTravelPhrasebook } from "@/lib/travel-phrases";

export function generateStaticParams() {
  return getAllOverviewSlugs().map((language) => ({ language }));
}

export async function generateMetadata(
  props: PageProps<"/languages/[language]">,
) {
  const { language } = await props.params;
  const overview = getOverview(language);
  if (!overview) return { title: "Language — Languages Center" };
  return {
    title: `Learn ${overview.name} — Languages Center`,
    description: overview.about,
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
  if (isLoggedIn) {
    return (
      <Link
        href={`/learn/${overview.slug}`}
        className="inline-flex items-center gap-2 px-7 py-3.5 text-base font-semibold text-white bg-teal rounded-full hover:bg-teal-dark hover:shadow-lg transition-all"
      >
        Start learning {overview.name}
        <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </Link>
    );
  }
  return (
    <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3">
      <Link
        href="/login"
        className="inline-flex items-center justify-center gap-2 px-7 py-3.5 text-base font-semibold text-white bg-teal rounded-full hover:bg-teal-dark hover:shadow-lg transition-all"
      >
        Sign up to start
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

  // Smart routing: a signed-in learner who has completed anything in this
  // language should land directly on the course view — the marketing
  // overview is only useful for discovery. Anonymous visitors and users
  // with zero completed lessons still see this page. Check runs before any
  // heavier DB work so redirects are cheap.
  if (user && (await userHasProgressInLanguage(slug))) {
    redirect(`/learn/${slug}`);
  }

  // Fetch DB-backed content (returns empty arrays if not yet seeded)
  const dbLanguage = await getLanguageBySlug(slug);
  const [tree, podcasts, videos, isPremium] = await Promise.all([
    dbLanguage ? getCEFRTreeForLanguage(dbLanguage.id) : Promise.resolve([]),
    dbLanguage ? getPodcastsForLanguage(dbLanguage.id) : Promise.resolve([]),
    dbLanguage ? getVideosForLanguage(dbLanguage.id) : Promise.resolve([]),
    isCurrentUserPremium(),
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
                  Learn {overview.name}
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

        {/* Two side-by-side travel-track cards — Traveler's Course
            (warm terracotta) + Phrase Passport (deep blue). Same shape,
            same size, visually balanced, hard to confuse. Only rendered
            for Spanish/French today. */}
        {hasTravelPhrasebook(slug) && (
          <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 sm:pt-10">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-5">
              {/* Traveler's Course — terracotta */}
              <Link
                href={`/learn/${slug}/travel`}
                className="group relative flex flex-col overflow-hidden rounded-3xl border-2 border-orange-300/70 bg-gradient-to-br from-orange-100 via-amber-50 to-orange-50 p-6 sm:p-7 shadow-md hover:shadow-xl hover:border-orange-400 transition-all"
              >
                <div className="pointer-events-none absolute -top-10 -right-10 opacity-10">
                  <svg className="w-56 h-56 text-orange-700" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M17.657 16.657L13.414 20.9a2 2 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path strokeLinecap="round" strokeLinejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                </div>
                <div className="relative flex items-start gap-4">
                  <div className="shrink-0 w-14 h-14 sm:w-16 sm:h-16 rounded-2xl bg-gradient-to-br from-orange-500 to-red-600 text-white flex items-center justify-center shadow-lg ring-4 ring-white/60">
                    <svg className="w-7 h-7 sm:w-8 sm:h-8" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M17.657 16.657L13.414 20.9a2 2 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                      <path strokeLinecap="round" strokeLinejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                  </div>
                  <div className="min-w-0">
                    <span className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.14em] bg-orange-600 text-white shadow-sm mb-2">
                      Immersive course
                    </span>
                    <h2 className="text-xl sm:text-2xl font-bold text-orange-950 tracking-tight">
                      Traveler&rsquo;s Course
                    </h2>
                  </div>
                </div>
                <p className="relative text-sm text-orange-900/80 mt-3 leading-relaxed flex-1">
                  Simulate a real trip with 50 immersive lessons per city — airport to departure gate.
                </p>
                <span className="relative mt-4 inline-flex items-center justify-center gap-2 px-5 py-2.5 text-sm font-bold text-white bg-orange-600 rounded-full shadow-md group-hover:bg-orange-700 group-hover:shadow-lg transition-all self-start whitespace-nowrap">
                  Choose a City
                  <svg className="w-4 h-4 group-hover:translate-x-0.5 transition-transform" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                  </svg>
                </span>
              </Link>

              {/* Phrase Passport — deep blue */}
              <Link
                href={`/languages/${slug}/travel-guide`}
                className="group relative flex flex-col overflow-hidden rounded-3xl border-2 border-blue-500/40 bg-gradient-to-br from-blue-700 via-blue-800 to-indigo-900 p-6 sm:p-7 shadow-md hover:shadow-xl hover:border-blue-400 transition-all"
              >
                <div className="pointer-events-none absolute -top-10 -right-10 opacity-10">
                  <svg className="w-56 h-56 text-white" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M5 3a2 2 0 00-2 2v16l7-4 7 4V5a2 2 0 00-2-2H5z" />
                  </svg>
                </div>
                <div className="relative flex items-start gap-4">
                  <div className="shrink-0 w-14 h-14 sm:w-16 sm:h-16 rounded-2xl bg-white/15 text-white flex items-center justify-center shadow-lg ring-4 ring-white/20 backdrop-blur">
                    <svg className="w-7 h-7 sm:w-8 sm:h-8" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M5 3a2 2 0 00-2 2v16l7-4 7 4V5a2 2 0 00-2-2H5z" />
                    </svg>
                  </div>
                  <div className="min-w-0">
                    <span className="inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.14em] bg-white/20 text-white shadow-sm mb-2 backdrop-blur">
                      Quick reference
                    </span>
                    <h2 className="text-xl sm:text-2xl font-bold text-white tracking-tight">
                      Phrase Passport
                    </h2>
                  </div>
                </div>
                <p className="relative text-sm text-blue-100/90 mt-3 leading-relaxed flex-1">
                  65 essential phrases with pronunciation — your pocket guide to getting by.
                </p>
                <span className="relative mt-4 inline-flex items-center justify-center gap-2 px-5 py-2.5 text-sm font-bold text-blue-900 bg-white rounded-full shadow-md group-hover:bg-blue-50 group-hover:shadow-lg transition-all self-start whitespace-nowrap">
                  Open Passport
                  <svg className="w-4 h-4 group-hover:translate-x-0.5 transition-transform" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                  </svg>
                </span>
              </Link>
            </div>
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
