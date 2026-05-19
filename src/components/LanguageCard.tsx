import Image from "next/image";
import type { Language, Difficulty } from "@/lib/languages";

function DifficultyBadge({ level }: { level: Difficulty }) {
  const colors: Record<Difficulty, string> = {
    Easy: "bg-teal-light text-teal-dark border-teal/20",
    Medium: "bg-peach-light text-amber-700 border-peach-dark/40",
    Hard: "bg-red-50 text-red-700 border-red-200",
  };

  return (
    <span
      className={`inline-block px-2.5 py-0.5 text-xs font-medium rounded-full border ${colors[level]}`}
    >
      {level}
    </span>
  );
}

function FlagImage({ countryCode, name }: { countryCode: string; name: string }) {
  return (
    <Image
      src={`https://flagcdn.com/w80/${countryCode}.png`}
      alt={`${name} flag`}
      width={40}
      height={30}
      className="rounded-sm object-cover shadow-sm"
    />
  );
}

export default function LanguageCard({ language }: { language: Language }) {
  return (
    <div
      id={language.slug}
      className="group bg-white border border-border rounded-2xl p-6 hover:shadow-lg hover:border-teal/40 hover:scale-[1.02] transition-all duration-200 cursor-pointer"
    >
      <div className="flex items-start justify-between mb-4">
        <FlagImage countryCode={language.countryCode} name={language.name} />
      </div>
      <h3 className="text-lg font-semibold text-navy mb-4 group-hover:text-teal transition-colors">
        {language.name}
      </h3>
      <div className="space-y-2.5">
        <div className="flex items-center justify-between">
          <span className="text-xs text-navy/50 uppercase tracking-wide font-medium">Grammar</span>
          <DifficultyBadge level={language.grammar} />
        </div>
        <div className="flex items-center justify-between">
          <span className="text-xs text-navy/50 uppercase tracking-wide font-medium">Pronunciation</span>
          <DifficultyBadge level={language.pronunciation} />
        </div>
      </div>
    </div>
  );
}
