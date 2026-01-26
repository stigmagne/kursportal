'use client';

import { useState, useEffect } from 'react';
import { getRandomFunnyLoading } from '@/lib/constants/funny-messages';

export default function Loading() {
    const [message, setMessage] = useState('');

    useEffect(() => {
        setMessage(getRandomFunnyLoading());
    }, []);

    return (
        <div className="min-h-screen flex flex-col items-center justify-center gap-4">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
            {message && (
                <p className="text-muted-foreground text-sm italic animate-pulse">
                    {message}
                </p>
            )}
        </div>
    );
}
