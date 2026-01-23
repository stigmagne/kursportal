'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { CheckCircle, Award, MessageSquare, BookOpen, Clock } from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';
import { nb } from 'date-fns/locale';
import { useLocale, useTranslations } from 'next-intl';

interface Activity {
    id: string;
    activity_type: string;
    description: string;
    metadata: any;
    created_at: string;
}

export function ActivityLog() {
    const [activities, setActivities] = useState<Activity[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const supabase = createClient();
    const locale = useLocale();
    const t = useTranslations('Profile');

    useEffect(() => {
        fetchActivities();
    }, []);

    const fetchActivities = async () => {
        const { data: user } = await supabase.auth.getUser();
        if (!user.user) return;

        const { data } = await supabase
            .from('user_activity')
            .select('*')
            .eq('user_id', user.user.id)
            .order('created_at', { ascending: false })
            .limit(20);

        if (data) setActivities(data);
        setIsLoading(false);
    };

    const getActivityIcon = (type: string) => {
        switch (type) {
            case 'lesson_completed':
                return <CheckCircle className="w-5 h-5 text-green-500" />;
            case 'quiz_passed':
                return <Award className="w-5 h-5 text-blue-500" />;
            case 'quiz_failed':
                return <Clock className="w-5 h-5 text-yellow-500" />;
            case 'certificate_earned':
                return <Award className="w-5 h-5 text-purple-500" />;
            case 'comment_posted':
                return <MessageSquare className="w-5 h-5 text-gray-500" />;
            case 'course_enrolled':
                return <BookOpen className="w-5 h-5 text-blue-500" />;
            default:
                return <Clock className="w-5 h-5 text-gray-400" />;
        }
    };

    if (isLoading) {
        return (
            <div className="space-y-3">
                {[1, 2, 3, 4, 5].map(i => (
                    <div key={i} className="h-16 bg-gray-100 rounded animate-pulse" />
                ))}
            </div>
        );
    }

    if (activities.length === 0) {
        return (
            <div className="text-center py-12 text-gray-500">
                <Clock className="w-12 h-12 mx-auto mb-4 opacity-50" />
                <p>{t('no_activity')}</p>
            </div>
        );
    }

    return (
        <div className="space-y-4">
            {activities.map((activity) => (
                <div
                    key={activity.id}
                    className="flex items-start gap-4 p-4 bg-white border border-gray-200 rounded-lg hover:shadow-md transition-shadow"
                >
                    <div className="shrink-0 mt-1">
                        {getActivityIcon(activity.activity_type)}
                    </div>

                    <div className="flex-1 min-w-0">
                        <p className="text-sm text-gray-900">{activity.description}</p>
                        <p className="text-xs text-gray-500 mt-1">
                            {formatDistanceToNow(new Date(activity.created_at), {
                                addSuffix: true,
                                locale: locale === 'no' ? nb : undefined,
                            })}
                        </p>
                    </div>
                </div>
            ))}
        </div>
    );
}
