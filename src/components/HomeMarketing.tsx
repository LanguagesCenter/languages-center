import Link from "next/link";
import Image from "next/image";
import LanguageGrid, { type LanguageGridItem } from "@/components/LanguageGrid";

export interface HomeMarketingProps {
  langs: LanguageGridItem[];
  startedSlugsInOrder: string[];
  isPremium: boolean;
  travelerCompletedCounts: Record<string, number>;
}

// Marketing homepage — anonymous visitors and signed-in users who
// haven't completed anything yet. Returning learners get
// HomePersonalized instead; the split is done in page.tsx.
export default function HomeMarketing({
  langs,
  startedSlugsInOrder,
  isPremium,
  travelerCompletedCounts,
}: HomeMarketingProps) {
  return (
    <main className="flex-1">
      {/* Hero */}
      <section className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-peach/50 via-peach-light/40 to-white pointer-events-none" />
        <div className="absolute top-20 -right-20 w-80 h-80 rounded-full bg-teal/10 blur-3xl pointer-events-none" />
        <div className="absolute -bottom-24 -left-16 w-96 h-96 rounded-full bg-amber-300/20 blur-3xl pointer-events-none" />
        <div className="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-14 sm:pt-20 lg:pt-28 pb-14 sm:pb-20 text-center">
          <span className="inline-flex items-center gap-2 rounded-full bg-white/70 border border-teal/20 backdrop-blur px-3 py-1 text-xs font-semibold text-teal-dark tracking-wide shadow-sm">
            <span className="w-1.5 h-1.5 rounded-full bg-teal animate-pulse" />
            Now teaching Spanish and French
          </span>
          <h1 className="mt-6 text-4xl sm:text-6xl lg:text-7xl font-extrabold text-navy tracking-tight leading-[1.05]">
            Learn languages that <span className="text-teal">actually stick.</span>
          </h1>
          <p className="mt-5 sm:mt-6 text-base sm:text-lg lg:text-xl text-navy/60 max-w-2xl mx-auto leading-relaxed">
            CEFR-aligned lessons, native-accent audio, AI feedback on your
            speaking and writing — from your first &ldquo;hello&rdquo; all the way to
            fluent conversation.
          </p>
          <div className="mt-8 sm:mt-10 flex flex-col sm:flex-row items-stretch sm:items-center justify-center gap-3 max-w-md sm:max-w-none mx-auto">
            <Link
              href="/login"
              className="inline-flex items-center justify-center gap-2 px-7 py-3.5 text-base font-semibold text-white bg-teal rounded-full hover:bg-teal-dark hover:shadow-lg active:scale-[0.98] transition-all"
            >
              Start learning for free
              <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </Link>
            {!isPremium && (
              <Link
                href="/pricing"
                className="inline-flex items-center justify-center gap-2 px-6 py-3.5 text-base font-medium text-teal-dark hover:text-teal transition-colors"
              >
                View pricing
              </Link>
            )}
          </div>
          <p className="mt-4 text-xs text-navy/40">
            No credit card required · Free forever tier
          </p>
        </div>
      </section>

      {/* Featured languages — anchored below the hero so first-time
          visitors can immediately see what's on offer. */}
      <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-4 pb-14 sm:pb-16">
        <div className="flex items-baseline justify-between mb-5">
          <div>
            <h2 className="text-2xl sm:text-3xl font-bold text-navy tracking-tight">
              Pick a language and start today
            </h2>
            <p className="text-sm sm:text-base text-navy/60 mt-1">
              Two full courses, A1 through C1, with placement tests included.
            </p>
          </div>
        </div>
        <LanguageGrid
          languages={langs}
          startedSlugsInOrder={startedSlugsInOrder}
          travelerCompletedCounts={travelerCompletedCounts}
        />
      </section>

      {/* Why Languages Center */}
      <section className="bg-white border-y border-border">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-14 sm:py-20">
          <div className="text-center max-w-2xl mx-auto mb-10 sm:mb-12">
            <p className="text-xs font-semibold uppercase tracking-[0.18em] text-teal-dark mb-2">
              Why Languages Center
            </p>
            <h2 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight">
              Built for real fluency, not streak points
            </h2>
            <p className="text-base sm:text-lg text-navy/60 mt-3">
              Every feature is tuned toward one goal: getting you comfortable
              speaking, reading, listening and writing in your target
              language.
            </p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-5">
            <FeatureCard
              iconPath="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"
              title="CEFR-aligned curriculum"
              body="A1 through C1 courses that mirror the same framework universities and employers use worldwide."
            />
            <FeatureCard
              iconPath="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
              title="Placement exams"
              body="A 15-minute test drops you at the right level from day one — no re-learning the alphabet if you don't need to."
            />
            <FeatureCard
              iconPath="M8 10h.01M12 10h.01M16 10h.01M21 12c0 4.418-4.03 8-9 8a9.86 9.86 0 01-4-.8L3 20l1.3-3.9A7.94 7.94 0 013 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
              title="AI-powered feedback"
              body="Every speaking, writing and grammar answer gets instant, personalized coaching — the kind you'd expect from a real tutor."
            />
            <FeatureCard
              iconPath="M3 10v4a1 1 0 001 1h3l4.29 4.29a1 1 0 001.71-.71V5.42a1 1 0 00-1.71-.71L7 9H4a1 1 0 00-1 1zm13.5 2a4.5 4.5 0 00-2.5-4.03v8.05A4.5 4.5 0 0016.5 12z"
              title="Native-accent audio"
              body="Every phrase, dialogue and lesson plays with a native voice, so you're training your ear from the very first session."
            />
          </div>
        </div>
      </section>

      {/* Feature highlights — three big cards spotlighting the app's most
          distinctive tools. */}
      <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-14 sm:py-20">
        <div className="text-center max-w-2xl mx-auto mb-10 sm:mb-12">
          <p className="text-xs font-semibold uppercase tracking-[0.18em] text-teal-dark mb-2">
            Inside the course
          </p>
          <h2 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight">
            More than flashcards
          </h2>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          <HighlightCard
            eyebrow="Speak with confidence"
            title="Speaking practice with instant coaching"
            body="Record yourself completing prompts and get scored on pronunciation, fluency and grammar — with concrete tips to improve."
            accent="teal"
          />
          <HighlightCard
            eyebrow="See where you stand"
            title="Placement + level certificates"
            body="Take a placement exam to jump straight to your level, or complete a level to earn a downloadable certificate."
            accent="teal"
          />
        </div>
      </section>

      {/* Closing CTA — one final push. */}
      <section className="bg-gradient-to-br from-teal to-teal-dark text-white">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-14 sm:py-20 text-center">
          <h2 className="text-3xl sm:text-4xl font-bold tracking-tight">
            Ready when you are.
          </h2>
          <p className="mt-3 text-base sm:text-lg text-white/85 max-w-xl mx-auto">
            Sign up in seconds, take a placement test, and get your first
            lesson recommended for you.
          </p>
          <div className="mt-8 flex flex-col sm:flex-row items-stretch sm:items-center justify-center gap-3 max-w-md sm:max-w-none mx-auto">
            <Link
              href="/login"
              className="inline-flex items-center justify-center gap-2 px-7 py-3.5 text-base font-semibold text-teal-dark bg-white rounded-full hover:bg-white/90 hover:shadow-lg active:scale-[0.98] transition-all"
            >
              Start learning for free
              <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </Link>
            {!isPremium && (
              <Link
                href="/pricing"
                className="inline-flex items-center justify-center gap-2 px-6 py-3.5 text-base font-medium text-white/85 hover:text-white transition-colors"
              >
                Compare plans
              </Link>
            )}
          </div>
        </div>
      </section>
    </main>
  );
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

function HighlightCard({
  eyebrow,
  title,
  body,
  accent,
  href,
  hrefLabel,
}: {
  eyebrow: string;
  title: string;
  body: string;
  accent: "teal" | "amber";
  href?: string;
  hrefLabel?: string;
}) {
  const border = accent === "amber" ? "border-amber-300/70" : "border-teal/30";
  const bg =
    accent === "amber"
      ? "bg-gradient-to-br from-amber-50 via-orange-50 to-white"
      : "bg-gradient-to-br from-teal-light/70 to-white";
  const eyebrowColor = accent === "amber" ? "text-amber-800" : "text-teal-dark";
  const linkColor =
    accent === "amber"
      ? "text-amber-800 hover:text-amber-900"
      : "text-teal-dark hover:text-teal";
  const flag =
    accent === "amber" ? (
      <Image
        src="https://flagcdn.com/w80/es.png"
        alt=""
        width={40}
        height={30}
        className="rounded-sm object-cover shadow-sm ring-1 ring-black/5"
      />
    ) : null;
  return (
    <div className={`${bg} border ${border} rounded-2xl p-5 sm:p-6 shadow-sm`}>
      <div className="flex items-start justify-between gap-3 mb-3">
        <p className={`text-[11px] font-semibold uppercase tracking-[0.14em] ${eyebrowColor}`}>
          {eyebrow}
        </p>
        {flag}
      </div>
      <h3 className="text-lg sm:text-xl font-bold text-navy leading-snug">{title}</h3>
      <p className="text-sm text-navy/70 mt-2 leading-relaxed">{body}</p>
      {href && (
        <Link
          href={href}
          className={`mt-4 inline-flex items-center gap-1 text-sm font-semibold ${linkColor} transition-colors`}
        >
          {hrefLabel}
          <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
          </svg>
        </Link>
      )}
    </div>
  );
}
