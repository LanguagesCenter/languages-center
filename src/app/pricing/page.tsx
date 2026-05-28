"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { createClient } from "@/lib/supabase/client";
import { useI18n } from "@/components/I18nProvider";
import HomeButton from "@/components/HomeButton";
import type { User } from "@supabase/supabase-js";

type Billing = "monthly" | "yearly";

export default function PricingPage() {
  const { t } = useI18n();
  const [user, setUser] = useState<User | null>(null);
  const [isPremium, setIsPremium] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [billing, setBilling] = useState<Billing>("yearly");
  const router = useRouter();
  const supabase = createClient();

  const premiumPrice = billing === "yearly" ? "$7.99" : "$9.99";
  const premiumPeriod = t("pricing.month");

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      setUser(user);
      setIsPremium(!!user?.user_metadata?.is_premium);
    });
  }, [supabase.auth]);

  async function handleSubscribe(withTrial: boolean) {
    if (!user) {
      router.push("/login");
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const res = await fetch("/api/checkout", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ plan: billing, withTrial }),
      });
      const data = await res.json();

      if (data.url) {
        window.location.href = data.url;
      } else {
        setError(data.error || "Failed to create checkout session.");
        setLoading(false);
      }
    } catch {
      setError("Something went wrong. Please try again.");
      setLoading(false);
    }
  }

  const freeFeatures = [
    t("pricing.feat.overview"),
    t("pricing.feat.ratings"),
    t("pricing.feat.community"),
  ];
  const freeExcluded = [
    t("pricing.feat.fullLessons"),
    t("pricing.feat.audio"),
    t("pricing.feat.progress"),
    t("pricing.feat.offline"),
  ];
  const premiumFeatures = [
    t("pricing.feat.everythingFree"),
    t("pricing.feat.fullLessons"),
    t("pricing.feat.audio"),
    t("pricing.feat.progress"),
    t("pricing.feat.offline"),
    t("pricing.feat.priority"),
  ];

  return (
    <div className="min-h-screen bg-background flex flex-col">
      {/* Header */}
      <div className="p-6 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <HomeButton />
          <Link href="/" className="flex items-center gap-2.5 w-fit">
            <Image
              src="/Logo fianl.jpg"
              alt="Languages Center logo"
              width={36}
              height={36}
              className="rounded-lg"
            />
            <span className="text-lg font-bold text-navy tracking-tight">
              Languages Center
            </span>
          </Link>
        </div>
        <Link
          href="/"
          className="inline-flex items-center gap-2 px-4 py-2 text-sm font-semibold text-teal-dark bg-teal-light rounded-full hover:bg-teal hover:text-white transition-colors"
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" d="M15 19l-7-7 7-7" />
          </svg>
          {t("pricing.backHome")}
        </Link>
      </div>

      {/* Content */}
      <div className="flex-1 flex flex-col items-center justify-center px-4 pb-20">
        <h1 className="text-3xl sm:text-4xl font-extrabold text-navy text-center tracking-tight mb-3">
          {t("pricing.title")}
        </h1>
        <p className="text-navy/50 text-center mb-8 max-w-md">
          {t("pricing.subtitle")}
        </p>

        {/* Monthly / Yearly toggle */}
        <div className="inline-flex items-center bg-white border border-border rounded-full p-1 mb-10 shadow-sm">
          <button
            type="button"
            onClick={() => setBilling("monthly")}
            className={`px-5 py-2 text-sm font-semibold rounded-full transition-colors ${
              billing === "monthly"
                ? "bg-teal text-white"
                : "text-navy/60 hover:text-navy"
            }`}
          >
            {t("pricing.toggle.monthly")}
          </button>
          <button
            type="button"
            onClick={() => setBilling("yearly")}
            className={`relative px-5 py-2 text-sm font-semibold rounded-full transition-colors ${
              billing === "yearly"
                ? "bg-teal text-white"
                : "text-navy/60 hover:text-navy"
            }`}
          >
            {t("pricing.toggle.yearly")}
            <span
              className={`ms-2 inline-block text-[10px] font-bold uppercase tracking-wider px-1.5 py-0.5 rounded-full ${
                billing === "yearly"
                  ? "bg-white text-teal-dark"
                  : "bg-peach-light text-peach-dark"
              }`}
            >
              {t("pricing.save20")}
            </span>
          </button>
        </div>

        {error && (
          <div className="w-full max-w-2xl mb-6 text-sm text-red-600 bg-red-50 border border-red-200 rounded-xl px-4 py-3 text-center">
            {error}
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-2xl">
          {/* Free plan */}
          <div className="relative rounded-2xl p-8 border border-border bg-white">
            <h2 className="text-lg font-bold text-navy mb-1">{t("pricing.free")}</h2>
            <p className="text-sm text-navy/50 mb-5">{t("pricing.freeDesc")}</p>

            <div className="flex items-baseline gap-1 mb-6">
              <span className="text-4xl font-extrabold text-navy">$0</span>
              <span className="text-sm text-navy/40">{t("pricing.forever")}</span>
            </div>

            <ul className="space-y-2.5 mb-8">
              {freeFeatures.map((feature) => (
                <li key={feature} className="flex items-center gap-2.5 text-sm text-navy/70">
                  <svg className="w-4 h-4 text-teal shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2.5}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                  </svg>
                  {feature}
                </li>
              ))}
              {freeExcluded.map((feature) => (
                <li key={feature} className="flex items-center gap-2.5 text-sm text-navy/30">
                  <svg className="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2.5}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                  {feature}
                </li>
              ))}
            </ul>

            <div className="w-full py-2.5 text-sm font-semibold text-center text-navy/40 bg-background rounded-xl border border-border">
              {t("pricing.cta.current")}
            </div>
          </div>

          {/* Premium plan */}
          <div className="relative rounded-2xl p-8 border border-teal bg-white shadow-lg">
            <div className="absolute -top-3 left-1/2 -translate-x-1/2 px-3 py-0.5 bg-teal text-white text-xs font-semibold rounded-full">
              {t("pricing.mostPopular")}
            </div>

            <h2 className="text-lg font-bold text-navy mb-1">{t("pricing.premium")}</h2>
            <p className="text-sm text-navy/50 mb-5">{t("pricing.premiumDesc")}</p>

            <div className="flex items-baseline gap-1 mb-1">
              <span className="text-4xl font-extrabold text-navy">{premiumPrice}</span>
              <span className="text-sm text-navy/40">{premiumPeriod}</span>
            </div>
            <p className="text-xs text-navy/50 mb-6 min-h-[2.5rem]">
              {billing === "yearly"
                ? t("pricing.yearlyBilling")
                : t("pricing.monthlyBilling")}
            </p>

            <ul className="space-y-2.5 mb-8">
              {premiumFeatures.map((feature) => (
                <li key={feature} className="flex items-center gap-2.5 text-sm text-navy/70">
                  <svg className="w-4 h-4 text-teal shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2.5}>
                    <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                  </svg>
                  {feature}
                </li>
              ))}
            </ul>

            {isPremium ? (
              <div className="w-full py-2.5 text-sm font-semibold text-center text-teal bg-teal-light rounded-xl">
                {t("pricing.cta.manage")}
              </div>
            ) : (
              <div className="space-y-2">
                <button
                  onClick={() => handleSubscribe(true)}
                  disabled={loading}
                  className="w-full py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {loading ? t("login.loading") : t("pricing.cta.startTrial")}
                </button>
                <button
                  onClick={() => handleSubscribe(false)}
                  disabled={loading}
                  className="w-full py-2.5 text-sm font-semibold text-teal-dark bg-white border border-teal rounded-xl hover:bg-teal-light transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {t("pricing.cta.startNow")}
                </button>
                <p className="text-[11px] text-navy/40 text-center pt-1">
                  {t("pricing.trial.cancelAnytime")}
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
