"use client";

import { useState, useRef, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { FLAG_CODES } from "@/lib/flag-codes";
import { isLanguageVisible } from "@/lib/languages";
import { useI18n } from "@/components/I18nProvider";
import { getLocalizedLanguageName, UI_LANG_NAMES } from "@/lib/i18n";
import { sortByPopularity } from "@/lib/language-proximity";
import LanguageSwitcher from "@/components/LanguageSwitcher";
import HomeButton from "@/components/HomeButton";
import type { User } from "@supabase/supabase-js";

interface NavbarLanguage {
  name: string;
  slug: string;
  countryCode: string;
}

// Cities per Traveler's Course language. Hardcoded in sync with
// CITY_META / traveler_courses — any additions here must also land in
// the DB (and vice versa). Kept client-side so the dropdown renders
// without a round-trip.
const TRIPS_BY_LANG: {
  slug: string;
  flag: string;
  cities: { city: string; citySlug: string; country: string; countryFlag: string }[];
}[] = [
  {
    slug: "spanish",
    flag: "es",
    cities: [
      { city: "Madrid", citySlug: "madrid", country: "Spain", countryFlag: "es" },
      { city: "Barcelona", citySlug: "barcelona", country: "Spain", countryFlag: "es" },
      { city: "Mexico City", citySlug: "mexico-city", country: "Mexico", countryFlag: "mx" },
      { city: "Buenos Aires", citySlug: "buenos-aires", country: "Argentina", countryFlag: "ar" },
    ],
  },
  {
    slug: "french",
    flag: "fr",
    cities: [
      { city: "Paris", citySlug: "paris", country: "France", countryFlag: "fr" },
      { city: "Lyon", citySlug: "lyon", country: "France", countryFlag: "fr" },
      { city: "Montreal", citySlug: "montreal", country: "Canada", countryFlag: "ca" },
    ],
  },
];

export default function Navbar() {
  const { t, lang: uiLang } = useI18n();
  const [tripsOpen, setTripsOpen] = useState(false);
  const [fluencyOpen, setFluencyOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [languages, setLanguages] = useState<NavbarLanguage[]>([]);
  const tripsRef = useRef<HTMLDivElement>(null);
  const fluencyRef = useRef<HTMLDivElement>(null);
  const userMenuRef = useRef<HTMLDivElement>(null);
  const router = useRouter();
  const supabase = createClient();

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      setUser(user);
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });

    supabase
      .from("languages")
      .select("name, code")
      .order("id")
      .then(({ data }) => {
        if (!data) return;
        const mapped = (data as { name: string; code: string }[])
          .filter((row) => isLanguageVisible(row.code))
          .map((row) => ({
            name: row.name,
            slug: row.code,
            countryCode: FLAG_CODES[row.code] ?? row.code,
          }));
        setLanguages(sortByPopularity(mapped));
      });

    return () => subscription.unsubscribe();
  }, [supabase.auth]);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (tripsRef.current && !tripsRef.current.contains(e.target as Node)) {
        setTripsOpen(false);
      }
      if (fluencyRef.current && !fluencyRef.current.contains(e.target as Node)) {
        setFluencyOpen(false);
      }
      if (userMenuRef.current && !userMenuRef.current.contains(e.target as Node)) {
        setUserMenuOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Freeze body scroll while the Fluency Course dropdown is open — same
  // reason as the old Languages dropdown: wheel events leak otherwise.
  useEffect(() => {
    if (!fluencyOpen) return;
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prevOverflow;
    };
  }, [fluencyOpen]);

  async function handleLogout() {
    await supabase.auth.signOut();
    setUserMenuOpen(false);
    router.refresh();
  }

  return (
    <nav className="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-border">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Home button + logo */}
          <div className="flex items-center gap-3">
            <HomeButton />
            <Link href="/" className="flex items-center gap-2.5">
              <Image
                src="/Logo fianl.jpg"
                alt="Languages Center logo"
                width={40}
                height={40}
                className="rounded-lg"
              />
              <span className="text-xl font-bold text-navy tracking-tight">
                Languages Center
              </span>
            </Link>
          </div>

          {/* Center nav — Trips first, Fluency Course second, Phrase
              Lookup third, Pricing fourth. Everything that used to live
              under the old "Travel" dropdown now lives under Trips. */}
          <div className="hidden md:flex items-center gap-8">
            {/* Trips dropdown — cities grouped by language. This is the
                new primary entry point. */}
            <div className="relative" ref={tripsRef}>
              <button
                onClick={() => setTripsOpen(!tripsOpen)}
                className="inline-flex items-center gap-1.5 text-sm font-semibold text-navy hover:text-orange-600 transition-colors"
              >
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24" aria-hidden>
                  <path d="M21 16v-2l-8-5V3.5a1.5 1.5 0 00-3 0V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1L15 22v-1.5L13 19v-5.5L21 16z" />
                </svg>
                {t("nav.trips")}
                <svg
                  className={`w-4 h-4 transition-transform ${tripsOpen ? "rotate-180" : ""}`}
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              {tripsOpen && (
                <div className="absolute top-full start-0 mt-2 w-72 bg-white rounded-xl shadow-xl border border-border py-2 max-h-[70vh] overflow-y-auto">
                  <div className="px-4 pt-1 pb-1.5 flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-wider text-orange-700">
                    <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24" aria-hidden>
                      <path strokeLinecap="round" strokeLinejoin="round" d="M17.657 16.657L13.414 20.9a2 2 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                      <path strokeLinecap="round" strokeLinejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    {t("nav.tripsHeading")}
                  </div>
                  {TRIPS_BY_LANG.map((group) => (
                    <div key={group.slug} className="pt-1">
                      <Link
                        href={`/learn/${group.slug}/start`}
                        onClick={() => setTripsOpen(false)}
                        className="flex items-center gap-3 px-4 py-2 text-sm font-semibold text-navy hover:bg-orange-50 hover:text-orange-700 transition-colors"
                      >
                        <span className="relative inline-block w-6 h-[18px] overflow-hidden rounded-sm shrink-0 ring-1 ring-black/5">
                          <Image
                            src={`https://flagcdn.com/w40/${group.flag}.png`}
                            alt=""
                            fill
                            sizes="24px"
                            className="object-cover"
                            unoptimized
                          />
                        </span>
                        {getLocalizedLanguageName(
                          group.slug,
                          uiLang,
                          group.slug === "spanish" ? "Spanish" : "French",
                        )}
                      </Link>
                      {group.cities.map((c) => (
                        <Link
                          key={c.citySlug}
                          href={`/learn/${group.slug}/travel/${c.citySlug}`}
                          onClick={() => setTripsOpen(false)}
                          className="flex items-center gap-3 pl-11 pr-4 py-1.5 text-sm text-navy/70 hover:bg-orange-50 hover:text-orange-700 transition-colors"
                        >
                          <span className="relative inline-block w-5 h-[15px] overflow-hidden rounded-sm shrink-0 ring-1 ring-black/5">
                            <Image
                              src={`https://flagcdn.com/w40/${c.countryFlag}.png`}
                              alt=""
                              fill
                              sizes="20px"
                              className="object-cover"
                              unoptimized
                            />
                          </span>
                          {c.city}
                        </Link>
                      ))}
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Fluency Course dropdown — every language, routing to the
                CEFR course page. This is the renamed version of the old
                "Languages" dropdown; the phrasebook sub-link is gone
                because Phrase Lookup now has its own top-level entry. */}
            <div className="relative" ref={fluencyRef}>
              <button
                onClick={() => setFluencyOpen(!fluencyOpen)}
                className="flex items-center gap-1 text-sm font-medium text-navy/70 hover:text-teal transition-colors"
              >
                {t("nav.fluencyCourse")}
                <svg
                  className={`w-4 h-4 transition-transform ${fluencyOpen ? "rotate-180" : ""}`}
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              {fluencyOpen && (
                <div
                  className="absolute top-full start-0 mt-2 w-72 max-w-[calc(100vw-2rem)] bg-white rounded-xl shadow-xl border border-border py-2 max-h-80 overflow-y-auto overscroll-contain"
                  onWheel={(e) => e.stopPropagation()}
                  onTouchMove={(e) => e.stopPropagation()}
                >
                  <div className="px-4 pt-1 pb-1.5 text-[11px] font-bold uppercase tracking-wider text-teal-dark">
                    {t("nav.fluencyHeading")}
                  </div>
                  {languages
                    .filter(
                      (l) => l.slug !== (UI_LANG_NAMES[uiLang]?.slug ?? null),
                    )
                    .map((lang) => (
                      <Link
                        key={lang.slug}
                        href={`/learn/${lang.slug}`}
                        onClick={() => setFluencyOpen(false)}
                        className="flex items-center gap-3 px-4 py-2 text-sm text-navy/80 hover:bg-peach-light hover:text-teal-dark transition-colors"
                      >
                        <span className="relative inline-block w-6 h-[18px] overflow-hidden rounded-sm shrink-0 ring-1 ring-black/5">
                          <Image
                            src={`https://flagcdn.com/w40/${lang.countryCode}.png`}
                            alt={`${lang.name} flag`}
                            fill
                            sizes="24px"
                            className="object-cover"
                            unoptimized
                          />
                        </span>
                        {getLocalizedLanguageName(lang.slug, uiLang, lang.name)}
                      </Link>
                    ))}
                </div>
              )}
            </div>

            {/* Phrase Lookup — tertiary, now a top-level link. Only two
                languages have one today, so instead of a dropdown we
                drop them inline (Spanish, French). Click Spanish by
                default; the French variant is one more click away via
                the homepage/overview. */}
            <Link
              href="/languages/spanish/travel-guide"
              className="inline-flex items-center gap-1.5 text-sm font-medium text-navy/70 hover:text-blue-700 transition-colors"
            >
              <svg className="w-4 h-4 text-blue-700" fill="currentColor" viewBox="0 0 24 24" aria-hidden>
                <path d="M5 3a2 2 0 00-2 2v16l7-4 7 4V5a2 2 0 00-2-2H5z" />
              </svg>
              {t("nav.phraseLookup")}
            </Link>

            {/* Pricing */}
            <Link
              href="/pricing"
              className="text-sm font-medium text-navy/70 hover:text-teal transition-colors"
            >
              {t("nav.pricing")}
            </Link>
          </div>

          {/* Auth + UI lang switcher */}
          <div className="flex items-center gap-3">
            <LanguageSwitcher />
            {user ? (
              (() => {
                const fullName = (user.user_metadata?.full_name as string | undefined)?.trim();
                const displayLabel = fullName || user.email || "";
                const avatarChar = (fullName || user.email || "?")[0]?.toUpperCase() ?? "?";
                return (
                  <div className="relative" ref={userMenuRef}>
                    <button
                      type="button"
                      onClick={() => setUserMenuOpen(!userMenuOpen)}
                      className="flex items-center gap-2 h-10 pl-1 pr-3 text-sm font-medium text-navy/70 hover:text-teal rounded-full border border-border hover:border-teal/30 transition-colors"
                    >
                      <span className="w-8 h-8 rounded-full bg-teal text-white flex items-center justify-center text-sm font-semibold">
                        {avatarChar}
                      </span>
                      <span className="hidden sm:inline max-w-[180px] truncate">
                        {displayLabel}
                      </span>
                      <svg
                        className={`w-3.5 h-3.5 transition-transform ${userMenuOpen ? "rotate-180" : ""}`}
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                      </svg>
                    </button>
                    {userMenuOpen && (
                      <div className="absolute right-0 top-full mt-2 w-56 bg-white rounded-xl shadow-lg border border-border py-2">
                        <div className="px-4 py-2 border-b border-border">
                          <p className="text-xs text-navy/40">{t("nav.signedInAs")}</p>
                          <p className="text-sm text-navy font-medium truncate">
                            {fullName || user.email}
                          </p>
                          {fullName && (
                            <p className="text-xs text-navy/40 truncate">{user.email}</p>
                          )}
                        </div>
                        <Link
                          href="/profile"
                          onClick={() => setUserMenuOpen(false)}
                          className="block w-full px-4 py-2 text-sm text-navy/80 hover:bg-peach-light hover:text-teal-dark transition-colors"
                        >
                          {t("nav.profile")}
                        </Link>
                        <Link
                          href="/profile"
                          onClick={() => setUserMenuOpen(false)}
                          className="block w-full px-4 py-2 text-sm text-navy/80 hover:bg-peach-light hover:text-teal-dark transition-colors"
                        >
                          {t("nav.settings")}
                        </Link>
                        <Link
                          href="/profile#certifications"
                          onClick={() => setUserMenuOpen(false)}
                          className="block w-full px-4 py-2 text-sm text-navy/80 hover:bg-peach-light hover:text-teal-dark transition-colors"
                        >
                          {t("nav.certificates")}
                        </Link>
                        <div className="border-t border-border my-1" />
                        <button
                          type="button"
                          onClick={handleLogout}
                          className="w-full text-start px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors"
                        >
                          {t("nav.logout")}
                        </button>
                      </div>
                    )}
                  </div>
                );
              })()
            ) : (
              <Link
                href="/login"
                className="inline-flex items-center h-10 px-5 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark hover:shadow-md transition-all duration-200"
              >
                {t("nav.signIn")}
              </Link>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
}

