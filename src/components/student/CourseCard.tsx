'use client';

import { useState, useEffect } from 'react';
import { Link } from '@/i18n/routing';
import { createClient } from '@/utils/supabase/client';
import { Play, CheckCircle } from 'lucide-react';
import { useTranslations } from 'next-intl';

interface CourseCardProps {
    course: {
        id: string;
        title: string;
        description: string;
        cover_image: string | null;
        slug: string;
    };
    progress: number;
    status: string;
    enrolledDate: string;
    userId: string;
}

export default function CourseCard({ course, progress, status, enrolledDate, userId }: CourseCardProps) {
    const t = useTranslations('CourseCard');
    const [resumeUrl, setResumeUrl] = useState<string>(`/courses/${course.id}/learn`);
    const [isLoading, setIsLoading] = useState(true);
    const supabase = createClient();

    useEffect(() => {
        findResumeLesson();
    }, []);

    const findResumeLesson = async () => {
        // Find the first incomplete lesson or last accessed lesson
        const { data: completedLessons } = await supabase
            .from('lesson_completion')
            .select('lesson_id')
            .eq('user_id', userId);

        const completedIds = completedLessons?.map(c => c.lesson_id) || [];

        // Get all lessons for this course
        const { data: lessons } = await supabase
            .from('lessons')
            .select('id, module_id, order_index')
            .in('module_id',
                await supabase
                    .from('course_modules')
                    .select('id')
                    .eq('course_id', course.id)
                    .then(res => res.data?.map(m => m.id) || [])
            )
            .order('order_index');

        if (lessons && lessons.length > 0) {
            // Find first incomplete lesson
            const incompleteLesson = lessons.find(l => !completedIds.includes(l.id));

            if (incompleteLesson) {
                setResumeUrl(`/courses/${course.id}/learn/${incompleteLesson.id}`);
            } else {
                // All complete - go to first lesson
                setResumeUrl(`/courses/${course.id}/learn/${lessons[0].id}`);
            }
        }

        setIsLoading(false);
    };

    const isCompleted = progress >= 100;

    return (
        <div className="glass rounded-2xl border border-white/10 overflow-hidden hover:border-primary/30 transition-all hover:shadow-lg hover:-translate-y-1 duration-300">
            {/* Cover Image */}
            <div className="relative h-48 bg-linear-to-br from-primary/20 to-primary/5">
                {course.cover_image ? (
                    <img
                        src={course.cover_image}
                        alt={course.title}
                        className="w-full h-full object-cover"
                    />
                ) : (
                    <div className="w-full h-full flex items-center justify-center">
                        <div className="text-6xl opacity-20">📚</div>
                    </div>
                )}

                {/* Completion Badge */}
                {isCompleted && (
                    <div className="absolute top-4 right-4 bg-green-600 text-white px-3 py-1 rounded-full text-xs font-medium flex items-center gap-1">
                        <CheckCircle className="w-3 h-3" />
                        {t('completed')}
                    </div>
                )}
            </div>

            {/* Content */}
            <div className="p-6 space-y-4">
                {/* Title */}
                <h3 className="text-xl font-semibold line-clamp-2 min-h-14">
                    {course.title}
                </h3>

                {/* Description */}
                <p className="text-sm text-muted-foreground line-clamp-2 min-h-10">
                    {course.description}
                </p>

                {/* Progress Bar */}
                <div className="space-y-2">
                    <div className="flex items-center justify-between text-sm">
                        <span className="text-muted-foreground">{t('progress')}</span>
                        <span className="font-medium">{progress}%</span>
                    </div>
                    <div className="w-full h-2 bg-muted rounded-full overflow-hidden">
                        <div
                            className="h-full bg-linear-to-r from-primary to-primary/80 transition-all duration-500"
                            style={{ width: `${progress}%` }}
                        />
                    </div>
                </div>

                {/* Actions */}
                <div className="flex gap-2 pt-2">
                    <Link
                        href={resumeUrl}
                        className="flex-1 flex items-center justify-center gap-2 bg-primary text-primary-foreground px-4 py-2 rounded-lg font-medium hover:bg-primary/90 transition-colors"
                    >
                        <Play className="w-4 h-4" />
                        {isCompleted ? t('review') : t('resume')}
                    </Link>
                    <Link
                        href={`/courses/${course.id}`}
                        className="px-4 py-2 rounded-lg border border-border hover:bg-muted transition-colors"
                    >
                        {t('details')}
                    </Link>
                </div>

                {/* Enrolled Date */}
                <p className="text-xs text-muted-foreground">
                    {t('enrolled')} {new Date(enrolledDate).toLocaleDateString()}
                </p>
            </div>
        </div>
    );
}
