import { NextIntlClientProvider } from 'next-intl';
import { getMessages } from 'next-intl/server';
import { notFound } from 'next/navigation';
import { routing } from '@/i18n/routing';
import Navbar from "@/components/Navbar";
import { Geist, Geist_Mono } from "next/font/google";
import "../globals.css";
import type { Metadata } from "next";
import { ToastProvider } from '@/components/providers/ToastProvider';
import { ClientErrorBoundary } from '@/components/providers/ClientErrorBoundary';
import { ServiceWorkerProvider } from '@/components/providers/ServiceWorkerProvider';
import MobileBottomNav from '@/components/MobileBottomNav';

const geistSans = Geist({
    variable: "--font-geist-sans",
    subsets: ["latin"],
});

const geistMono = Geist_Mono({
    variable: "--font-geist-mono",
    subsets: ["latin"],
});

export const metadata: Metadata = {
    title: "En Helt Syk Oppvekst",
    description: "Læringsplattform for forståelse og støtte",
    manifest: "/manifest.json",
    appleWebApp: {
        capable: true,
        statusBarStyle: "black-translucent",
        title: "EHSO"
    },
    viewport: {
        width: "device-width",
        initialScale: 1,
        maximumScale: 1,
        userScalable: false,
        viewportFit: "cover"
    },
    themeColor: "#6366f1"
};

export default async function LocaleLayout({
    children,
    params
}: Readonly<{
    children: React.ReactNode;
    params: Promise<{ locale: string }>;
}>) {
    const { locale } = await params;

    // Ensure that the incoming `locale` is valid
    if (!routing.locales.includes(locale as any)) {
        notFound();
    }

    // Providing all messages to the client
    // side is the easiest way to get started
    const messages = await getMessages();

    return (
        <html lang={locale} suppressHydrationWarning>
            <body
                className={`${geistSans.variable} ${geistMono.variable} antialiased`}
            >
                <ServiceWorkerProvider>
                    <NextIntlClientProvider messages={messages}>
                        <Navbar />
                        <ClientErrorBoundary>
                            <main className="min-h-screen bg-linear-to-b from-background to-muted/20 pb-16 md:pb-0">
                                {children}
                            </main>
                        </ClientErrorBoundary>
                        <MobileBottomNav />
                        <ToastProvider />
                    </NextIntlClientProvider>
                </ServiceWorkerProvider>
            </body>
        </html>
    );
}
