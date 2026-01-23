

import { createClient } from '@/utils/supabase/server'
import { getTranslations } from 'next-intl/server';
import { redirect } from 'next/navigation';
import CourseList from '@/components/student/CourseList';

export default async function CoursesPage() {
  const t = await getTranslations('Courses');
  const supabase = await createClient()

  // Require authentication
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    redirect('/login')
  }

  // Fetch available tags
  const { data: tags } = await supabase
    .from('tags')
    .select('id, name, slug')
    .order('name');

  // Fetch only published courses (RLS will filter by user's group)
  // We also need to fetch the course tags
  const { data: coursesData } = await supabase
    .from('courses')
    .select(`
      id,
      title,
      description,
      course_tags (
        tag:tags (
          slug
        )
      )
    `)
    .eq('published', true)
    .order('created_at', { ascending: false });

  // Transform data
  const courses = coursesData?.map(course => ({
    id: course.id,
    title: course.title,
    description: course.description,
    tags: course.course_tags.map((ct: any) => ct.tag.slug)
  })) || [];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="mb-12 text-center">
        <h1 className="text-4xl font-bold tracking-tight mb-4">{t('title')}</h1>
        <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
          {t('subtitle')}
        </p>
      </div>

      <CourseList
        initialCourses={courses}
        availableTags={tags || []}
        translations={{
          start_course: t('start_course'),
          no_courses: t('no_description'), // fallback if desc missing
          filter_by_tags: t('filter_by_tags'),
          clear_filters: t('clear_filters'),
          no_results: t('no_results_filters')
        }}
      />
    </div>
  )
}
