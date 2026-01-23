import { createClient } from '@/utils/supabase/server';
import { getTranslations } from 'next-intl/server';
import { redirect } from 'next/navigation';
import CourseSidebar from '@/components/student/CourseSidebar';
import LessonViewer from '@/components/student/LessonViewer';
import { hasAccessToCourse } from '@/utils/paywall';

export default async function LearnPage({ params }: { params: Promise<{ id: string }> }) {
    const { id: courseId } = await params;
    const supabase = await createClient();

    // Get current user
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        redirect('/login');
    }

    // Check access (Paywall)
    const hasAccess = await hasAccessToCourse(user.id, courseId);
    if (!hasAccess) {
        redirect('/pricing');
    }

    // Check enrollment for progress tracking (optional, but used for logic below)
    // We keep this to ensure we don't break logic that expects 'enrollment' variable if used later?
    // Looking at the code: 'enrollment' variable is NOT used later.
    // So we can remove the enrollment query entirely.

    // Get course with modules and lessons
    const { data: course } = await supabase
        .from('courses')
        .select(`
            *,
            course_modules!course_modules_course_id_fkey (
                id,
                title,
                description,
                order_index,
                lessons (
                    id,
                    title,
                    description,
                    order_index,
                    duration_minutes
                )
            )
        `)
        .eq('id', courseId)
        .single();

    if (!course) {
        redirect('/courses');
    }

    // Get user's completed lessons
    const { data: completions } = await supabase
        .from('lesson_completion')
        .select('lesson_id')
        .eq('user_id', user.id);

    const completedLessonIds = new Set(completions?.map(c => c.lesson_id) || []);

    // Find first incomplete lesson
    let firstIncompleteLesson = null;
    for (const module of course.course_modules || []) {
        for (const lesson of module.lessons || []) {
            if (!completedLessonIds.has(lesson.id)) {
                firstIncompleteLesson = lesson;
                break;
            }
        }
        if (firstIncompleteLesson) break;
    }

    // If all complete, show first lesson
    const redirectLesson = firstIncompleteLesson ||
        course.course_modules?.[0]?.lessons?.[0];

    if (redirectLesson) {
        redirect(`/courses/${courseId}/learn/${redirectLesson.id}`);
    }

    // No lessons in course
    const t = await getTranslations('CourseDetails');

    return (
        <div className="min-h-screen flex items-center justify-center">
            <div className="text-center">
                <h1 className="text-2xl font-bold mb-2">{t('no_lessons.title')}</h1>
                <p className="text-muted-foreground">{t('no_lessons.description')}</p>
            </div>
        </div>
    );
}
