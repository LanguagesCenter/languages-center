"use client";

import Link from "next/link";
import { useI18n } from "@/components/I18nProvider";

export default function Hero() {
  const { t } = useI18n();
  return (
    <section className="relative pt-20 pb-16 px-4 text-center overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-b from-peach/40 via-peach-light/30 to-transparent pointer-events-none" />

      <div className="relative">
        <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-navy tracking-tight max-w-3xl mx-auto leading-[1.1]">
          {t("hero.title1")}{" "}
          <span className="text-teal">{t("hero.title2")}</span>
        </h1>
        <p className="mt-6 text-lg text-navy/60 max-w-2xl mx-auto leading-relaxed">
          {t("hero.desc")}
        </p>
        <div className="mt-9 flex flex-col sm:flex-row items-center justify-center gap-3">
          <Link
            href="/learn"
            className="inline-flex items-center gap-2 px-7 py-3.5 text-base font-semibold text-white bg-teal rounded-full hover:bg-teal-dark hover:shadow-lg transition-all"
          >
            {t("hero.startLearning")}
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
          <Link
            href="/pricing"
            className="inline-flex items-center gap-2 px-6 py-3.5 text-base font-medium text-teal-dark hover:text-teal transition-colors"
          >
            {t("hero.viewPricing")}
          </Link>
        </div>
      </div>
    </section>
  );
}
