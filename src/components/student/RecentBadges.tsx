'use client';

import { Card } from '@/components/ui/card';
import { useTranslations } from 'next-intl';
import { Award } from 'lucide-react';

interface BadgeItem {
    id: string;
    name: string;
    description: string;
    icon: string;
    tier: 'bronze' | 'silver' | 'gold' | 'platinum';
    earned_at: string;
}

export default function RecentBadges({ badges }: { badges: BadgeItem[] }) {
    const t = useTranslations('Dashboard');

    const getTierColor = (tier: string) => {
        switch (tier) {
            case 'gold': return 'bg-yellow-100 text-yellow-700 border-yellow-200';
            case 'silver': return 'bg-slate-100 text-slate-700 border-slate-200';
            case 'bronze': return 'bg-orange-100 text-orange-700 border-orange-200';
            case 'platinum': return 'bg-cyan-100 text-cyan-700 border-cyan-200';
            default: return 'bg-muted text-muted-foreground';
        }
    };

    return (
        <Card className="p-6">
            <h3 className="font-semibold text-lg mb-4 flex items-center gap-2">
                <Award className="w-5 h-5 text-amber-500" />
                {t('badges_title', { defaultMessage: 'Dine utmerkelser' })}
            </h3>

            <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 gap-4">
                {badges.length === 0 ? (
                    <div className="col-span-full text-center py-4 text-sm text-muted-foreground">
                        {t('no_badges', { defaultMessage: 'Ingen utmerkelser enda. Fullfør kurs og quizer for å tjene dem!' })}
                    </div>
                ) : (
                    badges.map((badge) => (
                        <div key={badge.id} className="flex flex-col items-center text-center group">
                            <div className={`w-12 h-12 rounded-full flex items-center justify-center text-2xl mb-2 border-2 transition-transform group-hover:scale-110 ${getTierColor(badge.tier)}`}>
                                {badge.icon}
                            </div>
                            <span className="text-xs font-medium truncate w-full" title={badge.name}>
                                {badge.name}
                            </span>
                        </div>
                    ))
                )}
            </div>
        </Card>
    );
}
