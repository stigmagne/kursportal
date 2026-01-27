'use client';

import { useState } from 'react';
import { Menu, X } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { ChevronDown, ChevronRight, Check } from 'lucide-react';
import { useTranslations } from 'next-intl';

interface Module {
    id: string;
    title: string;
    order_index: number;
    lessons: Lesson[];
}

interface Lesson {
    id: string;
    title: string;
    order_index: number;
    duration_minutes?: number;
}

interface Course {
    id: string;
    title: string;
    course_modules?: Module[];
}

interface MobileCourseSidebarProps {
    course: Course;
    currentLessonId: string;
    completedLessonIds: Set<string>;
    userId: string;
}

export default function MobileCourseSidebar({
    course,
    currentLessonId,
    completedLessonIds,
    userId
}: MobileCourseSidebarProps) {
    const t = useTranslations('CourseSidebar');
    const [isOpen, setIsOpen] = useState(false);
    const [expandedModules, setExpandedModules] = useState<Set<string>>(() => {
        // Auto-expand module containing current lesson
        const currentModule = course.course_modules?.find((m) =>
            m.lessons?.some((l) => l.id === currentLessonId)
        );
        return currentModule ? new Set([currentModule.id]) : new Set();
    });

    const toggleModule = (moduleId: string) => {
        const newExpanded = new Set(expandedModules);
        if (newExpanded.has(moduleId)) {
            newExpanded.delete(moduleId);
        } else {
            newExpanded.add(moduleId);
        }
        setExpandedModules(newExpanded);
    };

    // Calculate progress
    const totalLessons = course.course_modules?.reduce((acc, m) =>
        acc + (m.lessons?.length || 0), 0) || 0;
    const completedCount = completedLessonIds.size;
    const progress = totalLessons > 0 ? Math.round((completedCount / totalLessons) * 100) : 0;

    return (
        <>
            {/* Hamburger Button - Fixed top-left on mobile */}
            <button
                onClick={() => setIsOpen(true)}
                className="md:hidden fixed top-4 left-4 z-50 p-2 bg-background border-2 border-black dark:border-white rounded-lg shadow-lg"
                aria-label={t('openMenu')}
            >
                <Menu className="w-6 h-6" />
            </button>

            {/* Overlay */}
            {isOpen && (
                <div
                    className="md:hidden fixed inset-0 bg-black/50 z-50"
                    onClick={() => setIsOpen(false)}
                />
            )}

            {/* Mobile Drawer */}
            <div className={`
                md:hidden fixed inset-y-0 left-0 z-50 w-80 max-w-[85vw] 
                bg-background border-r-2 border-black dark:border-white
                transform transition-transform duration-300 ease-in-out
                ${isOpen ? 'translate-x-0' : '-translate-x-full'}
            `}>
                {/* Close Button */}
                <button
                    onClick={() => setIsOpen(false)}
                    className="absolute top-4 right-4 p-2"
                    aria-label={t('closeMenu')}
                >
                    <X className="w-6 h-6" />
                </button>

                {/* Sidebar Content */}
                <div className="flex flex-col h-full">
                    {/* Header */}
                    <div className="p-6 border-b-2 border-black dark:border-white">
                        <Link
                            href={`/courses/${course.id}`}
                            className="text-sm text-primary hover:underline mb-2 block"
                            onClick={() => setIsOpen(false)}
                        >
                            ← {t('backToCourse')}
                        </Link>
                        <h2 className="font-bold text-lg mb-4">{course.title}</h2>

                        {/* Progress */}
                        <div>
                            <div className="flex justify-between text-sm mb-2">
                                <span className="text-muted-foreground">{t('progress')}</span>
                                <span className="font-medium">{progress}%</span>
                            </div>
                            <div className="h-2 bg-muted rounded-full overflow-hidden">
                                <div
                                    className="h-full bg-primary transition-all duration-300"
                                    style={{ width: `${progress}%` }}
                                />
                            </div>
                            <p className="text-xs text-muted-foreground mt-1">
                                {t('lessonsComplete', { completed: completedCount, total: totalLessons })}
                            </p>
                        </div>
                    </div>

                    {/* Module List */}
                    <div className="flex-1 overflow-y-auto p-4 space-y-2">
                        {course.course_modules?.sort((a, b) => a.order_index - b.order_index).map((module) => {
                            const isExpanded = expandedModules.has(module.id);
                            const moduleLessons = module.lessons || [];
                            const moduleCompleted = moduleLessons.every((l) => completedLessonIds.has(l.id));

                            return (
                                <div key={module.id} className="rounded-lg border border-border bg-background/50">
                                    {/* Module Header */}
                                    <button
                                        onClick={() => toggleModule(module.id)}
                                        className="w-full p-3 flex items-center gap-2 hover:bg-muted/50 transition-colors"
                                    >
                                        {isExpanded ? (
                                            <ChevronDown className="w-4 h-4 shrink-0" />
                                        ) : (
                                            <ChevronRight className="w-4 h-4 shrink-0" />
                                        )}
                                        <span className="flex-1 text-left text-sm font-medium">{module.title}</span>
                                        {moduleCompleted && <Check className="w-4 h-4 text-green-600" />}
                                    </button>

                                    {/* Lessons */}
                                    {isExpanded && (
                                        <div className="pb-2 px-2 space-y-1">
                                            {moduleLessons.sort((a, b) => a.order_index - b.order_index).map((lesson) => {
                                                const isCompleted = completedLessonIds.has(lesson.id);
                                                const isCurrent = lesson.id === currentLessonId;

                                                return (
                                                    <Link
                                                        key={lesson.id}
                                                        href={`/courses/${course.id}/learn/${lesson.id}`}
                                                        onClick={() => setIsOpen(false)}
                                                        className={`block p-2 pl-8 rounded text-sm transition-colors ${isCurrent
                                                            ? 'bg-primary/20 text-primary font-medium border-l-2 border-primary'
                                                            : 'hover:bg-muted'
                                                            }`}
                                                    >
                                                        <div className="flex items-center gap-2">
                                                            {isCompleted ? (
                                                                <Check className="w-4 h-4 text-green-600 shrink-0" />
                                                            ) : (
                                                                <div className="w-4 h-4 rounded-full border-2 border-muted-foreground shrink-0" />
                                                            )}
                                                            <span className="flex-1">{lesson.title}</span>
                                                            {lesson.duration_minutes && (
                                                                <span className="text-xs text-muted-foreground">
                                                                    {lesson.duration_minutes}m
                                                                </span>
                                                            )}
                                                        </div>
                                                    </Link>
                                                );
                                            })}
                                        </div>
                                    )}
                                </div>
                            );
                        })}
                    </div>
                </div>
            </div>

            {/* Desktop Sidebar - Same as original but with translations */}
            <div className="hidden md:flex w-80 bg-background border-r-2 border-black flex-col h-screen sticky top-0 dark:border-white">
                {/* Header */}
                <div className="p-6 border-b-2 border-black dark:border-white">
                    <Link href={`/courses/${course.id}`} className="text-sm text-primary hover:underline mb-2 block">
                        ← {t('backToCourse')}
                    </Link>
                    <h2 className="font-bold text-lg mb-4">{course.title}</h2>

                    {/* Progress */}
                    <div>
                        <div className="flex justify-between text-sm mb-2">
                            <span className="text-muted-foreground">{t('progress')}</span>
                            <span className="font-medium">{progress}%</span>
                        </div>
                        <div className="h-2 bg-muted rounded-full overflow-hidden">
                            <div
                                className="h-full bg-primary transition-all duration-300"
                                style={{ width: `${progress}%` }}
                            />
                        </div>
                        <p className="text-xs text-muted-foreground mt-1">
                            {t('lessonsComplete', { completed: completedCount, total: totalLessons })}
                        </p>
                    </div>
                </div>

                {/* Module List */}
                <div className="flex-1 overflow-y-auto p-4 space-y-2">
                    {course.course_modules?.sort((a, b) => a.order_index - b.order_index).map((module) => {
                        const isExpanded = expandedModules.has(module.id);
                        const moduleLessons = module.lessons || [];
                        const moduleCompleted = moduleLessons.every((l) => completedLessonIds.has(l.id));

                        return (
                            <div key={module.id} className="rounded-lg border border-border bg-background/50">
                                {/* Module Header */}
                                <button
                                    onClick={() => toggleModule(module.id)}
                                    className="w-full p-3 flex items-center gap-2 hover:bg-muted/50 transition-colors"
                                >
                                    {isExpanded ? (
                                        <ChevronDown className="w-4 h-4 shrink-0" />
                                    ) : (
                                        <ChevronRight className="w-4 h-4 shrink-0" />
                                    )}
                                    <span className="flex-1 text-left text-sm font-medium">{module.title}</span>
                                    {moduleCompleted && <Check className="w-4 h-4 text-green-600" />}
                                </button>

                                {/* Lessons */}
                                {isExpanded && (
                                    <div className="pb-2 px-2 space-y-1">
                                        {moduleLessons.sort((a, b) => a.order_index - b.order_index).map((lesson) => {
                                            const isCompleted = completedLessonIds.has(lesson.id);
                                            const isCurrent = lesson.id === currentLessonId;

                                            return (
                                                <Link
                                                    key={lesson.id}
                                                    href={`/courses/${course.id}/learn/${lesson.id}`}
                                                    className={`block p-2 pl-8 rounded text-sm transition-colors ${isCurrent
                                                        ? 'bg-primary/20 text-primary font-medium border-l-2 border-primary'
                                                        : 'hover:bg-muted'
                                                        }`}
                                                >
                                                    <div className="flex items-center gap-2">
                                                        {isCompleted ? (
                                                            <Check className="w-4 h-4 text-green-600 shrink-0" />
                                                        ) : (
                                                            <div className="w-4 h-4 rounded-full border-2 border-muted-foreground shrink-0" />
                                                        )}
                                                        <span className="flex-1">{lesson.title}</span>
                                                        {lesson.duration_minutes && (
                                                            <span className="text-xs text-muted-foreground">
                                                                {lesson.duration_minutes}m
                                                            </span>
                                                        )}
                                                    </div>
                                                </Link>
                                            );
                                        })}
                                    </div>
                                )}
                            </div>
                        );
                    })}
                </div>
            </div>
        </>
    );
}
