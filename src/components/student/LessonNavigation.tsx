'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Link } from '@/i18n/routing';
import { ChevronLeft, ChevronRight, Check, Loader2 } from 'lucide-react';
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
    const [isCompleted, setIsCompleted] = useState(false);
    const [isMarkingComplete, setIsMarkingComplete] = useState(false);
    const supabase = createClient();

    useEffect(() => {
        fetchNavigation();
        checkCompletion();
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

    const checkCompletion = async () => {
        const { data: user } = await supabase.auth.getUser();
        if (!user.user) return;

        const { data } = await supabase
            .from('lesson_completion')
            .select('id')
            .eq('user_id', user.user.id)
            .eq('lesson_id', currentLessonId)
            .maybeSingle();

        setIsCompleted(!!data);
    };

    const markAsComplete = async () => {
        setIsMarkingComplete(true);
        const { data: user } = await supabase.auth.getUser();
        if (!user.user) {
            setIsMarkingComplete(false);
            return;
        }

        const { error } = await supabase
            .from('lesson_completion')
            .upsert({
                user_id: user.user.id,
                lesson_id: currentLessonId,
                completed_at: new Date().toISOString(),
            }, {
                onConflict: 'user_id,lesson_id'
            });

        if (!error) {
            setIsCompleted(true);
            // Refresh to get new next lesson
            fetchNavigation();
        }
        setIsMarkingComplete(false);
    };

    if (isLoading) {
        return (
            <div className="sticky bottom-0 z-10 bg-white dark:bg-zinc-950 border-t-2 border-black dark:border-white p-4 shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.1)]">
                <div className="max-w-4xl mx-auto flex items-center justify-between">
                    <div className="h-10 w-24 bg-muted rounded animate-pulse"></div>
                    <div className="h-10 w-32 bg-muted rounded animate-pulse"></div>
                    <div className="h-10 w-24 bg-muted rounded animate-pulse"></div>
                </div>
            </div>
        );
    }

    return (
        <div className="sticky bottom-0 z-10 bg-white dark:bg-zinc-950 border-t-2 border-black dark:border-white p-4 shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.1)]">
            <div className="max-w-4xl mx-auto flex items-center justify-between gap-2">
                {/* Previous Button */}
                {prevLesson ? (
                    <Link
                        href={`/courses/${courseId}/learn/${prevLesson}`}
                        className="flex items-center gap-2 px-3 py-2 sm:px-4 rounded-lg border-2 border-black dark:border-white hover:bg-muted transition-colors text-sm sm:text-base"
                    >
                        <ChevronLeft className="w-4 h-4" />
                        <span className="hidden sm:inline">{t('previous')}</span>
                    </Link>
                ) : (
                    <div className="w-10 sm:w-24" />
                )}

                {/* Mark Complete Button */}
                <button
                    onClick={markAsComplete}
                    disabled={isCompleted || isMarkingComplete}
                    className={`flex items-center gap-2 px-4 py-2 rounded-lg font-medium transition-colors text-sm sm:text-base ${isCompleted
                        ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-100 border-2 border-green-600'
                        : 'bg-primary text-primary-foreground hover:bg-primary/90 border-2 border-black dark:border-white'
                        }`}
                >
                    {isMarkingComplete ? (
                        <Loader2 className="w-4 h-4 animate-spin" />
                    ) : isCompleted ? (
                        <>
                            <Check className="w-4 h-4" />
                            <span className="hidden sm:inline">{t('completed')}</span>
                        </>
                    ) : (
                        <>
                            <Check className="w-4 h-4" />
                            <span className="hidden sm:inline">{t('mark_complete')}</span>
                        </>
                    )}
                </button>

                {/* Next Button */}
                {nextLesson ? (
                    <Link
                        href={`/courses/${courseId}/learn/${nextLesson}`}
                        className="flex items-center gap-2 px-3 py-2 sm:px-4 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-colors border-2 border-black dark:border-white text-sm sm:text-base"
                    >
                        <span className="hidden sm:inline">{t('next')}</span>
                        <ChevronRight className="w-4 h-4" />
                    </Link>
                ) : (
                    <Link
                        href={`/courses/${courseId}`}
                        className="flex items-center gap-2 px-3 py-2 sm:px-4 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-colors border-2 border-black dark:border-white text-sm sm:text-base"
                    >
                        <Check className="w-4 h-4" />
                        <span className="hidden sm:inline">{t('back_to_course')}</span>
                    </Link>
                )}
            </div>
        </div>
    );
}
