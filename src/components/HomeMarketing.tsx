"use client";

import Link from "next/link";
import Image from "next/image";
import LanguageGrid, { type LanguageGridItem } from "@/components/LanguageGrid";
import { useI18n } from "@/components/I18nProvider";

export interface HomeMarketingCity {
  languageSlug: string; // "spanish" | "french"
  city: string;
  country: string;
  citySlug: string;
  coverImageUrl: string;
  lessonsTotal: number;
  freePreviewCount: number;
}

export interface HomeMarketingProps {
  langs: LanguageGridItem[];
  startedSlugsInOrder: string[];
  travelerCompletedCounts: Record<string, number>;
  cities: HomeMarketingCity[];
  isLoggedIn: boolean;
}

// Marketing homepage — anonymous visitors and signed-in users who
// haven't completed anything yet. Trips-first: hero + city grid lead
// the page; the Fluency language grid sits in a smaller secondary
// section below.
export default function HomeMarketing({
  langs,
  startedSlugsInOrder,
  travelerCompletedCounts,
  cities,
  isLoggedIn,
}: HomeMarketingProps) {
  const { t } = useI18n();
  // When the user is signed in, the "Start your trip" CTA sends them
  // through the smart-routing endpoint so progress-aware redirects do
  // the right thing. Anonymous visitors go to the city grid directly
  // (we scroll to #cities anchor on the same page).
  const primaryHref = isLoggedIn ? "/learn/spanish/start" : "#cities";

  return (
    <main className="flex-1">
      {/* Hero — now trips-first. The old "learn CEFR language" headline
          is gone; the lead message is that this course gets you ready
          for a specific trip. */}
      <section className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-orange-100/60 via-amber-50/50 to-white pointer-events-none" />
        <div className="absolute top-20 -right-20 w-80 h-80 rounded-full bg-orange-400/10 blur-3xl pointer-events-none" />
        <div className="absolute -bottom-24 -left-16 w-96 h-96 rounded-full bg-amber-300/20 blur-3xl pointer-events-none" />
        <div className="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-14 sm:pt-20 lg:pt-24 pb-10 sm:pb-14 text-center">
          <span className="inline-flex items-center gap-2 rounded-full bg-white/80 border border-orange-300/40 backdrop-blur px-3 py-1 text-xs font-semibold text-orange-800 tracking-wide shadow-sm">
            <span aria-hidden>✈</span>
            {t("hero.badge")}
          </span>
          <h1 className="mt-6 text-4xl sm:text-5xl lg:text-6xl font-extrabold text-navy tracking-tight leading-[1.05]">
            {t("hero.title")}
          </h1>
          <p className="mt-5 sm:mt-6 text-base sm:text-lg lg:text-xl text-navy/60 max-w-2xl mx-auto leading-relaxed">
            {t("hero.subtitle")}
          </p>
          <div className="mt-8 sm:mt-10 flex flex-col sm:flex-row items-stretch sm:items-center justify-center gap-3 max-w-md sm:max-w-none mx-auto">
            <Link
              href={primaryHref}
              className="inline-flex items-center justify-center gap-2 px-7 py-3.5 text-base font-semibold text-white bg-gradient-to-br from-orange-500 to-red-600 rounded-full hover:from-orange-600 hover:to-red-700 hover:shadow-lg active:scale-[0.98] transition-all"
            >
              <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24" aria-hidden>
                <path d="M21 16v-2l-8-5V3.5a1.5 1.5 0 00-3 0V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1L15 22v-1.5L13 19v-5.5L21 16z" />
              </svg>
              {t("hero.ctaPrimary")}
              <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </Link>
            <Link
              href="#fluency"
              className="inline-flex items-center justify-center gap-2 px-6 py-3.5 text-base font-medium text-teal-dark hover:text-teal transition-colors"
            >
              {t("hero.ctaSecondary")}
              <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
              </svg>
            </Link>
          </div>
          <p className="mt-4 text-xs text-navy/40">
            {t("hero.noCard")}
          </p>
        </div>
      </section>

      {/* Pick your city — the main content block now. Seven cities
          across Spanish and French; each card goes to the per-city
          preview (anonymous) or straight to the course city page
          (signed-in). */}
      <section id="cities" className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-2 pb-14 sm:pb-16 scroll-mt-20">
        <div className="mb-6 sm:mb-8">
          <h2 className="text-2xl sm:text-3xl font-bold text-navy tracking-tight">
            {t("home.pickYourCity")}
          </h2>
          <p className="text-sm sm:text-base text-navy/60 mt-1 max-w-xl">
            {t("home.pickYourCitySubtitle")}
          </p>
        </div>
        {cities.length === 0 ? (
          <div className="rounded-2xl border border-dashed border-border bg-white p-8 text-center text-sm text-navy/60">
            Cities are being set up — check back soon.
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-5">
            {cities.map((c) => (
              <CityCard key={`${c.languageSlug}-${c.citySlug}`} city={c} isLoggedIn={isLoggedIn} />
            ))}
          </div>
        )}
      </section>

      {/* Want full fluency? Secondary section with the Fluency Course
          language cards. Smaller heading, muted styling so the cities
          clearly read as the main product. */}
      <section id="fluency" className="bg-white border-y border-border scroll-mt-20">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-12 sm:py-16">
          <div className="mb-6 sm:mb-8">
            <p className="text-xs font-semibold uppercase tracking-[0.18em] text-teal-dark mb-2">
              {t("card.fluencyCourse")}
            </p>
            <h2 className="text-2xl sm:text-3xl font-bold text-navy tracking-tight">
              {t("home.wantFullFluency")}
            </h2>
            <p className="text-sm sm:text-base text-navy/60 mt-1 max-w-xl">
              {t("home.wantFullFluencySubtitle")}
            </p>
          </div>
          <LanguageGrid
            languages={langs}
            startedSlugsInOrder={startedSlugsInOrder}
            travelerCompletedCounts={travelerCompletedCounts}
          />
        </div>
      </section>

      {/* Phrase Lookup — tertiary. Single compact card linking to both
          Spanish and French phrasebooks. Small on purpose. */}
      <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-10 sm:py-14">
        <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-blue-700 via-blue-800 to-indigo-900 p-6 sm:p-8 shadow-md">
          <div className="pointer-events-none absolute -top-10 -right-10 opacity-10">
            <svg className="w-56 h-56 text-white" fill="currentColor" viewBox="0 0 24 24">
              <path d="M5 3a2 2 0 00-2 2v16l7-4 7 4V5a2 2 0 00-2-2H5z" />
            </svg>
          </div>
          <div className="relative flex flex-col sm:flex-row items-start sm:items-center justify-between gap-5">
            <div className="max-w-xl">
              <p className="text-[11px] font-bold uppercase tracking-[0.18em] text-blue-200 mb-2">
                {t("nav.phraseLookup")}
              </p>
              <h3 className="text-xl sm:text-2xl font-bold text-white leading-tight">
                {t("home.phraseLookupTitle")}
              </h3>
              <p className="text-sm text-blue-100/90 mt-2 leading-relaxed">
                {t("home.phraseLookupBody")}
              </p>
            </div>
            <div className="flex flex-wrap gap-2 shrink-0">
              <Link
                href="/languages/spanish/travel-guide"
                className="inline-flex items-center gap-2 px-4 py-2 text-sm font-bold text-blue-900 bg-white rounded-full hover:bg-blue-50 shadow-md transition-all"
              >
                <Image
                  src="https://flagcdn.com/w40/es.png"
                  alt=""
                  width={20}
                  height={15}
                  className="rounded-sm shadow-sm"
                />
                Español
              </Link>
              <Link
                href="/languages/french/travel-guide"
                className="inline-flex items-center gap-2 px-4 py-2 text-sm font-bold text-blue-900 bg-white rounded-full hover:bg-blue-50 shadow-md transition-all"
              >
                <Image
                  src="https://flagcdn.com/w40/fr.png"
                  alt=""
                  width={20}
                  height={15}
                  className="rounded-sm shadow-sm"
                />
                Français
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Why Languages Center — kept but re-angled toward the traveler
          story (features phrased around actually hearing/using the
          language abroad). */}
      <section className="bg-white border-y border-border">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-12 sm:py-16">
          <div className="text-center max-w-2xl mx-auto mb-10 sm:mb-12">
            <p className="text-xs font-semibold uppercase tracking-[0.18em] text-teal-dark mb-2">
              Why Languages Center
            </p>
            <h2 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight">
              Built for the language you&rsquo;ll actually use
            </h2>
            <p className="text-base sm:text-lg text-navy/60 mt-3">
              Every lesson is scripted around situations you&rsquo;ll be in
              on the trip — not textbook grammar for its own sake.
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-5">
            <FeatureCard
              iconPath="M17.657 16.657L13.414 20.9a2 2 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0zM15 11a3 3 0 11-6 0 3 3 0 016 0z"
              title="Real city, real signs"
              body="Lessons are shot at named spots — Gran Vía, Puerta del Sol, Barajas — with actual Spanish you&rsquo;ll see on the ground."
            />
            <FeatureCard
              iconPath="M8 10h.01M12 10h.01M16 10h.01M21 12c0 4.418-4.03 8-9 8a9.86 9.86 0 01-4-.8L3 20l1.3-3.9A7.94 7.94 0 013 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
              title="AI-powered feedback"
              body="Speak into the mic and get instant coaching on pronunciation, fluency and grammar — the kind you&rsquo;d expect from a real tutor."
            />
            <FeatureCard
              iconPath="M3 10v4a1 1 0 001 1h3l4.29 4.29a1 1 0 001.71-.71V5.42a1 1 0 00-1.71-.71L7 9H4a1 1 0 00-1 1zm13.5 2a4.5 4.5 0 00-2.5-4.03v8.05A4.5 4.5 0 0016.5 12z"
              title="Native-accent audio"
              body="Taxi drivers, bar staff, PA announcements — every clip plays in a native voice so you train your ear from day one."
            />
            <FeatureCard
              iconPath="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"
              title="Also: full CEFR"
              body="Behind every trip sits a CEFR-aligned Fluency Course — A1 → C1, with placement exams and certificates when you want the long haul."
            />
          </div>
        </div>
      </section>
    </main>
  );
}

