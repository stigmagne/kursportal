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

    // Get course data including groups, modules and lessons
    const { data: course, error } = await supabase
        .from('courses')
        .select(`
            *,
            categories:course_categories(
                category:categories(id, name)
            ),
            course_groups(
                group_id,
                groups(id, name)
            ),
            course_modules(
                id,
                title,
                description,
                order_index,
                lessons(
                    id,
                    title,
                    duration_minutes,
                    order_index
                )
            )
        `)
        .eq('id', id)
        .single();

    if (error || !course) {
        notFound();
    }

    // Get the group names for this course
    const courseGroupNames = course.course_groups?.map((cg: any) => cg.groups?.name).filter(Boolean) || [];
    const firstGroupName = courseGroupNames[0] || null;

    // Check access if course has group restriction
    let hasAccess = true;

    // Always check if user is admin first (before any group restrictions)
    const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('role, user_type')
        .eq('id', user.id)
        .single();

    console.log('Profile query result:', { profile, profileError, userId: user.id });

    // Admins always have full access regardless of course groups
    const isAdmin = profile?.role === 'admin';
    console.log('Is admin:', isAdmin);

    if (isAdmin) {
        hasAccess = true;
    } else if (courseGroupNames.length > 0) {
        // Get user's groups for non-admin users
        const { data: userGroupsData } = await supabase
            .from('user_groups')
            .select('groups(name)')
            .eq('user_id', user.id);

        const userGroupNames = userGroupsData?.map((ug: any) => ug.groups?.name).filter(Boolean) || [];

        // Check completed assessments
        const { data: completedAssessments } = await supabase
            .from('assessment_sessions')
            .select('assessment_type:assessment_types(target_group)')
            .eq('user_id', user.id)
            .eq('status', 'completed');

        const completedTypes = completedAssessments?.map(
            (a: any) => a.assessment_type?.target_group
        ).filter(Boolean) || [];

        // User has access if:
        // 1. User type is 'both', OR
        // 2. User belongs to one of the course's groups, OR
        // 3. User has completed an assessment for one of the course's groups
        hasAccess =
            profile?.user_type === 'both' ||
            courseGroupNames.some((groupName: string) => userGroupNames.includes(groupName)) ||
            courseGroupNames.some((groupName: string) => completedTypes.includes(groupName));
    }

    // If no access, show blocked page
    if (!hasAccess) {
        // Determine assessment slug based on group name
        const getAssessmentSlug = (groupName: string) => {
            const slugMap: Record<string, string> = {
                'søsken': 'sibling-assessment',
                'foreldre': 'parent-assessment',
                'Team medlem': 'team-member-assessment',
                'Team leder': 'team-leader-assessment'
            };
            return slugMap[groupName] || 'assessment';
        };

        return (
            <div className="min-h-screen bg-background flex items-center justify-center p-4">
                <div className="max-w-md text-center">
                    <div className="w-16 h-16 rounded-full bg-muted flex items-center justify-center mx-auto mb-6">
                        <Lock className="w-8 h-8 text-muted-foreground" />
                    </div>
                    <h1 className="text-2xl font-bold mb-2">Kurs utilgjengelig</h1>
                    <p className="text-muted-foreground mb-6">
                        Dette kurset er for {firstGroupName || 'en spesifikk gruppe'}.
                        Du må fullføre den tilhørende vurderingen for å få tilgang.
                    </p>
                    <div className="flex flex-col gap-3">
                        <Link
                            href={`/assessment/${getAssessmentSlug(firstGroupName || '')}`}
                            className="inline-flex items-center justify-center gap-2 px-6 py-3 bg-primary text-primary-foreground font-medium rounded-none border-2 border-primary hover:bg-primary/90"
                        >
                            {firstGroupName === 'søsken' ? (
                                <Users className="w-4 h-4" />
                            ) : (
                                <Heart className="w-4 h-4" />
                            )}
                            Ta vurdering for {firstGroupName || 'denne gruppen'}
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

                        {/* Course Modules and Lessons */}
                        {course.course_modules && course.course_modules.length > 0 ? (
                            <div className="space-y-6">
                                <h2 className="text-2xl font-bold">{t('course_content')}</h2>
                                {course.course_modules
                                    .sort((a: any, b: any) => a.order_index - b.order_index)
                                    .map((module: any, moduleIndex: number) => (
                                        <div
                                            key={module.id}
                                            className="border-2 border-foreground/20 bg-card"
                                        >
                                            <div className="px-6 py-4 border-b-2 border-foreground/10 bg-muted/30">
                                                <h3 className="font-bold text-lg">
                                                    {t('module')} {moduleIndex + 1}: {module.title}
                                                </h3>
                                                {module.description && (
                                                    <p className="text-sm text-muted-foreground mt-1">
                                                        {module.description}
                                                    </p>
                                                )}
                                            </div>
                                            <ul className="divide-y divide-foreground/10">
                                                {module.lessons
                                                    ?.sort((a: any, b: any) => a.order_index - b.order_index)
                                                    .map((lesson: any, lessonIndex: number) => (
                                                        <li key={lesson.id} className="px-6 py-3 flex items-center justify-between hover:bg-muted/20 transition-colors">
                                                            <span className="flex items-center gap-3">
                                                                <span className="text-muted-foreground text-sm font-mono">
                                                                    {moduleIndex + 1}.{lessonIndex + 1}
                                                                </span>
                                                                <span>{lesson.title}</span>
                                                            </span>
                                                            {lesson.duration_minutes && (
                                                                <span className="text-xs text-muted-foreground">
                                                                    {lesson.duration_minutes} min
                                                                </span>
                                                            )}
                                                        </li>
                                                    ))}
                                            </ul>
                                        </div>
                                    ))}
                            </div>
                        ) : (
                            <div className="text-muted-foreground italic">
                                {t('no_content')}
                            </div>
                        )}

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
