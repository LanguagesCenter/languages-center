import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { I18nProvider } from "@/components/I18nProvider";
import { getServerDir, getServerLang } from "@/lib/i18n-server";

const inter = Inter({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title:
    "Languages Center — Learn the language you'll actually need on your trip",
  description:
    "Simulate a real trip, city by city — airport signs, taxis, menus, real streets. Spanish and French Traveler's Course, plus full A1 → C1 Fluency Course in seven languages.",
};

export default async function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  // Pull the user's chosen UI language from the cookie so SSR renders with
  // the right lang+dir. Falls back to "en" / "ltr" on first visit.
  const [lang, dir] = await Promise.all([getServerLang(), getServerDir()]);

  return (
    <html
      lang={lang}
      dir={dir}
      className={`${inter.variable} antialiased`}
    >
      <body className="min-h-screen flex flex-col bg-background text-foreground">
        <I18nProvider initialLang={lang}>{children}</I18nProvider>
      </body>
    </html>
  );
}
