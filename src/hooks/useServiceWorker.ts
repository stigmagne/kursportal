'use client';

import { useEffect } from 'react';

export function useServiceWorker() {
    useEffect(() => {
        if (typeof window !== 'undefined' && 'serviceWorker' in navigator) {
            // Register service worker
            navigator.serviceWorker
                .register('/sw.js')
                .then((registration) => {
                    console.log('SW registered:', registration.scope);
                })
                .catch((error) => {
                    console.error('SW registration failed:', error);
                });
        }
    }, []);
}

// Utility to cache a specific lesson for offline reading
export function cacheLessonForOffline(lessonUrl: string) {
    if (typeof window !== 'undefined' && 'serviceWorker' in navigator) {
        navigator.serviceWorker.ready.then((registration) => {
            registration.active?.postMessage({
                type: 'CACHE_LESSON',
                url: lessonUrl
            });
        });
    }
}

// Utility to clear all cached data
export function clearOfflineCache() {
    if (typeof window !== 'undefined' && 'serviceWorker' in navigator) {
        navigator.serviceWorker.ready.then((registration) => {
            registration.active?.postMessage({
                type: 'CLEAR_CACHE'
            });
        });
    }
}

// Check if user is online
export function useOnlineStatus() {
    if (typeof window === 'undefined') return true;
    return navigator.onLine;
}
