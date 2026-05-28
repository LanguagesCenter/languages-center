"use client";

import Link from "next/link";
import { useI18n } from "@/components/I18nProvider";

interface HomeButtonProps {
  variant?: "default" | "muted";
  className?: string;
}

// House-icon home link. Used in the navbar and in the headers of pages
// that don't render the full navbar (login, forgot/reset password, pricing).
export default function HomeButton({ variant = "default", className }: HomeButtonProps) {
  const { t } = useI18n();
  const tone =
    variant === "muted"
      ? "text-navy/60 hover:text-teal hover:bg-peach-light/60"
      : "text-navy/70 hover:text-teal hover:bg-peach-light";

  return (
    <Link
      href="/"
      aria-label={t("nav.home")}
      title={t("nav.home")}
      className={`inline-flex items-center justify-center w-9 h-9 rounded-full border border-border transition-colors ${tone} ${className ?? ""}`}
    >
      <svg
        className="w-4 h-4"
        fill="none"
        stroke="currentColor"
        strokeWidth={2}
        viewBox="0 0 24 24"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M2.25 12l8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25"
        />
      </svg>
    </Link>
  );
}
