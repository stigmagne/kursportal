'use client';

import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { PlayCircle, ArrowRight, BookOpen } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { useTranslations } from 'next-intl';

interface EnrolledCourse {
    id: string; // enrollment id
    course_id: string;
    progress: number;
    course: {
        title: string;
        description: string;
        cover_image: string | null;
        slug: string;
    };
}

export default function ContinueLearning({ course }: { course: EnrolledCourse }) {
    const t = useTranslations('Dashboard');

    if (!course) return null;

    return (
        <Card className="p-6 overflow-hidden relative">
            <div className="flex flex-col md:flex-row gap-6 items-center">
                {/* Image / Icon */}
                <div className="w-full md:w-32 h-32 md:h-24 rounded-lg bg-muted flex items-center justify-center shrink-0 overflow-hidden relative">
                    {course.course.cover_image ? (
                        <img
                            src={course.course.cover_image}
                            alt={course.course.title}
                            className="w-full h-full object-cover"
                        />
                    ) : (
                        <BookOpen className="w-10 h-10 text-muted-foreground/50" />
                    )}
                </div>

                {/* Content */}
                <div className="flex-1 text-center md:text-left space-y-2 w-full">
                    <div className="flex items-center gap-2 justify-center md:justify-start text-sm text-primary font-medium mb-1">
                        <PlayCircle className="w-4 h-4" />
                        {t('continue_learning', { defaultMessage: 'Fortsett der du slapp' })}
                    </div>

                    <h3 className="font-bold text-xl md:text-2xl line-clamp-1">
                        {course.course.title}
                    </h3>

                    <div className="space-y-1">
                        <div className="flex justify-between text-xs text-muted-foreground">
                            <span>{t('progress', { defaultMessage: 'Fremgang' })}</span>
                            <span>{Math.round(course.progress)}%</span>
                        </div>
                        <Progress value={course.progress} className="h-2" />
                    </div>
                </div>

                {/* Action */}
                <div className="w-full md:w-auto mt-4 md:mt-0">
                    <Link href={`/courses/${course.course.slug}`}>
                        <Button size="lg" className="w-full md:w-auto shadow-lg shadow-primary/20">
                            {t('resume_course', { defaultMessage: 'Fortsett kurset' })}
                            <ArrowRight className="w-4 h-4 ml-2" />
                        </Button>
                    </Link>
                </div>
            </div>
        </Card>
    );
}
