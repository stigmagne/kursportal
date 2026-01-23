'use client';

import { useEffect } from 'react';
import { AlertTriangle } from 'lucide-react';
import { useTranslations } from 'next-intl';

export default function Error({
    error,
    reset,
}: {
    error: Error & { digest?: string };
    reset: () => void;
}) {
    const t = useTranslations('Error');

    useEffect(() => {
        console.error('Error:', error);
    }, [error]);

    return (
        <div className="min-h-screen flex items-center justify-center p-4">
            <div className="glass rounded-xl p-8 max-w-md w-full text-center space-y-6">
                <div className="w-16 h-16 mx-auto rounded-full bg-destructive/10 flex items-center justify-center">
                    <AlertTriangle className="w-8 h-8 text-destructive" />
                </div>
                <div>
                    <h1 className="text-2xl font-bold mb-2">{t('title')}</h1>
                    <p className="text-muted-foreground">{t('description')}</p>
                </div>
                <button
                    onClick={reset}
                    className="px-6 py-2 bg-primary text-primary-foreground rounded-lg font-medium hover:bg-primary/90 transition-colors"
                >
                    {t('retry')}
                </button>
            </div>
        </div>
    );
}
