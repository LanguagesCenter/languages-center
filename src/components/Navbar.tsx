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
// CITY_META / traveler_courses so the Trips dropdown renders without
// a DB round-trip. New rows must land in both places.
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

// Shared Tailwind class for every top-level nav item (Trips, Fluency
// Course, Phrase Lookup, Pricing). Keeping this in one constant is the
// only way to guarantee the four items don't drift — each item must
// render identically so the user can't tell which one was built first.
const NAV_LINK = [
  "inline-flex items-center gap-1 h-10 text-sm font-medium",
  "text-navy/70 hover:text-teal transition-colors whitespace-nowrap",
].join(" ");

// Chevron renders at the same size + same gap-from-label on every nav
// item that drops down. Non-dropdown items (Phrase Lookup, Pricing)
// get no chevron and no icon — matching the "all or none" rule.
function NavChevron({ open }: { open: boolean }) {
  return (
    <svg
      className={`w-3.5 h-3.5 transition-transform ${open ? "rotate-180" : ""}`}
      fill="none"
      stroke="currentColor"
      viewBox="0 0 24 24"
      aria-hidden
    >
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
    </svg>
  );
}

export default function Navbar() {
  const { t, lang: uiLang } = useI18n();
  const [tripsOpen, setTripsOpen] = useState(false);
  const [fluencyOpen, setFluencyOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  // Mobile drawer state. `mobileOpen` toggles the hamburger panel;
  // `mobileTripsOpen`/`mobileFluencyOpen` drive the accordion rows
  // inside it. These are separate from the desktop dropdowns because
  // the hamburger panel is only rendered below `lg`.
  const [mobileOpen, setMobileOpen] = useState(false);
  const [mobileTripsOpen, setMobileTripsOpen] = useState(false);
  const [mobileFluencyOpen, setMobileFluencyOpen] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [languages, setLanguages] = useState<NavbarLanguage[]>([]);
  const tripsRef = useRef<HTMLDivElement>(null);
  const fluencyRef = useRef<HTMLDivElement>(null);
  const userMenuRef = useRef<HTMLDivElement>(null);
  const hamburgerRef = useRef<HTMLButtonElement>(null);
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

  // Freeze body scroll while any overlay is open. Without this, wheel
  // events bleed through to the page underneath the Fluency dropdown
  // and the mobile drawer.
  useEffect(() => {
    const anyOpen = fluencyOpen || mobileOpen;
    if (!anyOpen) return;
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prevOverflow;
    };
  }, [fluencyOpen, mobileOpen]);

  // Escape closes the mobile drawer. Keeping it scoped to the drawer
  // avoids fighting with other Escape handlers on nested pages.
  useEffect(() => {
    if (!mobileOpen) return;
    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") {
        setMobileOpen(false);
        // Return focus to the hamburger so keyboard users keep their
        // place in the tab order.
        hamburgerRef.current?.focus();
      }
    }
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [mobileOpen]);

  async function handleLogout() {
    await supabase.auth.signOut();
    setUserMenuOpen(false);
    router.refresh();
  }

  // Close the mobile drawer on navigation. Used by every link inside
  // the drawer so a tap closes it before the destination loads.
  function closeMobile() {
    setMobileOpen(false);
    setMobileTripsOpen(false);
    setMobileFluencyOpen(false);
  }

  return (
    <nav className="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-border">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16 gap-3">
          {/* Home button + logo. Logo text truncates / disappears on
              small screens so it can never force the nav to wrap. */}
          <div className="flex items-center gap-3 min-w-0">
            <HomeButton />
            <Link href="/" className="flex items-center gap-2.5 min-w-0">
              <Image
                src="/Logo fianl.jpg"
                alt="Languages Center logo"
                width={40}
                height={40}
                className="rounded-lg shrink-0"
              />
              <span className="hidden sm:inline text-xl font-bold text-navy tracking-tight truncate">
                Languages Center
              </span>
            </Link>
          </div>

          {/* Center nav — only at xl+ (1280px) where every supported
              language's labels fit on one line without crowding. Long
              translations (Russian "Курс свободного владения", German
              "Phrasen-Nachschlag") need the full width; below xl we
              collapse into the hamburger. All four items share
              NAV_LINK so they can't drift. Trips and Fluency have
              chevrons (dropdowns); Phrase Lookup and Pricing don't.
              No icons on any of them — the "all or none" rule. gap-7
              keeps rhythm consistent and leaves breathing room before
              the language-switcher pill on the right. */}
          <div className="hidden xl:flex items-center gap-7">
            <div className="relative" ref={tripsRef}>
              <button
                type="button"
                onClick={() => setTripsOpen(!tripsOpen)}
                aria-expanded={tripsOpen}
                aria-haspopup="menu"
                className={NAV_LINK}
              >
                {t("nav.trips")}
                <NavChevron open={tripsOpen} />
              </button>
              {tripsOpen && (
                <div
                  role="menu"
                  className="absolute top-full start-0 mt-2 w-72 bg-white rounded-xl shadow-xl border border-border py-2 max-h-[70vh] overflow-y-auto"
                >
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

            <div className="relative" ref={fluencyRef}>
              <button
                type="button"
                onClick={() => setFluencyOpen(!fluencyOpen)}
                aria-expanded={fluencyOpen}
                aria-haspopup="menu"
                className={NAV_LINK}
              >
                {t("nav.fluencyCourse")}
                <NavChevron open={fluencyOpen} />
              </button>
              {fluencyOpen && (
                <div
                  role="menu"
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

            <Link href="/languages/spanish/travel-guide" className={NAV_LINK}>
              {t("nav.phraseLookup")}
            </Link>

            <Link href="/pricing" className={NAV_LINK}>
              {t("nav.pricing")}
            </Link>
          </div>

          {/* Right rail — hamburger (below lg), language switcher,
              and user menu / sign-in. All three are h-10 to share a
              baseline with the center nav. */}
          <div className="flex items-center gap-2 sm:gap-3 shrink-0">
            {/* Hamburger — only below lg. 44x44 tap target; morphs
                between the lines icon and the X icon so one button
                carries both open and close affordances. */}
            <button
              ref={hamburgerRef}
              type="button"
              onClick={() => setMobileOpen((o) => !o)}
              aria-expanded={mobileOpen}
              aria-controls="mobile-nav"
              aria-label={mobileOpen ? "Close menu" : "Open menu"}
              className="xl:hidden inline-flex items-center justify-center w-11 h-11 -mr-1 rounded-lg text-navy/70 hover:text-teal hover:bg-navy/5 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-teal"
            >
              {mobileOpen ? (
                <svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24" aria-hidden>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              ) : (
                <svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24" aria-hidden>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M4 6h16M4 12h16M4 18h16" />
                </svg>
              )}
            </button>

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
                      aria-haspopup="menu"
                      aria-expanded={userMenuOpen}
                      aria-label={fullName || user.email || "Account"}
                      // Flag-only-style pill on mobile/tablet; the
                      // name shows from lg so the control matches the
                      // LanguageSwitcher behaviour.
                      className="flex items-center gap-2 h-10 pl-1 pr-1 xl:pr-3 text-sm font-medium text-navy/70 hover:text-teal rounded-full border border-border hover:border-teal/30 transition-colors"
                    >
                      <span className="w-8 h-8 rounded-full bg-teal text-white flex items-center justify-center text-sm font-semibold">
                        {avatarChar}
                      </span>
                      <span className="hidden xl:inline max-w-[180px] truncate">
                        {displayLabel}
                      </span>
                      <svg
                        className={`hidden xl:inline w-3.5 h-3.5 transition-transform ${userMenuOpen ? "rotate-180" : ""}`}
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                        aria-hidden
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
                className="inline-flex items-center h-10 px-4 lg:px-5 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark hover:shadow-md transition-all duration-200 whitespace-nowrap"
              >
                {t("nav.signIn")}
              </Link>
            )}
          </div>
        </div>
      </div>

      {/* Mobile drawer — slide-down panel that occupies the viewport
          below the sticky nav. Accordion rows for Trips (cities) and
          Fluency Course (languages); flat links for Phrase Lookup and
          Pricing. Only rendered below `lg`; higher widths show the
          horizontal nav above. */}
      {mobileOpen && (
        <div
          id="mobile-nav"
          role="dialog"
          aria-modal="true"
          aria-label="Site navigation"
          // Fixed, full-viewport-below-header. z-40 sits under the
          // sticky nav (z-50) so the hamburger button stays clickable
          // to close the panel.
          className="xl:hidden fixed inset-x-0 top-16 bottom-0 z-40 bg-white overflow-y-auto overscroll-contain"
        >
          <nav className="divide-y divide-border">
            {/* Trips accordion */}
            <MobileAccordion
              label={t("nav.trips")}
              open={mobileTripsOpen}
              onToggle={() => setMobileTripsOpen((o) => !o)}
            >
              {TRIPS_BY_LANG.map((group) => (
                <div key={group.slug} className="pb-1">
                  <Link
                    href={`/learn/${group.slug}/start`}
                    onClick={closeMobile}
                    className="flex items-center gap-3 px-6 py-3 text-sm font-semibold text-navy hover:bg-orange-50 active:bg-orange-100 transition-colors min-h-[44px]"
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
                      onClick={closeMobile}
                      className="flex items-center gap-3 pl-14 pr-6 py-2.5 text-sm text-navy/70 hover:bg-orange-50 active:bg-orange-100 transition-colors min-h-[44px]"
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
            </MobileAccordion>

            {/* Fluency Course accordion */}
            <MobileAccordion
              label={t("nav.fluencyCourse")}
              open={mobileFluencyOpen}
              onToggle={() => setMobileFluencyOpen((o) => !o)}
            >
              {languages
                .filter((l) => l.slug !== (UI_LANG_NAMES[uiLang]?.slug ?? null))
                .map((lang) => (
                  <Link
                    key={lang.slug}
                    href={`/learn/${lang.slug}`}
                    onClick={closeMobile}
                    className="flex items-center gap-3 px-6 py-3 text-sm text-navy/80 hover:bg-peach-light active:bg-peach-light transition-colors min-h-[44px]"
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
            </MobileAccordion>

            <Link
              href="/languages/spanish/travel-guide"
              onClick={closeMobile}
              className="flex items-center justify-between w-full px-4 py-4 text-base font-medium text-navy hover:bg-navy/5 active:bg-navy/10 transition-colors min-h-[44px]"
            >
              {t("nav.phraseLookup")}
              <svg className="w-4 h-4 text-navy/40" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24" aria-hidden>
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </Link>

            <Link
              href="/pricing"
              onClick={closeMobile}
              className="flex items-center justify-between w-full px-4 py-4 text-base font-medium text-navy hover:bg-navy/5 active:bg-navy/10 transition-colors min-h-[44px]"
            >
              {t("nav.pricing")}
              <svg className="w-4 h-4 text-navy/40" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24" aria-hidden>
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
              </svg>
            </Link>
          </nav>
        </div>
      )}
    </nav>
  );
}

// One accordion row inside the mobile drawer. The whole row is the
// toggle (44px min height); when `open`, children render below in a
// white sub-list.
function MobileAccordion({
  label,
  open,
  onToggle,
  children,
}: {
  label: string;
  open: boolean;
  onToggle: () => void;
  children: React.ReactNode;
}) {
  return (
    <div>
      <button
        type="button"
        onClick={onToggle}
        aria-expanded={open}
        className="flex items-center justify-between w-full px-4 py-4 text-base font-medium text-navy hover:bg-navy/5 active:bg-navy/10 transition-colors min-h-[44px]"
      >
        <span>{label}</span>
        <svg
          className={`w-4 h-4 text-navy/40 transition-transform ${open ? "rotate-180" : ""}`}
          fill="none"
          stroke="currentColor"
          strokeWidth={2.5}
          viewBox="0 0 24 24"
          aria-hidden
        >
          <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
        </svg>
      </button>
      {open && <div className="bg-navy/[0.02] border-t border-border">{children}</div>}
    </div>
  );
}
