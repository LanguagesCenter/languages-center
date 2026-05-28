"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import { createClient } from "@/lib/supabase/client";
import { useI18n } from "@/components/I18nProvider";
import HomeButton from "@/components/HomeButton";
import type { User } from "@supabase/supabase-js";

export default function PricingPage() {
  const { t } = useI18n();
  const [user, setUser] = useState<User | null>(null);
  const [isPremium, setIsPremium] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();
  const supabase = createClient();

  const plans = [
    {
      name: t("pricing.free"),
      price: "$0",
      period: t("pricing.forever"),
      description: t("pricing.freeDesc"),
      features: [
        t("pricing.feat.overview"),
        t("pricing.feat.ratings"),
        t("pricing.feat.community"),
      ],
      excluded: [
        t("pricing.feat.fullLessons"),
        t("pricing.feat.audio"),
        t("pricing.feat.progress"),
        t("pricing.feat.offline"),
      ],
      highlighted: false,
    },
    {
      name: t("pricing.premium"),
      price: "$9.99",
      period: t("pricing.month"),
      description: t("pricing.premiumDesc"),
      features: [
        t("pricing.feat.everythingFree"),
        t("pricing.feat.fullLessons"),
        t("pricing.feat.audio"),
        t("pricing.feat.progress"),
        t("pricing.feat.offline"),
        t("pricing.feat.priority"),
      ],
      excluded: [],
      highlighted: true,
    },
  ];

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      setUser(user);
      setIsPremium(!!user?.user_metadata?.is_premium);
    });
  }, [supabase.auth]);

  async function handleSubscribe() {
    if (!user) {
      router.push("/login");
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const res = await fetch("/api/checkout", { method: "POST" });
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
        <p className="text-navy/50 text-center mb-12 max-w-md">
          {t("pricing.subtitle")}
        </p>

        {error && (
          <div className="w-full max-w-2xl mb-6 text-sm text-red-600 bg-red-50 border border-red-200 rounded-xl px-4 py-3 text-center">
            {error}
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-2xl">
          {plans.map((plan) => (
            <div
              key={plan.name}
              className={`relative rounded-2xl p-8 border ${
                plan.highlighted
                  ? "border-teal bg-white shadow-lg"
                  : "border-border bg-white"
              }`}
            >
              {plan.highlighted && (
                <div className="absolute -top-3 left-1/2 -translate-x-1/2 px-3 py-0.5 bg-teal text-white text-xs font-semibold rounded-full">
                  Most popular
                </div>
              )}

              <h2 className="text-lg font-bold text-navy mb-1">{plan.name}</h2>
              <p className="text-sm text-navy/50 mb-5">{plan.description}</p>

              <div className="flex items-baseline gap-1 mb-6">
                <span className="text-4xl font-extrabold text-navy">
                  {plan.price}
                </span>
                <span className="text-sm text-navy/40">{plan.period}</span>
              </div>

              {/* Features */}
              <ul className="space-y-2.5 mb-8">
                {plan.features.map((feature) => (
                  <li key={feature} className="flex items-center gap-2.5 text-sm text-navy/70">
                    <svg className="w-4 h-4 text-teal shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2.5}>
                      <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                    </svg>
                    {feature}
                  </li>
                ))}
                {plan.excluded.map((feature) => (
                  <li key={feature} className="flex items-center gap-2.5 text-sm text-navy/30">
                    <svg className="w-4 h-4 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={2.5}>
                      <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                    {feature}
                  </li>
                ))}
              </ul>

              {plan.highlighted ? (
                isPremium ? (
                  <div className="w-full py-2.5 text-sm font-semibold text-center text-teal bg-teal-light rounded-xl">
                    {t("pricing.cta.manage")}
                  </div>
                ) : (
                  <button
                    onClick={handleSubscribe}
                    disabled={loading}
                    className="w-full py-2.5 text-sm font-semibold text-white bg-teal rounded-xl hover:bg-teal-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {loading ? t("login.loading") : t("pricing.cta.subscribe")}
                  </button>
                )
              ) : (
                <div className="w-full py-2.5 text-sm font-semibold text-center text-navy/40 bg-background rounded-xl border border-border">
                  {t("pricing.cta.current")}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
