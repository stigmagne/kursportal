'use client';

import { Flame } from 'lucide-react';
import { useTranslations } from 'next-intl';

interface StreakCounterProps {
    currentStreak: number;
    longestStreak: number;
    lastActivityDate?: string;
    size?: 'sm' | 'md' | 'lg';
    variant?: 'default' | 'minimal';
}

export function StreakCounter({
    currentStreak,
    longestStreak,
    lastActivityDate,
    size = 'md',
    variant = 'default'
}: StreakCounterProps) {
    const t = useTranslations('gamification');

    // Check if streak is at risk (no activity today)
    const today = new Date().toISOString().split('T')[0];
    const isAtRisk = lastActivityDate && lastActivityDate !== today;
    const isActive = currentStreak > 0;

    const sizeClasses = {
        sm: 'p-3',
        md: 'p-4',
        lg: 'p-6',
    };

    const iconSizes = {
        sm: 24,
        md: 32,
        lg: 48,
    };

    const textSizes = {
        sm: 'text-2xl',
        md: 'text-4xl',
        lg: 'text-6xl',
    };

    const containerClasses = variant === 'default'
        ? `bg-white dark:bg-zinc-900 border-3 border-black dark:border-white shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)]`
        : '';

    return (
        <div className={`
            ${sizeClasses[size]}
            inline-flex items-center gap-3
            ${containerClasses}
            ${isAtRisk ? 'animate-pulse' : ''}
        `}>
            {/* Flame Icon */}
            <div className={`
                relative
                ${isActive ? '' : 'opacity-40 grayscale'}
            `}>
                <Flame
                    size={iconSizes[size]}
                    className={isActive ? 'text-orange-500' : 'text-zinc-400'}
                    strokeWidth={2.5}
                    fill={isActive ? '#F97316' : 'none'}
                />
                {isAtRisk && isActive && (
                    <span className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full animate-ping" />
                )}
            </div>

            {/* Streak Count */}
            <div className="flex flex-col">
                <span className={`
                    ${textSizes[size]} font-black leading-none
                    ${isActive ? 'text-black dark:text-white' : 'text-zinc-400'}
                `}>
                    {currentStreak}
                </span>
                <span className="text-xs font-bold uppercase tracking-wide text-zinc-500">
                    {currentStreak === 1 ? t('day') : t('days')}
                </span>
            </div>

            {/* Best Streak Badge */}
            {longestStreak > 0 && longestStreak >= currentStreak && (
                <div className="
                    ml-2 px-2 py-1
                    bg-yellow-400 dark:bg-yellow-500
                    border-2 border-black dark:border-black
                    text-xs font-bold uppercase
                ">
                    {t('best')}: {longestStreak}
                </div>
            )}
        </div>
    );
}
