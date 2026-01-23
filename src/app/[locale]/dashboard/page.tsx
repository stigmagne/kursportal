import { createClient } from '@/utils/supabase/server';
import { redirect } from '@/i18n/routing';
import DashboardContent from '@/components/student/DashboardContent';
import SubscriptionStatus from '@/components/student/SubscriptionStatus';
import { getTranslations } from 'next-intl/server';

interface EnrolledCourse {
    id: string;
    course_id: string;
    status: string;
    created_at: string;
    course: {
        id: string;
        title: string;
        description: string;
        cover_image: string | null;
        slug: string;
    };
}

export default async function DashboardPage({ params }: { params: { locale: string } }) {
    const { locale } = await params;
    const t = await getTranslations('Dashboard');
    const supabase = await createClient()

    // Check authentication
    const { data: { user } } = await supabase.auth.getUser()

    if (!user) {
        return redirect({ href: '/login', locale })
    }

    // Check if admin - redirect to admin panel
    const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single()

    if (profile?.role === 'admin') {
        return redirect({ href: '/admin', locale })
    }

    // Fetch enrolled courses
    const { data: enrollments, error } = await supabase
        .from('user_progress')
        .select(`
            id,
            course_id,
            status,
            created_at,
            course:courses (
                id,
                title,
                description,
                cover_image,
                slug
            )
        `)
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })

    // Fetch Subscription
    // Explicitly typed as any to avoid complex relationship typing issues for now, 
    // or we can rely on inference if the relationships are set up in Supabase client types.
    const { data: subscription } = await supabase
        .from('subscriptions')
        .select(`
            *,
            price:prices(
                *,
                product:products(*)
            )
        `)
        .in('status', ['active', 'trialing'])
        .eq('user_id', user.id)
        .maybeSingle(); // Use maybeSingle to avoid 406 error if none found

    // Note: Empty enrollments is not an error, it's expected for new users

    const validEnrollments = (enrollments || [])
        .map(e => ({
            ...e,
            course: Array.isArray(e.course) ? e.course[0] : e.course
        }))
        .filter(e => e.course) as unknown as EnrolledCourse[]

    // Calculate progress for each course
    const coursesWithProgress = await Promise.all(
        validEnrollments.map(async (enrollment) => {
            const { data: progressData } = await supabase
                .rpc('calculate_course_progress', {
                    p_user_id: user.id,
                    p_course_id: enrollment.course_id
                })

            return {
                ...enrollment,
                progress: progressData || 0
            }
        })
    )

    // Fetch User Activity
    const { data: activities } = await supabase
        .from('user_activity')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(5)

    // Fetch User Badges
    const { data: badges } = await supabase
        .from('user_badges')
        .select(`
            id,
            earned_at,
            badge:badges (
                id,
                name,
                description,
                icon,
                tier
            )
        `)
        .eq('user_id', user.id)
        .order('earned_at', { ascending: false })
        .limit(5)

    const formattedBadges = (badges || []).map(b => ({
        ...b.badge,
        earned_at: b.earned_at
    }))

    // Fetch Recent Quiz Results
    const { data: recentQuizzesRaw } = await supabase
        .from('quiz_attempts')
        .select(`
            id,
            quiz_id,
            score,
            passed,
            created_at,
            quiz:quizzes (
                title,
                lesson:lessons (
                    module:course_modules (
                        course:courses (
                            title
                        )
                    )
                )
            )
        `)
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(3)

    // @ts-ignore - complex nested type
    const recentQuizzes = (recentQuizzesRaw || []).map((q: any) => {
        const quiz = Array.isArray(q.quiz) ? q.quiz[0] : q.quiz
        const lesson = quiz?.lesson && Array.isArray(quiz.lesson) ? quiz.lesson[0] : quiz?.lesson
        const module = lesson?.module && Array.isArray(lesson.module) ? lesson.module[0] : lesson?.module
        const course = module?.course && Array.isArray(module.course) ? module.course[0] : module?.course

        return {
            id: q.id,
            quiz_id: q.quiz_id,
            score: q.score,
            passed: q.passed,
            created_at: q.created_at,
            quiz: {
                title: quiz?.title || t('unknown_quiz'),
                course: {
                    title: course?.title || t('unknown_course')
                }
            }
        }
    })

    // Fetch Recommended Courses (Published courses not enrolled in)
    const enrolledCourseIds = validEnrollments.map(e => e.course_id)

    let recommendedQuery = supabase
        .from('courses')
        .select('id, title, description, slug, cover_image')
        .eq('published', true)

    if (enrolledCourseIds.length > 0) {
        recommendedQuery = recommendedQuery.not('id', 'in', `(${enrolledCourseIds.join(',')})`)
    }

    const { data: recommendedCourses } = await recommendedQuery.limit(3)

    return (
        <div className="space-y-8">
            <SubscriptionStatus subscription={subscription} />
            <DashboardContent
                courses={coursesWithProgress}
                userId={user.id}
                activities={activities || []}
                badges={formattedBadges || []}
                recentQuizzes={recentQuizzes || []}
                recommendedCourses={recommendedCourses || []}
            />
        </div>
    )
}
