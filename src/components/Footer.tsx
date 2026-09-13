"use client";

import Link from "next/link";
import Image from "next/image";
import { useI18n } from "@/components/I18nProvider";

// Footer trimmed to just the pieces that actually work:
//   • Brand + tagline
//   • One real Lessons link
//   • YouTube (the only live social)
// Everything else — Careers, Contact, Grammar Guides, Pronunciation
// Tips, Instagram, TikTok — used to point at "#" placeholders that
// went nowhere; removed rather than keep dead links in production.
export default function Footer() {
  const { t } = useI18n();
  return (
    <footer className="bg-navy mt-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-14">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-8">
          {/* Brand */}
          <div>
            <Link href="/" className="flex items-center gap-2 mb-4">
              <Image
                src="/Logo fianl.jpg"
                alt="Languages Center logo"
                width={36}
                height={36}
                className="rounded-lg"
              />
              <span className="text-lg font-bold text-white">Languages Center</span>
            </Link>
            <p className="text-sm text-white/50 leading-relaxed">
              {t("footer.tagline")}
            </p>
          </div>

          {/* Resources — only the working link */}
          <div>
            <h4 className="text-sm font-semibold text-white/80 uppercase tracking-wider mb-4">
              {t("footer.resources")}
            </h4>
            <ul className="space-y-2.5">
              <li>
                <Link
                  href="/learn"
                  className="text-sm text-white/40 hover:text-peach transition-colors"
                >
                  {t("footer.lessons")}
                </Link>
              </li>
            </ul>
          </div>

          {/* Follow us — only the live channel */}
          <div>
            <h4 className="text-sm font-semibold text-white/80 uppercase tracking-wider mb-4">
              {t("footer.followUs")}
            </h4>
            <div className="flex gap-4">
              <a
                href="https://www.youtube.com/@the-language-center/?sub_confirmation=1"
                target="_blank"
                rel="noopener noreferrer"
                className="text-[#FF0000] hover:opacity-80 transition-opacity"
                aria-label="YouTube"
              >
                <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" />
                </svg>
              </a>
            </div>
          </div>
        </div>

        <div className="mt-12 pt-8 border-t border-white/10">
          <p className="text-sm text-white/30 text-center">
            &copy; {new Date().getFullYear()} Languages Center. {t("footer.rightsReserved")}
          </p>
        </div>
      </div>
    </footer>
  );
}
