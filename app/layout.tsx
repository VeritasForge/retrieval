import type { Metadata } from "next";
import { Inter } from "next/font/google";
import { ThemeProvider } from "@wrksz/themes/next";
import { Providers } from "@/components/providers";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Retrieval - 복습 관리",
  description: "에빙하우스 망각곡선 기반 간격 반복 학습 앱",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko" suppressHydrationWarning>
      <body className={inter.className}>
        <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
          <Providers>{children}</Providers>
        </ThemeProvider>
      </body>
    </html>
  );
}
