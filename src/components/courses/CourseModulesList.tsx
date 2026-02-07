'use client';

import { useTranslations } from 'next-intl';

interface Lesson {
    id: string;
    title: string;
    duration_minutes: number;
    order_index: number;
}

interface Module {
    id: string;
    title: string;
    description: string;
    order_index: number;
    lessons: Lesson[];
    quizzes: { id: string; title: string }[];
}

import { Link } from '@/i18n/routing';

interface CourseModulesListProps {
    modules: Module[];
    courseId: string;
}

export function CourseModulesList({ modules, courseId }: CourseModulesListProps) {
    const t = useTranslations('CourseDetails');

    if (!modules || modules.length === 0) {
        return (
            <div className="text-muted-foreground italic">
                {t('no_content')}
            </div>
        );
    }

    return (
        <div className="space-y-6">
            <h2 className="text-2xl font-bold">{t('course_content')}</h2>
            {modules
                .sort((a, b) => a.order_index - b.order_index)
                .map((module, moduleIndex) => (
                    <div
                        key={module.id}
                        className="border-2 border-black dark:border-white bg-background shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)] overflow-hidden transition-all hover:translate-x-px hover:translate-y-px hover:shadow-[3px_3px_0px_0px_rgba(0,0,0,1)] dark:hover:shadow-[3px_3px_0px_0px_rgba(255,255,255,1)]"
                    >
                        <div className="px-6 py-4 border-b-2 border-black dark:border-white bg-muted/50">
                            <h3 className="font-black text-xl">
                                {t('module')} {moduleIndex + 1}: {module.title}
                            </h3>
                            {module.description && (
                                <p className="text-muted-foreground mt-1 font-medium">
                                    {module.description}
                                </p>
                            )}
                        </div>
                        <ul className="divide-y-2 divide-border">
                            {module.lessons
                                ?.sort((a, b) => a.order_index - b.order_index)
                                .map((lesson, lessonIndex) => (
                                    <li key={lesson.id} className="px-6 py-4 flex items-center justify-between hover:bg-primary/5 transition-colors group">
                                        <span className="flex items-center gap-4">
                                            <span className="flex items-center justify-center w-8 h-8 rounded-lg bg-black text-white text-xs font-bold font-mono group-hover:bg-yellow-400 group-hover:text-black transition-colors border-2 border-black">
                                                {moduleIndex + 1}.{lessonIndex + 1}
                                            </span>
                                            <span className="font-bold text-foreground">{lesson.title}</span>
                                        </span>
                                        {lesson.duration_minutes && (
                                            <span className="text-xs font-bold text-muted-foreground bg-muted px-2 py-1 border border-border">
                                                {lesson.duration_minutes} min
                                            </span>
                                        )}
                                    </li>
                                ))}
                        </ul>
                        {module.quizzes && module.quizzes.length > 0 && (
                            <div className="p-4 border-t-2 border-black dark:border-white bg-muted/50">
                                {module.quizzes.map(quiz => (
                                    <Link
                                        key={quiz.id}
                                        href={`/courses/${courseId}/modules/${module.id}/quiz`}
                                        className="inline-flex items-center gap-2 px-6 py-3 bg-white text-black font-black uppercase tracking-wide border-2 border-black rounded-lg shadow-[3px_3px_0px_0px_rgba(0,0,0,1)] hover:shadow-[1px_1px_0px_0px_rgba(0,0,0,1)] hover:translate-x-[2px] hover:translate-y-[2px] hover:bg-yellow-50 active:translate-x-[3px] active:translate-y-[3px] active:shadow-none transition-all w-full justify-center"
                                    >
                                        Take Module Quiz: {quiz.title}
                                    </Link>
                                ))}
                            </div>
                        )}
                    </div>
                ))}
        </div>
    );
}
