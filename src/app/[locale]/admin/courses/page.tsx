import { createAdminClient } from '@/utils/supabase/admin'
import { Link } from '@/i18n/routing'
import { Plus } from 'lucide-react'
import CourseList from '@/components/admin/CourseList'
import CourseImporter from '@/components/admin/CourseImporter'
import { getTranslations } from 'next-intl/server';

export default async function AdminCoursesPage() {
    const t = await getTranslations('AdminCourses');
    // Use admin client with service role to bypass RLS
    // Admin access is already verified in the layout
    const supabase = createAdminClient()

    // Fetch courses with their target groups (stored directly on courses table)
    const { data: courses } = await supabase
        .from('courses')
        .select(`*`)
        .order('created_at', { ascending: false })

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold">{t('title')}</h1>
                <div className="flex gap-2">
                    <CourseImporter />
                    <Link
                        href="/admin/courses/new"
                        className="flex items-center gap-2 bg-primary text-primary-foreground px-4 py-2 rounded-lg text-sm font-medium hover:bg-primary/90 transition-colors"
                    >
                        <Plus className="w-4 h-4" />
                        {t('new_course')}
                    </Link>
                </div>
            </div>

            <CourseList initialCourses={courses || []} />
        </div>
    )
}
