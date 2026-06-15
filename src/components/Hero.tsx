"use client";

import Link from "next/link";
import { useI18n } from "@/components/I18nProvider";

export default function Hero({
  hasProgress = false,
  isPremium = false,
}: {
  // If the user has any recorded progress in any language, the primary
  // CTA reads "Continue learning" instead of "Start learning". Resolved
  // server-side on the homepage and passed in as a prop.
  hasProgress?: boolean;
  // Premium subscribers see "View dashboard" as the primary CTA and the
  // pricing link is hidden — they've already paid.
  isPremium?: boolean;
}) {
  const { t } = useI18n();

  // CTA logic: premium subscribers jump straight to /dashboard.
  // Free returning learners continue from /learn. New visitors see the
  // "Start learning" funnel into /learn.
  const primaryHref = isPremium ? "/dashboard" : "/learn";
  const primaryLabelKey = isPremium
    ? "hero.viewDashboard"
    : hasProgress
      ? "hero.continueLearning"
      : "hero.startLearning";

  return (
    <section className="relative pt-12 sm:pt-20 lg:pt-24 pb-12 sm:pb-16 lg:pb-20 px-4 sm:px-6 text-center overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-b from-peach/40 via-peach-light/30 to-transparent pointer-events-none" />

      <div className="relative">
        <h1 className="text-[2.25rem] leading-[1.05] sm:text-5xl lg:text-6xl xl:text-7xl font-extrabold text-navy tracking-tight max-w-3xl mx-auto sm:leading-[1.1]">
          {t("hero.title1")}{" "}
          <span className="text-teal">{t("hero.title2")}</span>
        </h1>
        <p className="mt-5 sm:mt-6 text-base sm:text-lg lg:text-xl text-navy/60 max-w-2xl mx-auto leading-relaxed px-1">
          {t("hero.desc")}
        </p>
        <div className="mt-7 sm:mt-9 flex flex-col sm:flex-row items-stretch sm:items-center justify-center gap-3 max-w-md sm:max-w-none mx-auto">
          <Link
            href={primaryHref}
            className="inline-flex items-center justify-center gap-2 px-6 sm:px-7 py-3 sm:py-3.5 text-base font-semibold text-white bg-teal rounded-full hover:bg-teal-dark hover:shadow-lg active:scale-[0.98] transition-all"
          >
            {t(primaryLabelKey)}
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
          {!isPremium && (
            <Link
              href="/pricing"
              className="inline-flex items-center justify-center gap-2 px-5 sm:px-6 py-3 sm:py-3.5 text-base font-medium text-teal-dark hover:text-teal transition-colors"
            >
              {t("hero.viewPricing")}
            </Link>
          )}
        </div>
      </div>
    </section>
  );
}
