import { createClient } from '@/utils/supabase/server'
import { Link, redirect as nextIntlRedirect } from '@/i18n/routing'
import { notFound, redirect } from 'next/navigation'
import { ArrowLeft, CheckCircle, Lock, Users, Heart } from 'lucide-react'
import ReactMarkdown from 'react-markdown'
import QuizTaker from '@/components/QuizTaker'
import CourseProgressSidebar from '@/components/CourseProgressSidebar'
import EnrollButton from '@/components/student/EnrollButton';
import { getTranslations } from 'next-intl/server';

export default async function CoursePage({ params }: { params: Promise<{ id: string; locale: string }> }) {
    const { id, locale } = await params;
    const t = await getTranslations('CourseDetails');
    const supabase = await createClient();

    // Require authentication
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        redirect('/login');
    }

    // Get course data including target_group
    const { data: course, error } = await supabase
        .from('courses')
        .select(`
            *,
            categories:course_categories(
                category:categories(id, name)
            )
        `)
        .eq('id', id)
        .single();

    if (error || !course) {
        notFound();
    }

    // Check access if course has target_group restriction
    let hasAccess = true;
    if (course.target_group) {
        // Get user profile
        const { data: profile } = await supabase
            .from('profiles')
            .select('user_type')
            .eq('id', user.id)
            .single();

        // Check completed assessments
        const { data: completedAssessments } = await supabase
            .from('assessment_sessions')
            .select('assessment_type:assessment_types(target_group)')
            .eq('user_id', user.id)
            .eq('status', 'completed');

        const completedTypes = completedAssessments?.map(
            (a: any) => a.assessment_type?.target_group
        ).filter(Boolean) || [];

        hasAccess =
            profile?.user_type === 'both' ||
            profile?.user_type === course.target_group ||
            completedTypes.includes(course.target_group);
    }

    // If no access, show blocked page
    if (!hasAccess) {
        return (
            <div className="min-h-screen bg-background flex items-center justify-center p-4">
                <div className="max-w-md text-center">
                    <div className="w-16 h-16 rounded-full bg-muted flex items-center justify-center mx-auto mb-6">
                        <Lock className="w-8 h-8 text-muted-foreground" />
                    </div>
                    <h1 className="text-2xl font-bold mb-2">Kurs utilgjengelig</h1>
                    <p className="text-muted-foreground mb-6">
                        Dette kurset er for {course.target_group === 'sibling' ? 'søsken' : 'foreldre'}.
                        Du må fullføre den tilhørende vurderingen for å få tilgang.
                    </p>
                    <div className="flex flex-col gap-3">
                        <Link
                            href={`/assessment/${course.target_group}-assessment`}
                            className="inline-flex items-center justify-center gap-2 px-6 py-3 bg-primary text-primary-foreground font-medium rounded-none border-2 border-primary hover:bg-primary/90"
                        >
                            {course.target_group === 'sibling' ? (
                                <Users className="w-4 h-4" />
                            ) : (
                                <Heart className="w-4 h-4" />
                            )}
                            Ta vurdering for {course.target_group === 'sibling' ? 'søsken' : 'foreldre'}
                        </Link>
                        <Link
                            href="/courses"
                            className="text-sm text-muted-foreground hover:text-foreground"
                        >
                            ← Tilbake til kursoversikt
                        </Link>
                    </div>
                </div>
            </div>
        );
    }

    // Check if user is enrolled
    let isEnrolled = false;
    let progress = 0;

    if (user) {
        const { data: enrollment } = await supabase
            .from('user_progress')
            .select('id')
            .eq('user_id', user.id)
            .eq('course_id', id)
            .single();

        isEnrolled = !!enrollment;

        // Calculate progress if enrolled
        if (isEnrolled) {
            const { data: progressData } = await supabase
                .rpc('calculate_course_progress', {
                    p_user_id: user.id,
                    p_course_id: id
                });
            progress = progressData || 0;
        }
    }

    return (
        <div className="min-h-screen bg-background">
            {/* Course Header */}
            <div className="bg-muted/30 border-b border-white/5">
                <div className="max-w-4xl mx-auto px-4 sm:px-6 py-12">
                    <Link href="/courses" className="inline-flex items-center gap-2 text-muted-foreground hover:text-foreground mb-6 text-sm font-medium transition-colors">
                        <ArrowLeft className="w-4 h-4" />
                        {t('back_to_catalog')}
                    </Link>
                    <h1 className="text-4xl md:text-5xl font-extrabold tracking-tight mb-4">{course.title}</h1>
                    <p className="text-xl text-muted-foreground">{course.description}</p>
                </div>
            </div>

            {/* Content Area */}
            <div className="max-w-4xl mx-auto px-4 sm:px-6 py-12">
                <div className="grid gap-12 lg:grid-cols-[1fr_250px]">

                    {/* Main Content */}
                    <div className="space-y-12">
                        <div className="prose dark:prose-invert max-w-none mb-8">
                            <ReactMarkdown>{course.description}</ReactMarkdown>
                        </div>

                        {/* Enroll Button */}
                        <div className="mb-8">
                            <EnrollButton
                                courseId={course.id}
                                courseName={course.title}
                                isEnrolled={isEnrolled}
                            />
                        </div>
                        <div className="prose prose-invert prose-lg max-w-none">
                            <ReactMarkdown>
                                {course.content || `*${t('no_content')}*`}
                            </ReactMarkdown>
                        </div>

                        <hr className="border-white/10" />

                        <div className="mt-12">
                            <QuizTaker />
                        </div>
                    </div>

                    {/* Sidebar / Actions */}
                    <div className="space-y-6">
                        <CourseProgressSidebar courseId={course.id} initialProgress={progress} />
                    </div>

                </div>
            </div>
        </div>
    )
}
