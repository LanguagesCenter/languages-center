import Link from "next/link";
import Image from "next/image";
import { notFound } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { getLanguageBySlug, getArticlesForLanguage } from "@/lib/learn";
import { getOverview } from "@/lib/language-overviews";

import { FLAG_CODES } from "@/lib/flag-codes";

const LEVEL_PILL: Record<string, string> = {
  A1: "bg-emerald-50 text-emerald-700 ring-emerald-200",
  A2: "bg-teal-light text-teal-dark ring-teal/30",
  B1: "bg-amber-50 text-amber-800 ring-amber-200",
  B2: "bg-orange-50 text-orange-800 ring-orange-200",
  C1: "bg-rose-50 text-rose-800 ring-rose-200",
};

export async function generateMetadata(
  props: PageProps<"/languages/[language]/articles">,
) {
  const { language } = await props.params;
  const overview = getOverview(language);
  return {
    title: overview
      ? `${overview.name} Articles — Languages Center`
      : "Articles — Languages Center",
  };
}

export default async function ArticlesPage(
  props: PageProps<"/languages/[language]/articles">,
) {
  const { language: slug } = await props.params;
  const language = await getLanguageBySlug(slug);
  if (!language) notFound();
  const articles = await getArticlesForLanguage(language.id);
  const flagCode = FLAG_CODES[language.code] ?? language.code;

  return (
    <>
      <Navbar />
      <main className="flex-1">
        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-8">
          <Link
            href={`/languages/${slug}`}
            className="inline-flex items-center gap-1.5 text-sm text-navy/60 hover:text-teal transition-colors mb-6"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
            Back to {language.name}
          </Link>
          <div className="flex items-center gap-4">
            <Image
              src={`https://flagcdn.com/w80/${flagCode}.png`}
              alt={`${language.name} flag`}
              width={56}
              height={42}
              className="rounded-md object-cover shadow-sm"
            />
            <div>
              <h1 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight">
                {language.name} Articles
              </h1>
              <p className="text-sm text-navy/60 mt-1">
                Short reads at every level, with full English translations.
              </p>
            </div>
          </div>
        </section>

        <section className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pb-20">
          {articles.length === 0 ? (
            <p className="text-sm text-navy/50">
              No articles yet for {language.name}. Check back soon.
            </p>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
              {articles.map((article) => {
                const pill = LEVEL_PILL[article.level] ?? LEVEL_PILL.A1;
                return (
                  <Link
                    key={article.id}
                    href={`/languages/${slug}/articles/${article.slug}`}
                    className="group bg-white border border-border rounded-2xl p-6 hover:border-teal/40 hover:shadow-md hover:-translate-y-0.5 transition-all flex flex-col"
                  >
                    <div className="flex items-center justify-between mb-4">
                      <span className={`inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ${pill}`}>
                        {article.level}
                      </span>
                      <span className="inline-flex items-center gap-1 text-xs text-navy/50">
                        <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                        </svg>
                        {article.reading_minutes} min
                      </span>
                    </div>
                    <h3 className="text-lg font-semibold text-navy mb-1 group-hover:text-teal transition-colors">
                      {article.title}
                    </h3>
                    <p className="text-sm text-navy/50 mb-4 italic">
                      {article.title_english}
                    </p>
                    <p className="text-sm text-navy/60 line-clamp-3 leading-relaxed flex-1">
                      {article.content_target.split(".").slice(0, 2).join(".")}…
                    </p>
                    <span className="mt-4 inline-flex items-center gap-1 text-sm font-semibold text-teal group-hover:text-teal-dark transition-colors">
                      Read article
                      <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                      </svg>
                    </span>
                  </Link>
                );
              })}
            </div>
          )}
        </section>
      </main>
      <Footer />
    </>
  );
}
