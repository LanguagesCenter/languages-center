"use client";

import { useState, useRef, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { FLAG_CODES } from "@/lib/flag-codes";
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

export default function Navbar() {
  const { t, lang: uiLang } = useI18n();
  const [open, setOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [languages, setLanguages] = useState<NavbarLanguage[]>([]);
  const dropdownRef = useRef<HTMLDivElement>(null);
  const userMenuRef = useRef<HTMLDivElement>(null);
  const router = useRouter();
  const supabase = createClient();

  useEffect(() => {
    // Auth
    supabase.auth.getUser().then(({ data: { user } }) => {
      setUser(user);
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });

    // Languages — pulled live from the same Supabase table the rest of the
    // app uses, so any new row added there shows up here automatically.
    supabase
      .from("languages")
      .select("name, code")
      .order("id")
      .then(({ data }) => {
        if (!data) return;
        const mapped = (data as { name: string; code: string }[]).map((row) => ({
          name: row.name,
          slug: row.code,
          countryCode: FLAG_CODES[row.code] ?? row.code,
        }));
        // Site-wide popularity order so the dropdown matches the
        // homepage and /learn page lists.
        setLanguages(sortByPopularity(mapped));
      });

    return () => subscription.unsubscribe();
  }, [supabase.auth]);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setOpen(false);
      }
      if (userMenuRef.current && !userMenuRef.current.contains(e.target as Node)) {
        setUserMenuOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // While the languages dropdown is open, freeze the page behind it. Without
  // this, wheel events that reach the dropdown's max-height boundary scroll
  // the body underneath. `overscroll-contain` alone is unreliable on
  // touchpads and across browsers; locking the body is the robust fix.
  useEffect(() => {
    if (!open) return;
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prevOverflow;
    };
  }, [open]);

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

          {/* Center nav */}
          <div className="hidden md:flex items-center gap-8">
            {/* Languages dropdown */}
            <div className="relative" ref={dropdownRef}>
              <button
                onClick={() => setOpen(!open)}
                className="flex items-center gap-1 text-sm font-medium text-navy/70 hover:text-teal transition-colors"
              >
                {t("nav.languages")}
                <svg
                  className={`w-4 h-4 transition-transform ${open ? "rotate-180" : ""}`}
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              {open && (
                <div
                  className="absolute top-full start-0 mt-2 w-72 max-w-[calc(100vw-2rem)] bg-white rounded-xl shadow-xl border border-border py-2 max-h-80 overflow-y-auto overscroll-contain"
                  // Mousewheel/touch events stay inside this list; body
                  // scroll-lock handled by the open-effect above.
                  onWheel={(e) => e.stopPropagation()}
                  onTouchMove={(e) => e.stopPropagation()}
                >
                  {/* Hide the row that matches the user's UI language —
                      we don't promote learning the language they already
                      use to navigate the site. */}
                  {languages
                    .filter(
                      (l) => l.slug !== (UI_LANG_NAMES[uiLang]?.slug ?? null),
                    )
                    .map((lang) => (
                    <Link
                      key={lang.slug}
                      href={`/languages/${lang.slug}`}
                      onClick={() => setOpen(false)}
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

            {/* Pricing link */}
            <Link
              href="/pricing"
              className="text-sm font-medium text-navy/70 hover:text-teal transition-colors"
            >
              {t("nav.pricing")}
            </Link>

            {/* YouTube link */}
            <a
              href="https://www.youtube.com/@the-language-center/?sub_confirmation=1"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-1.5 text-sm font-medium text-navy/70 hover:text-teal transition-colors"
            >
              <svg className="w-5 h-5 text-[#FF0000]" viewBox="0 0 24 24" fill="currentColor">
                <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" />
              </svg>
              {t("nav.youtube")}
            </a>
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
                      className="flex items-center gap-2 pl-1 pr-3 py-1 text-sm font-medium text-navy/70 hover:text-teal rounded-full border border-border hover:border-teal/30 transition-colors"
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
                className="px-5 py-2 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark hover:shadow-md transition-all duration-200"
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