function CityCard({
  city,
  isLoggedIn,
}: {
  city: HomeMarketingCity;
  isLoggedIn: boolean;
}) {
  const { t } = useI18n();
  // Anonymous visitors go to the per-city preview page (anon-friendly,
  // first 5 lessons unlocked). Signed-in users jump straight to the
  // course city page.
  const href = isLoggedIn
    ? `/learn/${city.languageSlug}/travel/${city.citySlug}`
    : `/preview/${city.citySlug}`;
  return (
    <Link
      href={href}
      className="group relative flex flex-col overflow-hidden bg-white border border-border rounded-2xl hover:border-orange-400/40 hover:shadow-lg sm:hover:-translate-y-0.5 transition-all"
    >
      <div className="relative w-full aspect-[16/10] bg-navy/5">
        {city.coverImageUrl && (
          <Image
            src={city.coverImageUrl}
            alt={`${city.city}, ${city.country}`}
            fill
            sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
            className="object-cover group-hover:scale-[1.02] transition-transform duration-500"
          />
        )}
        <div className="absolute top-3 left-3">
          <span className="inline-flex items-center gap-1.5 rounded-full bg-white/95 backdrop-blur px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider text-amber-800 shadow-sm">
            <span aria-hidden>✈</span>
            {t("card.firstLessonsFree", { count: String(city.freePreviewCount) })}
          </span>
        </div>
        <div className="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-black/60 to-transparent pointer-events-none" />
        <div className="absolute bottom-3 left-3 right-3 flex items-end justify-between gap-2">
          <div className="min-w-0">
            <p className="text-[11px] font-semibold uppercase tracking-[0.14em] text-white/80">
              {city.country}
            </p>
            <h3 className="text-2xl font-bold text-white leading-tight drop-shadow-sm truncate">
              {city.city}
            </h3>
          </div>
          <Image
            src={`https://flagcdn.com/w80/${city.languageSlug === "spanish" ? countryToFlagForCity(city.country, "es") : "fr"}.png`}
            alt=""
            width={28}
            height={21}
            className="rounded-sm object-cover shadow-sm ring-1 ring-black/20"
          />
        </div>
      </div>
      <div className="flex items-center justify-between gap-3 px-4 sm:px-5 py-3 sm:py-4">
        <p className="text-xs text-navy/60">
          {t("card.cityLessons", { count: String(city.lessonsTotal) })}
        </p>
        <span className="inline-flex items-center gap-1 text-xs font-bold text-orange-700 group-hover:text-orange-800 transition-colors">
          {t("card.startTrip")}
          <svg className="w-3.5 h-3.5 group-hover:translate-x-0.5 transition-transform" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
          </svg>
        </span>
      </div>
    </Link>
  );
}

// Pick a sensible country flag for the city's badge. Spanish cities
// span multiple countries so we flag the actual country; French cities
// are either France or Canada; Spanish is Spain/MX/AR.
function countryToFlagForCity(country: string, fallback: string): string {
  const c = country.toLowerCase();
  if (c.includes("mex")) return "mx";
  if (c.includes("argent")) return "ar";
  if (c.includes("spain")) return "es";
  if (c.includes("france")) return "fr";
  if (c.includes("canada")) return "ca";
  return fallback;
}

function FeatureCard({
  iconPath,
  title,
  body,
}: {
  iconPath: string;
  title: string;
  body: string;
}) {
  return (
    <div className="bg-white border border-border rounded-2xl p-5 sm:p-6 hover:shadow-md hover:border-teal/40 transition-all">
      <div className="w-11 h-11 rounded-xl bg-teal-light text-teal-dark flex items-center justify-center mb-4">
        <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d={iconPath} />
        </svg>
      </div>
      <h3 className="text-base sm:text-lg font-bold text-navy mb-1.5">{title}</h3>
      <p className="text-sm text-navy/60 leading-relaxed">{body}</p>
    </div>
  );
}
