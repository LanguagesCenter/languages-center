"use client";

import { useState, useRef, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { languages } from "@/lib/languages";
import { createClient } from "@/lib/supabase/client";
import type { User } from "@supabase/supabase-js";

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const dropdownRef = useRef<HTMLDivElement>(null);
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

  async function handleLogout() {
    await supabase.auth.signOut();
    setUserMenuOpen(false);
    router.refresh();
  }

  return (
    <nav className="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-border">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
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

          {/* Center nav */}
          <div className="hidden md:flex items-center gap-8">
            {/* Languages dropdown */}
            <div className="relative" ref={dropdownRef}>
              <button
                onClick={() => setOpen(!open)}
                className="flex items-center gap-1 text-sm font-medium text-navy/70 hover:text-teal transition-colors"
              >
                Languages
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
                <div className="absolute top-full left-1/2 -translate-x-1/2 mt-2 w-56 bg-white rounded-xl shadow-lg border border-border py-2">
                  {languages.map((lang) => (
                    <Link
                      key={lang.slug}
                      href={`#${lang.slug}`}
                      onClick={() => setOpen(false)}
                      className="flex items-center gap-3 px-4 py-2 text-sm text-navy/80 hover:bg-peach-light hover:text-teal-dark transition-colors"
                    >
                      <Image
                        src={`https://flagcdn.com/w40/${lang.countryCode}.png`}
                        alt={`${lang.name} flag`}
                        width={20}
                        height={15}
                        className="rounded-sm object-cover"
                      />
                      {lang.name}
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
              Pricing
            </Link>

            {/* YouTube link */}
            <a
              href="https://www.youtube.com/@languagescenter"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-1.5 text-sm font-medium text-navy/70 hover:text-teal transition-colors"
            >
              <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" />
              </svg>
              YouTube
            </a>
          </div>

          {/* Auth */}
          <div className="flex items-center gap-4">
            {user ? (
              <div className="relative" ref={userMenuRef}>
                <button
                  onClick={() => setUserMenuOpen(!userMenuOpen)}
                  className="flex items-center gap-2 px-3 py-1.5 text-sm font-medium text-navy/70 hover:text-teal rounded-full border border-border hover:border-teal/30 transition-colors"
                >
                  <div className="w-6 h-6 rounded-full bg-teal/10 flex items-center justify-center">
                    <span className="text-xs font-semibold text-teal">
                      {user.email?.[0].toUpperCase()}
                    </span>
                  </div>
                  <span className="hidden sm:inline max-w-[150px] truncate">
                    {user.email}
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
                  <div className="absolute right-0 top-full mt-2 w-48 bg-white rounded-xl shadow-lg border border-border py-2">
                    <div className="px-4 py-2 border-b border-border">
                      <p className="text-xs text-navy/40">Signed in as</p>
                      <p className="text-sm text-navy font-medium truncate">
                        {user.email}
                      </p>
                    </div>
                    <button
                      onClick={handleLogout}
                      className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors"
                    >
                      Log out
                    </button>
                  </div>
                )}
              </div>
            ) : (
              <Link
                href="/login"
                className="px-5 py-2 text-sm font-semibold text-white bg-teal rounded-full hover:bg-teal-dark hover:shadow-md transition-all duration-200"
              >
                Sign In
              </Link>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
}
