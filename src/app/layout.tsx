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
  title: "Languages Center — Learn Any Language",
  description:
    "Explore languages from around the world. Learn Spanish, French, German, Greek, and more with Languages Center.",
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
