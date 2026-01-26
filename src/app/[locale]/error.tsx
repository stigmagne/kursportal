'use client';

import { useEffect, useState } from 'react';
import { AlertTriangle, RefreshCw, Home } from 'lucide-react';
import { getRandomFunnyError } from '@/lib/constants/funny-messages';

export default function Error({
    error,
    reset,
}: {
    error: Error & { digest?: string };
    reset: () => void;
}) {
    const [funnyMessage, setFunnyMessage] = useState('');

    useEffect(() => {
        console.error('Error:', error);
        setFunnyMessage(getRandomFunnyError());
    }, [error]);

    return (
        <div className="min-h-screen flex items-center justify-center p-4">
            <div className="rounded-xl border-2 border-border bg-card p-8 max-w-md w-full text-center space-y-6">
                <div className="w-16 h-16 mx-auto rounded-full bg-destructive/10 flex items-center justify-center">
                    <AlertTriangle className="w-8 h-8 text-destructive" />
                </div>
                <div>
                    <h1 className="text-2xl font-bold mb-2">Oi sansen!</h1>
                    {funnyMessage && (
                        <p className="text-lg italic text-muted-foreground mb-2">
                            "{funnyMessage}"
                        </p>
                    )}
                    <p className="text-sm text-muted-foreground">
                        Noe gikk galt. Prøv igjen eller gå til forsiden.
                    </p>
                </div>
                <div className="flex gap-2 justify-center">
                    <button
                        onClick={reset}
                        className="flex items-center gap-2 px-6 py-2 bg-primary text-primary-foreground rounded-lg font-medium hover:bg-primary/90 transition-colors"
                    >
                        <RefreshCw className="w-4 h-4" />
                        Prøv igjen
                    </button>
                    <a
                        href="/"
                        className="flex items-center gap-2 px-6 py-2 border-2 border-border rounded-lg font-medium hover:bg-muted transition-colors"
                    >
                        <Home className="w-4 h-4" />
                        Forsiden
                    </a>
                </div>
                {process.env.NODE_ENV === 'development' && (
                    <pre className="mt-4 p-3 bg-muted text-left text-xs overflow-auto rounded border">
                        {error.message}
                    </pre>
                )}
            </div>
        </div>
    );
}
