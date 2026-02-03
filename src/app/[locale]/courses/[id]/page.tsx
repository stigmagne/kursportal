import { createClient } from '@/utils/supabase/server'
import { Link, redirect as nextIntlRedirect } from '@/i18n/routing'
import { notFound, redirect } from 'next/navigation'
import { ArrowLeft, CheckCircle, Lock, Users, Heart } from 'lucide-react'
import ReactMarkdown from 'react-markdown'

import CourseProgressSidebar from '@/components/CourseProgressSidebar'
import EnrollButton from '@/components/student/EnrollButton';
import { getTranslations } from 'next-intl/server';
import { CourseContentWrapper } from '@/components/courses/CourseContentWrapper';

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
                ),
                quizzes(
                    id,
                    title
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

    // Fetch discussions and replies for the integrated forum
    const { data: discussionsData } = await supabase
        .from('discussion_with_counts')
        .select('*')
        .eq('course_id', id)
        .order('created_at', { ascending: false });

    // Fetch replies for these discussions
    // Note: In a production app with many discussions, we would load replies on demand.
    // For this MVP, we fetch all relevant replies to enable the "Single Page" feel in the wrapper.
    let fullDiscussions: any[] = [];

    if (discussionsData && discussionsData.length > 0) {
        const discussionIds = discussionsData.map(d => d.id);

        const { data: repliesData } = await supabase
            .from('discussion_replies')
            .select(`
                *,
                author:profiles(full_name, avatar_url),
                likes:discussion_likes(id)
            `)
            .in('discussion_id', discussionIds)
            .order('created_at', { ascending: true });

        // Map and combine data
        fullDiscussions = discussionsData.map(d => {
            const relevantReplies = repliesData?.filter(r => r.discussion_id === d.id) || [];

            const mappedReplies = relevantReplies.map(r => ({
                id: r.id,
                content: r.content,
                user_id: r.user_id,
                author_name: r.author?.full_name || 'Ukjent bruker',
                author_avatar: r.author?.avatar_url,
                parent_reply_id: r.parent_reply_id,
                is_solution: r.is_solution,
                like_count: r.likes?.length || 0,
                created_at: r.created_at
            }));

            return {
                ...d,
                replies: mappedReplies
            };
        });
    }

    return (
        <div className="min-h-screen bg-background">
            {/* Course Header */}
            <div className="bg-background pb-12">
                <div className="h-48 bg-yellow-400 border-b-4 border-black pattern-dots pattern-yellow-500 pattern-bg-white pattern-size-4 pattern-opacity-20 relative overflow-hidden">
                    <div className="absolute inset-0 bg-gradient-to-t from-black/10 to-transparent" />
                </div>

                <div className="max-w-5xl mx-auto px-4 sm:px-6 relative z-10 -mt-24">
                    <div className="bg-white border-4 border-black shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] p-8 md:p-10">
                        <Link href="/courses" className="inline-flex items-center gap-2 text-gray-500 hover:text-black mb-6 text-sm font-black uppercase tracking-wide transition-colors group">
                            <ArrowLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" />
                            {t('back_to_catalog')}
                        </Link>
                        <h1 className="text-4xl md:text-6xl font-black tracking-tighter mb-6">{course.title}</h1>
                        <p className="text-xl md:text-2xl text-gray-600 font-medium leading-relaxed max-w-3xl">{course.description}</p>
                    </div>
                </div>
            </div>

            {/* Content Area */}
            <div className="max-w-5xl mx-auto px-4 sm:px-6 py-12">
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

                        <hr className="border-white/10" />

                        {/* Integrated Course Content & Discussions */}
                        <CourseContentWrapper
                            courseId={course.id}
                            modules={course.course_modules || []}
                            discussions={fullDiscussions}
                            currentUserId={user.id}
                            locale={locale}
                        />
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
