'use client';

import { useTranslations } from 'next-intl';

interface XPBarProps {
    currentXP: number;
    level: number;
    showLabel?: boolean;
}

function getXPForLevel(level: number): number {
    // Level formula matches database: level = floor(sqrt(xp / 100)) + 1
    // Reverse: xp = (level - 1)^2 * 100
    return Math.pow(level - 1, 2) * 100;
}

function getXPForNextLevel(level: number): number {
    return Math.pow(level, 2) * 100;
}

export function XPBar({ currentXP, level, showLabel = true }: XPBarProps) {
    const t = useTranslations('gamification');

    const xpForCurrentLevel = getXPForLevel(level);
    const xpForNextLevel = getXPForNextLevel(level);
    const xpInCurrentLevel = currentXP - xpForCurrentLevel;
    const xpNeededForNextLevel = xpForNextLevel - xpForCurrentLevel;
    const progress = Math.min(100, (xpInCurrentLevel / xpNeededForNextLevel) * 100);

    return (
        <div className="w-full">
            {showLabel && (
                <div className="flex justify-between items-center mb-2">
                    <span className="text-sm font-bold uppercase tracking-wide">
                        {t('level')} {level}
                    </span>
                    <span className="text-xs font-medium text-zinc-600 dark:text-zinc-400">
                        {xpInCurrentLevel} / {xpNeededForNextLevel} XP
                    </span>
                </div>
            )}

            {/* Progress Bar Container */}
            <div className="
                relative h-6 w-full
                bg-zinc-200 dark:bg-zinc-800
                border-3 border-black dark:border-white
                shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)]
            ">
                {/* Progress Fill */}
                <div
                    className="
                        absolute inset-y-0 left-0
                        bg-gradient-to-r from-blue-500 to-purple-500
                        transition-all duration-500 ease-out
                    "
                    style={{ width: `${progress}%` }}
                />

                {/* XP Text Overlay */}
                <div className="
                    absolute inset-0 
                    flex items-center justify-center
                    text-xs font-bold
                    text-black dark:text-white
                    mix-blend-difference
                ">
                    {currentXP} XP
                </div>
            </div>

            {/* Level Indicators */}
            <div className="flex justify-between mt-1">
                <span className="text-xs font-medium text-zinc-500">
                    Lvl {level}
                </span>
                <span className="text-xs font-medium text-zinc-500">
                    Lvl {level + 1}
                </span>
            </div>
        </div>
    );
}
