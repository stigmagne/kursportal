import { createClient } from '@/utils/supabase/server';
import { redirect, notFound } from 'next/navigation';
import CourseSidebar from '@/components/student/CourseSidebar';
import LessonViewer from '@/components/student/LessonViewer';
import { LessonNavigation } from '@/components/student/LessonNavigation';
import { LessonComments } from '@/components/student/LessonComments';
import { hasAccessToCourse } from '@/utils/paywall';

export default async function LessonPage({ params }: { params: Promise<{ id: string; lessonId: string }> }) {
    const { id: courseId, lessonId } = await params;
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
        notFound();
    }

    // Get current lesson with content blocks
    const { data: lesson } = await supabase
        .from('lessons')
        .select(`
            *,
            lesson_content (
                id,
                type,
                order_index,
                text_content,
                video_url,
                file_url,
                file_name
            ),
            module:course_modules!inner(id, title, course_id)
        `)
        .eq('id', lessonId)
        .single();

    if (!lesson || lesson.module.course_id !== courseId) {
        notFound();
    }

    // CHECK #1: Prerequisites - Can user access this lesson?
    const { data: canAccessPrereq } = await supabase
        .rpc('can_access_lesson', {
            p_user_id: user.id,
            p_lesson_id: lessonId
        });

    if (!canAccessPrereq) {
        // Prerequisites not met - redirect back
        redirect(`/courses/${courseId}/learn`);
    }

    // CHECK #2: Drip Schedule - Is this lesson unlocked by date/time?
    const { data: isUnlockedByDrip } = await supabase
        .rpc('is_lesson_unlocked_by_drip', {
            p_user_id: user.id,
            p_lesson_id: lessonId
        });

    if (!isUnlockedByDrip) {
        // Not unlocked by drip schedule yet - redirect back
        redirect(`/courses/${courseId}/learn`);
    }

    // Get user's completed lessons FOR THIS COURSE ONLY
    const { data: completions } = await supabase
        .from('lesson_completion')
        .select(`
            lesson_id,
            lessons!inner (
                id,
                module:course_modules!inner (
                    course_id
                )
            )
        `)
        .eq('user_id', user.id)
        .eq('lessons.module.course_id', courseId);

    const completedLessonIds = new Set(completions?.map(c => c.lesson_id) || []);

    return (
        <div className="flex min-h-screen">
            {/* Sidebar */}
            <CourseSidebar
                course={course}
                currentLessonId={lessonId}
                completedLessonIds={completedLessonIds}
                userId={user.id}
            />

            {/* Main Content */}
            <div className="flex-1 flex flex-col">
                <div className="flex-1 overflow-y-auto">
                    <LessonViewer lesson={lesson} userId={user.id} />

                    {/* Comments Section */}
                    <div className="max-w-4xl mx-auto px-6 py-8">
                        <LessonComments lessonId={lessonId} />
                    </div>
                </div>

                <LessonNavigation
                    courseId={courseId}
                    currentLessonId={lessonId}
                />
            </div>
        </div>
    );
}
