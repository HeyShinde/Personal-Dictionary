import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Personal Dictionary — AI-Powered Vocabulary for macOS",
  description: "Build your vocabulary with a beautiful macOS app. System dictionary, thesaurus, audio pronunciation, and Apple Intelligence — all in one place.",
  keywords: ["dictionary", "macOS", "vocabulary", "Apple Intelligence", "thesaurus", "learning"],
  openGraph: {
    title: "Personal Dictionary — AI-Powered Vocabulary for macOS",
    description: "Build your vocabulary with a beautiful macOS app featuring Apple Intelligence, audio pronunciation, and 20+ synonyms per word.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
