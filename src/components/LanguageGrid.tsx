"use client";

import { useMemo } from "react";
import LanguageCard from "@/components/LanguageCard";
import { useI18n } from "@/components/I18nProvider";
import { UI_LANG_NAMES } from "@/lib/i18n";
import {
  sortByPopularity,
  relatedToStarted,
} from "@/lib/language-proximity";
import type { Language } from "@/lib/languages";

export interface LanguageGridItem extends Language {
  lessonsTotal?: number;
  hasProgress?: boolean;
}

export default function LanguageGrid({
  languages,
  startedSlugsInOrder = [],
}: {
  languages: LanguageGridItem[];
  /**
   * Slugs the user has already started, ordered FIRST-started first → most
   * recently started last. Used to render the "Continue" section and to
   * seed the "Recommended for you" relatedness query.
   */
  startedSlugsInOrder?: string[];
}) {
  const { lang, t } = useI18n();

  // Hide the card for the language the user is currently navigating in.
  const nativeSlug = UI_LANG_NAMES[lang]?.slug ?? null;

  const { continueCards, recommendedCards } = useMemo(() => {
    const filtered = nativeSlug
      ? languages.filter((l) => l.slug !== nativeSlug)
      : languages;
    const byId = new Map(filtered.map((l) => [l.slug, l]));

    // Continue: only languages still in the list (after native-language
    // filter), in the order provided by the server.
    const continueCards: LanguageGridItem[] = startedSlugsInOrder
      .map((slug) => byId.get(slug))
      .filter((x): x is LanguageGridItem => x != null);

    const startedSet = new Set(continueCards.map((l) => l.slug));
    const notStarted = filtered.filter((l) => !startedSet.has(l.slug));

    // If the user hasn't started anything yet, recommended = all
    // languages by site-wide popularity ranking.
    if (continueCards.length === 0) {
      return {
        continueCards,
        recommendedCards: sortByPopularity(notStarted),
      };
    }

    // Otherwise, lead with the languages most related to what they've
    // already started, then pad with the rest by popularity.
    const related = new Set(
      relatedToStarted(
        continueCards.map((c) => c.slug),
        4,
      ),
    );
    const relatedCards = notStarted.filter((l) => related.has(l.slug));
    const restCards = sortByPopularity(
      notStarted.filter((l) => !related.has(l.slug)),
    );
    return { continueCards, recommendedCards: [...relatedCards, ...restCards] };
  }, [languages, startedSlugsInOrder, nativeSlug]);

  if (languages.length === 0) {
    return (
      <div className="text-center py-16">
        <p className="text-sm text-navy/50">
          No languages available yet — check back soon.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-8 sm:space-y-10">
      {continueCards.length > 0 && (
        <div className="space-y-5 sm:space-y-6">
          <p className="text-[11px] sm:text-xs uppercase tracking-[0.15em] font-semibold text-teal-dark">
            {t("home.continue")}
          </p>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-5 lg:gap-6">
            {continueCards.map((entry) => (
              <LanguageCard
                key={entry.slug}
                language={entry}
                lessonsTotal={entry.lessonsTotal}
                hasProgress={entry.hasProgress}
              />
            ))}
          </div>
        </div>
      )}
      {recommendedCards.length > 0 && (
        <div className="space-y-5 sm:space-y-6">
          <p className="text-[11px] sm:text-xs uppercase tracking-[0.15em] font-semibold text-teal-dark">
            {t("home.recommended")}
          </p>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-5 lg:gap-6">
            {recommendedCards.map((entry) => (
              <LanguageCard
                key={entry.slug}
                language={entry}
                lessonsTotal={entry.lessonsTotal}
                hasProgress={entry.hasProgress}
              />
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
