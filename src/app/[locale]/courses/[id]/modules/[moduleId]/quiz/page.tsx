import { createClient } from '@/utils/supabase/server';
import { redirect } from 'next/navigation';
import QuizTaker from '@/components/student/QuizTaker';
import { ArrowLeft } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { getTranslations } from 'next-intl/server';

interface ModuleQuizPageProps {
    params: Promise<{
        id: string; // courseId
        moduleId: string;
        locale: string;
    }>;
}

export default async function ModuleQuizPage({ params }: ModuleQuizPageProps) {
    const { id, moduleId, locale } = await params;
    const supabase = await createClient();
    const t = await getTranslations('CourseDetails');

    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
        redirect('/login');
    }

    // Verify module exists and belongs to course (optional but good for safety)
    const { data: moduleData, error } = await supabase
        .from('course_modules')
        .select('title')
        .eq('id', moduleId)
        .eq('course_id', id)
        .single();

    if (error || !moduleData) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <div className="text-center">
                    <h1 className="text-2xl font-bold mb-4">Module not found</h1>
                    <Link href={`/courses/${id}`} className="text-primary hover:underline">
                        Return to Course
                    </Link>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-background p-4 md:p-8">
            <div className="max-w-4xl mx-auto">
                <div className="mb-8">
                    <Link
                        href={`/courses/${id}`}
                        className="inline-flex items-center gap-2 text-muted-foreground hover:text-foreground transition-colors mb-4"
                    >
                        <ArrowLeft className="w-4 h-4" />
                        {t('back_to_course')}
                    </Link>
                    <h1 className="text-3xl font-bold">Quiz: {moduleData.title}</h1>
                </div>

                <div className="bg-card rounded-xl border shadow-sm">
                    <QuizTaker
                        moduleId={moduleId}
                        userId={user.id}
                    />
                </div>
            </div>
        </div>
    );
}
