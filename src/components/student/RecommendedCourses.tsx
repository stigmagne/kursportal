'use client';

import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { BookOpen } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { useTranslations } from 'next-intl';

interface Course {
    id: string;
    title: string;
    description: string;
    slug: string;
    cover_image: string | null;
}

export default function RecommendedCourses({ courses }: { courses: Course[] }) {
    const t = useTranslations('Dashboard');

    if (courses.length === 0) return null;

    return (
        <div className="space-y-4">
            <h3 className="font-semibold text-lg flex items-center gap-2">
                <BookOpen className="w-5 h-5 text-primary" />
                {t('recommended_title', { defaultMessage: 'Anbefalte kurs for deg' })}
            </h3>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                {courses.map((course) => (
                    <Card key={course.id} className="flex flex-col overflow-hidden hover:shadow-md transition-shadow">
                        <div className="h-32 bg-muted relative">
                            {course.cover_image && (
                                <img
                                    src={course.cover_image}
                                    alt={course.title}
                                    className="w-full h-full object-cover"
                                />
                            )}
                        </div>
                        <div className="p-4 flex-1 flex flex-col">
                            <h4 className="font-bold mb-2 line-clamp-1">{course.title}</h4>
                            <p className="text-sm text-muted-foreground line-clamp-2 mb-4 flex-1">
                                {course.description}
                            </p>
                            <Link href={`/courses/${course.slug}`}>
                                <Button variant="secondary" className="w-full">
                                    {t('view_course', { defaultMessage: 'Se kurs' })}
                                </Button>
                            </Link>
                        </div>
                    </Card>
                ))}
            </div>
        </div>
    );
}
