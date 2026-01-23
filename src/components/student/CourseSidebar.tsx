'use client';

import { Link } from '@/i18n/routing';
import { ChevronDown, ChevronRight, Check, Lock } from 'lucide-react';
import { useState } from 'react';

interface CourseSidebarProps {
    course: any;
    currentLessonId: string;
    completedLessonIds: Set<string>;
    userId: string;
}

export default function CourseSidebar({ course, currentLessonId, completedLessonIds, userId }: CourseSidebarProps) {
    const [expandedModules, setExpandedModules] = useState<Set<string>>(new Set());

    // Auto-expand module containing current lesson
    useState(() => {
        const currentModule = course.course_modules?.find((m: any) =>
            m.lessons?.some((l: any) => l.id === currentLessonId)
        );
        if (currentModule) {
            setExpandedModules(new Set([currentModule.id]));
        }
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
    const totalLessons = course.course_modules?.reduce((acc: number, m: any) =>
        acc + (m.lessons?.length || 0), 0) || 0;
    const completedCount = completedLessonIds.size;
    const progress = totalLessons > 0 ? Math.round((completedCount / totalLessons) * 100) : 0;

    return (
        <div className="w-80 bg-background border-r-2 border-black flex flex-col h-screen sticky top-0 dark:border-white">
            {/* Header */}
            <div className="p-6 border-b-2 border-black dark:border-white">
                <Link href={`/courses/${course.id}`} className="text-sm text-primary hover:underline mb-2 block">
                    ← Back to Course
                </Link>
                <h2 className="font-bold text-lg mb-4">{course.title}</h2>

                {/* Progress */}
                <div>
                    <div className="flex justify-between text-sm mb-2">
                        <span className="text-muted-foreground">Progress</span>
                        <span className="font-medium">{progress}%</span>
                    </div>
                    <div className="h-2 bg-muted rounded-full overflow-hidden">
                        <div
                            className="h-full bg-primary transition-all duration-300"
                            style={{ width: `${progress}%` }}
                        />
                    </div>
                    <p className="text-xs text-muted-foreground mt-1">
                        {completedCount} of {totalLessons} lessons complete
                    </p>
                </div>
            </div>

            {/* Module List */}
            <div className="flex-1 overflow-y-auto p-4 space-y-2">
                {course.course_modules?.sort((a: any, b: any) => a.order_index - b.order_index).map((module: any) => {
                    const isExpanded = expandedModules.has(module.id);
                    const moduleLessons = module.lessons || [];
                    const moduleCompleted = moduleLessons.every((l: any) => completedLessonIds.has(l.id));

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
                                    {moduleLessons.sort((a: any, b: any) => a.order_index - b.order_index).map((lesson: any) => {
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
    );
}
