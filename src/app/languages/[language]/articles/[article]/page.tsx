import Link from "next/link";
import { notFound } from "next/navigation";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import { getLanguageBySlug, getArticleBySlug } from "@/lib/learn";

const LEVEL_PILL: Record<string, string> = {
  A1: "bg-emerald-50 text-emerald-700 ring-emerald-200",
  A2: "bg-teal-light text-teal-dark ring-teal/30",
  B1: "bg-amber-50 text-amber-800 ring-amber-200",
  B2: "bg-orange-50 text-orange-800 ring-orange-200",
  C1: "bg-rose-50 text-rose-800 ring-rose-200",
};

function paragraphs(text: string) {
  return text
    .split(/\n+/)
    .map((p) => p.trim())
    .filter(Boolean);
}

export default async function ArticleDetailPage(
  props: PageProps<"/languages/[language]/articles/[article]">,
) {
  const { language: slug, article: articleSlug } = await props.params;
  const language = await getLanguageBySlug(slug);
  if (!language) notFound();
  const article = await getArticleBySlug(language.id, articleSlug);
  if (!article) notFound();

  const pill = LEVEL_PILL[article.level] ?? LEVEL_PILL.A1;
  const targetParas = paragraphs(article.content_target);
  const englishParas = paragraphs(article.content_english);

  return (
    <>
      <Navbar />
      <main className="flex-1">
        <article className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 pt-10 pb-20">
          <Link
            href={`/languages/${slug}/articles`}
            className="inline-flex items-center gap-1.5 text-sm text-navy/60 hover:text-teal transition-colors mb-6"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
            </svg>
            All {language.name} articles
          </Link>

          <div className="flex items-center gap-3 mb-4">
            <span className={`inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold ring-1 ${pill}`}>
              {article.level}
            </span>
            <span className="text-xs text-navy/40">·</span>
            <span className="inline-flex items-center gap-1 text-xs text-navy/50">
              <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
              </svg>
              {article.reading_minutes} min read
            </span>
          </div>
          <h1 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight mb-1">
            {article.title}
          </h1>
          <p className="text-lg text-navy/50 italic mb-10">{article.title_english}</p>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 md:gap-10">
            <div>
              <p className="text-xs font-semibold uppercase tracking-wider text-teal-dark mb-3">
                {language.name}
              </p>
              <div className="prose prose-sm max-w-none text-navy/80 leading-relaxed space-y-4">
                {targetParas.map((p, i) => (
                  <p key={i}>{p}</p>
                ))}
              </div>
            </div>
            <div className="md:border-l md:border-border md:pl-8 lg:pl-10">
              <p className="text-xs font-semibold uppercase tracking-wider text-navy/40 mb-3">
                English translation
              </p>
              <div className="prose prose-sm max-w-none text-navy/70 leading-relaxed space-y-4">
                {englishParas.map((p, i) => (
                  <p key={i}>{p}</p>
                ))}
              </div>
            </div>
          </div>
        </article>
      </main>
      <Footer />
    </>
  );
}
