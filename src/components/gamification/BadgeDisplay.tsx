'use client';

import { Sparkles, BookOpen, Brain, Flame, Trophy, MessageCircle, LucideIcon } from 'lucide-react';
import { useTranslations } from 'next-intl';

interface Badge {
    id: string;
    slug: string;
    name_no: string;
    name_en: string;
    description_no: string;
    description_en: string;
    icon: string;
    icon_color: string;
    earned_at?: string;
}

interface BadgeDisplayProps {
    badges: Badge[];
    earnedBadgeIds: string[];
    locale?: 'no' | 'en';
    size?: 'sm' | 'md' | 'lg';
}

const ICON_MAP: Record<string, LucideIcon> = {
    'Sparkles': Sparkles,
    'BookOpen': BookOpen,
    'Brain': Brain,
    'Flame': Flame,
    'Trophy': Trophy,
    'MessageCircle': MessageCircle,
};

export function BadgeDisplay({ badges, earnedBadgeIds, locale = 'no', size = 'md' }: BadgeDisplayProps) {
    const t = useTranslations('gamification');

    const sizeClasses = {
        sm: 'w-12 h-12',
        md: 'w-16 h-16',
        lg: 'w-20 h-20',
    };

    const iconSizes = {
        sm: 20,
        md: 28,
        lg: 36,
    };

    return (
        <div className="grid grid-cols-3 sm:grid-cols-6 gap-4">
            {badges.map((badge) => {
                const isEarned = earnedBadgeIds.includes(badge.id);
                const IconComponent = ICON_MAP[badge.icon] || Sparkles;
                const name = locale === 'no' ? badge.name_no : badge.name_en;
                const description = locale === 'no' ? badge.description_no : badge.description_en;

                return (
                    <div
                        key={badge.id}
                        className="group relative flex flex-col items-center"
                    >
                        {/* Badge Circle */}
                        <div
                            className={`
                                ${sizeClasses[size]}
                                flex items-center justify-center
                                rounded-full
                                border-3 border-black dark:border-white
                                transition-all duration-200
                                ${isEarned
                                    ? 'bg-white dark:bg-zinc-900 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)]'
                                    : 'bg-zinc-200 dark:bg-zinc-800 opacity-40 grayscale'
                                }
                                ${isEarned ? 'hover:shadow-[6px_6px_0px_0px_rgba(0,0,0,1)] hover:-translate-x-0.5 hover:-translate-y-0.5' : ''}
                            `}
                        >
                            <IconComponent
                                size={iconSizes[size]}
                                style={{ color: isEarned ? badge.icon_color : '#9CA3AF' }}
                                strokeWidth={2.5}
                            />
                        </div>

                        {/* Badge Name */}
                        <span className={`
                            mt-2 text-center text-xs font-bold uppercase tracking-wide
                            ${isEarned ? 'text-black dark:text-white' : 'text-zinc-400 dark:text-zinc-600'}
                        `}>
                            {name}
                        </span>

                        {/* Tooltip */}
                        <div className="
                            absolute bottom-full left-1/2 -translate-x-1/2 mb-2
                            px-3 py-2 
                            bg-black dark:bg-white 
                            text-white dark:text-black 
                            text-xs font-medium
                            rounded-none
                            border-2 border-black dark:border-white
                            shadow-[3px_3px_0px_0px_rgba(0,0,0,1)] dark:shadow-[3px_3px_0px_0px_rgba(255,255,255,1)]
                            opacity-0 group-hover:opacity-100
                            pointer-events-none
                            transition-opacity duration-200
                            whitespace-nowrap
                            z-10
                        ">
                            {description}
                            {!isEarned && (
                                <span className="block text-zinc-400 dark:text-zinc-600 mt-1">
                                    {t('not_earned')}
                                </span>
                            )}
                        </div>
                    </div>
                );
            })}
        </div>
    );
}
