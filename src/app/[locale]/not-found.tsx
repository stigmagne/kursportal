'use client';

import { useState, useEffect } from 'react';
import { FileQuestion } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { getRandomFunny404 } from '@/lib/constants/funny-messages';

export default function NotFound() {
    const [message, setMessage] = useState('');

    useEffect(() => {
        setMessage(getRandomFunny404());
    }, []);

    return (
        <div className="min-h-screen flex items-center justify-center p-4">
            <div className="text-center space-y-6">
                <div className="w-24 h-24 mx-auto rounded-full bg-muted flex items-center justify-center">
                    <FileQuestion className="w-12 h-12 text-muted-foreground" />
                </div>
                <div>
                    <h1 className="text-6xl font-bold mb-2">404</h1>
                    <p className="text-xl text-muted-foreground mb-2">Siden ble ikke funnet</p>
                    {message && (
                        <p className="text-lg italic text-muted-foreground max-w-md mx-auto">
                            "{message}"
                        </p>
                    )}
                </div>
                <Link
                    href="/"
                    className="inline-block px-6 py-2 bg-primary text-primary-foreground rounded-lg font-medium hover:bg-primary/90 transition-colors"
                >
                    Tilbake til forsiden
                </Link>
            </div>
        </div>
    );
}
