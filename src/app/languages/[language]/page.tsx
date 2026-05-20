import Link from "next/link";
import Image from "next/image";
import { notFound } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { createClient } from "@/lib/supabase/server";
import {
  getOverview,
  getAllOverviewSlugs,
  type LanguageOverview,
} from "@/lib/language-overviews";
import type { Difficulty } from "@/lib/languages";

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

const TIER_STYLES: Record<
  "Beginner" | "Intermediate" | "Advanced",
  { label: string; bg: string; accent: string }
> = {
  Beginner: {
    label: "Course 1",
    bg: "bg-gradient-to-b from-teal-light to-white",
    accent: "text-teal-dark",
  },
  Intermediate: {
    label: "Course 2",
    bg: "bg-gradient-to-b from-peach-light to-white",
    accent: "text-amber-700",
  },
  Advanced: {
    label: "Course 3",
    bg: "bg-gradient-to-b from-red-50 to-white",
    accent: "text-red-700",
  },
};

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
        <span className="text-2xl" aria-hidden>
          {related.flagEmoji}
        </span>
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
        <svg
          className="w-4 h-4"
          fill="none"
          stroke="currentColor"
          strokeWidth={2.5}
          viewBox="0 0 24 24"
        >
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

export default async function LanguageOverviewPage(
  props: PageProps<"/languages/[language]">,
) {
  const { language: slug } = await props.params;
  const overview = getOverview(slug);
  if (!overview) notFound();

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

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
              <svg
                className="w-4 h-4"
                fill="none"
                stroke="currentColor"
                strokeWidth={2}
                viewBox="0 0 24 24"
              >
                <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
              </svg>
              All languages
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
                  <span className="text-5xl" aria-hidden>
                    {overview.flagEmoji}
                  </span>
                </div>
                <h1 className="text-4xl sm:text-5xl font-bold text-navy tracking-tight mb-2">
                  Learn {overview.name}
                </h1>
                <p className="text-lg text-navy/60 mb-6">
                  <span className="italic">{overview.nativeName}</span> · {overview.speakers}
                </p>
                <div className="flex gap-6 mb-8">
                  <DifficultyBadge label="Grammar" level={overview.grammar} />
                  <DifficultyBadge label="Pronunciation" level={overview.pronunciation} />
                </div>
                <StartLearningCTA overview={overview} isLoggedIn={!!user} />
              </div>
            </div>
          </div>
        </section>

        {/* About */}
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-10">
            <div className="lg:col-span-2">
              <h2 className="text-2xl font-bold text-navy mb-3">
                About {overview.name}
              </h2>
              <p className="text-navy/70 leading-relaxed mb-6">{overview.about}</p>
              <div className="bg-white border border-border rounded-2xl p-5">
                <p className="text-xs font-semibold text-teal-dark uppercase tracking-wider mb-2">
                  Where it&apos;s spoken
                </p>
                <p className="text-sm text-navy/70 leading-relaxed">{overview.regions}</p>
              </div>
            </div>
            <div className="bg-white border border-border rounded-2xl p-6">
              <h3 className="text-sm font-semibold text-teal-dark uppercase tracking-wider mb-4">
                Interesting facts
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
              Why learn {overview.name}?
            </h2>
            <p className="text-navy/60 mb-8">
              Three reasons to make {overview.name} your next language.
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

        {/* Course preview */}
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
          <h2 className="text-2xl font-bold text-navy mb-2">Your learning path</h2>
          <p className="text-navy/60 mb-8">
            Three courses move you from your first word to fluent conversation.
          </p>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
            {overview.courses.map((course) => {
              const tier = TIER_STYLES[course.title];
              return (
                <div
                  key={course.title}
                  className={`rounded-2xl border border-border ${tier.bg} p-6`}
                >
                  <span
                    className={`text-xs font-bold uppercase tracking-wider ${tier.accent}`}
                  >
                    {tier.label}
                  </span>
                  <h3 className="text-xl font-bold text-navy mt-1 mb-3">{course.title}</h3>
                  <p className="text-sm text-navy/70 leading-relaxed mb-4">
                    {course.description}
                  </p>
                  <ul className="space-y-1.5">
                    {course.topics.map((topic) => (
                      <li
                        key={topic}
                        className="flex items-center gap-2 text-sm text-navy/70"
                      >
                        <svg
                          className="w-4 h-4 text-teal"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth={2.5}
                          viewBox="0 0 24 24"
                        >
                          <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                        </svg>
                        {topic}
                      </li>
                    ))}
                  </ul>
                </div>
              );
            })}
          </div>
          <div className="mt-10 flex justify-center">
            <StartLearningCTA overview={overview} isLoggedIn={!!user} />
          </div>
        </section>

        {/* Related */}
        <section className="bg-white border-t border-border">
          <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
            <h2 className="text-2xl font-bold text-navy mb-2">Related languages</h2>
            <p className="text-navy/60 mb-8">
              If {overview.name} interests you, you might also enjoy these.
            </p>
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
              {overview.related.map((slug) => (
                <RelatedCard key={slug} slug={slug} />
              ))}
            </div>
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
