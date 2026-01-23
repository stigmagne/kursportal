'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Link } from '@/i18n/routing';
import { CheckCircle, Circle, Lock } from 'lucide-react';
import { useTranslations } from 'next-intl';

interface LessonSidebarProps {
    courseId: string;
    currentLessonId: string;
}

export function LessonSidebar({
    courseId,
    currentLessonId,
}: LessonSidebarProps) {
    const t = useTranslations('Lesson');
    const [modules, setModules] = useState<any[]>([]);
    const [completedLessons, setCompletedLessons] = useState<Set<string>>(
        new Set()
    );
    const [isLoading, setIsLoading] = useState(true);
    const supabase = createClient();

    useEffect(() => {
        fetchModules();
        fetchCompletedLessons();
    }, [courseId]);

    const fetchModules = async () => {
        const { data } = await supabase
            .from('course_modules')
            .select(`
        *,
        lessons(*)
      `)
            .eq('course_id', courseId)
            .order('order_index');

        if (data) {
            // Sort lessons within each module
            const sortedData = data.map(module => ({
                ...module,
                lessons: module.lessons?.sort((a: any, b: any) => a.order_index - b.order_index) || []
            }));
            setModules(sortedData);
        }
        setIsLoading(false);
    };

    const fetchCompletedLessons = async () => {
        const { data: user } = await supabase.auth.getUser();
        if (!user.user) return;

        const { data } = await supabase
            .from('lesson_completion')
            .select('lesson_id')
            .eq('user_id', user.user.id);

        if (data) {
            setCompletedLessons(new Set(data.map((c) => c.lesson_id)));
        }
    };

    if (isLoading) {
        return (
            <div className="glass rounded-xl p-6 space-y-4 sticky top-4">
                <div className="h-6 bg-muted rounded w-1/2 animate-pulse"></div>
                <div className="space-y-2">
                    {[1, 2, 3, 4, 5].map((i) => (
                        <div key={i} className="h-10 bg-muted rounded animate-pulse"></div>
                    ))}
                </div>
            </div>
        );
    }

    return (
        <div className="glass rounded-xl p-6 space-y-4 sticky top-4 max-h-[calc(100vh-2rem)] overflow-y-auto">
            <h3 className="font-semibold">{t('course_content')}</h3>
            <div className="space-y-4">
                {modules.map((module) => (
                    <div key={module.id} className="space-y-2">
                        <h4 className="text-sm font-medium text-muted-foreground">
                            {module.title}
                        </h4>
                        <div className="space-y-1">
                            {module.lessons?.map((lesson: any) => {
                                const isCompleted = completedLessons.has(lesson.id);
                                const isCurrent = lesson.id === currentLessonId;

                                return (
                                    <Link
                                        key={lesson.id}
                                        href={`/courses/${courseId}/lessons/${lesson.id}`}
                                        className={`flex items-center gap-2 px-3 py-2 rounded-lg text-sm transition-colors ${isCurrent
                                                ? 'bg-primary text-primary-foreground'
                                                : 'hover:bg-muted'
                                            }`}
                                    >
                                        {isCompleted ? (
                                            <CheckCircle className="w-4 h-4 text-green-600 shrink-0" />
                                        ) : (
                                            <Circle className="w-4 h-4 shrink-0" />
                                        )}
                                        <span className="flex-1 truncate">{lesson.title}</span>
                                    </Link>
                                );
                            })}
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
}
