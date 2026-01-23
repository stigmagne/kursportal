'use client';

import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { ScrollArea } from '@/components/ui/scroll-area';
import { CheckCircle2, BookOpen, MessageSquare, Award, PlayCircle } from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';
import { nb, enUS } from 'date-fns/locale';
import { useLocale, useTranslations } from 'next-intl';

interface Activity {
    id: string;
    activity_type: string;
    description: string;
    created_at: string;
    metadata: any;
}

const getActivityIcon = (type: string) => {
    switch (type) {
        case 'lesson_completed': return <CheckCircle2 className="w-4 h-4 text-emerald-500" />;
        case 'quiz_passed': return <Award className="w-4 h-4 text-amber-500" />;
        case 'certificate_earned': return <Award className="w-4 h-4 text-purple-500" />;
        case 'comment_posted': return <MessageSquare className="w-4 h-4 text-blue-500" />;
        case 'course_enrolled': return <BookOpen className="w-4 h-4 text-primary" />;
        default: return <PlayCircle className="w-4 h-4 text-muted-foreground" />;
    }
};

export default function RecentActivity({ activities }: { activities: Activity[] }) {
    const t = useTranslations('Dashboard');
    const locale = useLocale();
    const dateLocale = locale === 'no' ? nb : enUS;

    return (
        <Card className="p-6">
            <h3 className="font-semibold text-lg mb-4 flex items-center gap-2">
                <PlayCircle className="w-5 h-5 text-primary" />
                {t('activity_title', { defaultMessage: 'Siste aktivitet' })}
            </h3>

            <div className="space-y-4">
                {activities.length === 0 ? (
                    <p className="text-sm text-muted-foreground text-center py-4">
                        {t('no_activity', { defaultMessage: 'Ingen aktivitet enda' })}
                    </p>
                ) : (
                    activities.map((activity) => (
                        <div key={activity.id} className="flex gap-3 items-start group">
                            <div className="mt-1 p-1.5 rounded-full bg-muted group-hover:bg-primary/10 transition-colors">
                                {getActivityIcon(activity.activity_type)}
                            </div>
                            <div>
                                <p className="text-sm font-medium leading-none mb-1">
                                    {activity.description}
                                </p>
                                <p className="text-xs text-muted-foreground">
                                    {formatDistanceToNow(new Date(activity.created_at), { addSuffix: true, locale: dateLocale })}
                                </p>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </Card>
    );
}
