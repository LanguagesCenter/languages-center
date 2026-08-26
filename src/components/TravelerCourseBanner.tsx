import Link from "next/link";

// Full-width promo block that lives between the homepage's language
// cards section and the footer. Distinct visual style (sky/teal
// gradient + suitcase icon) so it reads as a standalone bonus track,
// not another language card. Two CTA buttons — one per language that
// has a Traveler's Course.
export default function TravelerCourseBanner() {
  return (
    <section className="relative overflow-hidden bg-gradient-to-br from-sky-50 via-white to-teal-light/40 border-y border-sky-200/60">
      {/* Decorative background dots — subtle "trip route" vibe. */}
      <div className="pointer-events-none absolute -top-8 -right-8 w-64 h-64 rounded-full bg-sky-300/20 blur-3xl" />
      <div className="pointer-events-none absolute -bottom-10 -left-10 w-72 h-72 rounded-full bg-teal/15 blur-3xl" />

      <div className="relative max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-14 sm:py-20">
        <div className="grid grid-cols-1 lg:grid-cols-[auto_1fr] gap-8 lg:gap-12 items-center">
          {/* Icon */}
          <div className="flex justify-center lg:justify-start">
            <div className="relative w-20 h-20 sm:w-24 sm:h-24 rounded-3xl bg-gradient-to-br from-sky-500 to-teal-dark text-white flex items-center justify-center shadow-xl ring-4 ring-white">
              <svg
                className="w-10 h-10 sm:w-12 sm:h-12"
                fill="none"
                stroke="currentColor"
                strokeWidth={2}
                viewBox="0 0 24 24"
                aria-hidden
              >
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 7V5a2 2 0 012-2h2a2 2 0 012 2v2" />
                <rect x="3" y="7" width="18" height="14" rx="2" strokeLinecap="round" strokeLinejoin="round" />
                <path strokeLinecap="round" strokeLinejoin="round" d="M8 11v6M16 11v6M12 11v6" />
              </svg>
              {/* Small airplane badge in the corner */}
              <span className="absolute -top-2 -right-2 w-9 h-9 rounded-full bg-amber-500 text-white flex items-center justify-center shadow-md ring-2 ring-white">
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 24 24" aria-hidden>
                  <path d="M21 16v-2l-8-5V3.5a1.5 1.5 0 00-3 0V9l-8 5v2l8-2.5V19l-2 1.5V22l3.5-1L15 22v-1.5L13 19v-5.5L21 16z" />
                </svg>
              </span>
            </div>
          </div>

          {/* Copy + CTAs */}
          <div className="text-center lg:text-left">
            <p className="text-xs font-semibold uppercase tracking-[0.18em] text-teal-dark mb-2">
              Bonus track — no CEFR grind required
            </p>
            <h2 className="text-3xl sm:text-4xl font-bold text-navy tracking-tight">
              Planning a trip? Try our Traveler&rsquo;s Course
            </h2>
            <p className="text-sm sm:text-base text-navy/70 leading-relaxed mt-3 max-w-xl mx-auto lg:mx-0">
              City by city, sign by sign. Learn the exact phrases you&rsquo;ll
              actually hear on the ground — airport arrivals, cafés,
              metros, markets, restaurants. First 5 lessons per city are
              free.
            </p>

            <div className="mt-6 flex flex-col sm:flex-row gap-3 justify-center lg:justify-start">
              <Link
                href="/learn/spanish/travel"
                className="inline-flex items-center justify-center gap-2 px-6 py-3.5 text-sm sm:text-base font-bold text-white bg-gradient-to-r from-sky-600 to-teal-dark rounded-full shadow-md hover:shadow-xl hover:from-sky-700 hover:to-teal-dark active:scale-[0.98] transition-all"
              >
                <span aria-hidden className="text-lg">🇪🇸</span>
                Spanish Travel Course
                <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                </svg>
              </Link>
              <Link
                href="/learn/french/travel"
                className="inline-flex items-center justify-center gap-2 px-6 py-3.5 text-sm sm:text-base font-bold text-white bg-gradient-to-r from-sky-600 to-teal-dark rounded-full shadow-md hover:shadow-xl hover:from-sky-700 hover:to-teal-dark active:scale-[0.98] transition-all"
              >
                <span aria-hidden className="text-lg">🇫🇷</span>
                French Travel Course
                <svg className="w-4 h-4" fill="none" stroke="currentColor" strokeWidth={2.5} viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
                </svg>
              </Link>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
