'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Link } from '@/i18n/routing';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { useTranslations } from 'next-intl';

interface LessonNavigationProps {
    courseId: string;
    currentLessonId: string;
}

export function LessonNavigation({
    courseId,
    currentLessonId,
}: LessonNavigationProps) {
    const t = useTranslations('Lesson');
    const [prevLesson, setPrevLesson] = useState<string | null>(null);
    const [nextLesson, setNextLesson] = useState<string | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const supabase = createClient();

    useEffect(() => {
        fetchNavigation();
    }, [currentLessonId]);

    const fetchNavigation = async () => {
        const { data: user } = await supabase.auth.getUser();
        if (!user.user) {
            setIsLoading(false);
            return;
        }

        // Get previous lesson
        const { data: prev } = await supabase.rpc('get_previous_lesson', {
            p_current_lesson_id: currentLessonId,
        });
        setPrevLesson(prev);

        // Get next lesson
        const { data: next } = await supabase.rpc('get_next_lesson', {
            p_user_id: user.user.id,
            p_current_lesson_id: currentLessonId,
        });
        setNextLesson(next);

        setIsLoading(false);
    };

    if (isLoading) {
        return (
            <div className="flex items-center justify-between pt-6 border-t border-border">
                <div className="h-10 w-24 bg-muted rounded animate-pulse"></div>
                <div className="h-10 w-24 bg-muted rounded animate-pulse"></div>
            </div>
        );
    }

    return (
        <div className="flex items-center justify-between pt-6 border-t border-border">
            {prevLesson ? (
                <Link
                    href={`/courses/${courseId}/lessons/${prevLesson}`}
                    className="flex items-center gap-2 px-4 py-2 rounded-lg border border-border hover:bg-muted transition-colors"
                >
                    <ChevronLeft className="w-4 h-4" />
                    {t('previous')}
                </Link>
            ) : (
                <div />
            )}

            {nextLesson ? (
                <Link
                    href={`/courses/${courseId}/lessons/${nextLesson}`}
                    className="flex items-center gap-2 px-4 py-2 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-colors"
                >
                    {t('next')}
                    <ChevronRight className="w-4 h-4" />
                </Link>
            ) : (
                <Link
                    href={`/courses/${courseId}`}
                    className="px-4 py-2 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-colors"
                >
                    {t('back_to_course')}
                </Link>
            )}
        </div>
    );
}
