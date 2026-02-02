


import { createClient } from '@/utils/supabase/server'
import { getTranslations } from 'next-intl/server';
import { redirect } from 'next/navigation';
import CourseList from '@/components/student/CourseList';
import { Link } from '@/i18n/routing';
import { Lock, Users, Heart, Briefcase, UserCog } from 'lucide-react';
import { getUserGroups, TARGET_GROUP_LABELS, TargetGroup } from '@/utils/userGroups';

const GROUP_ICONS: Record<TargetGroup, React.ComponentType<{ className?: string }>> = {
  'sibling': Users,
  'parent': Heart,
  'team-member': Briefcase,
  'team-leader': UserCog
};

export default async function CoursesPage() {
  const t = await getTranslations('Courses');
  const supabase = await createClient()

  // Require authentication
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    redirect('/login')
  }

  // Check if user is admin
  const { data: profile } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single();

  const isAdmin = profile?.role === 'admin';

  // Fetch user's target groups (the new system)
  const userGroups = await getUserGroups(supabase, user.id);

  // Fetch available tags
  const { data: tags } = await supabase
    .from('tags')
    .select('id, name, slug')
    .order('name');

  // Fetch only published courses (or all for admins)
  const coursesQuery = supabase
    .from('courses')
    .select(`
      id,
      title,
      description,
      target_group,
      published,
      course_tags (
        tag:tags (
          slug
        )
      )
    `)
    .order('created_at', { ascending: false });

  // Only filter by published if not admin
  if (!isAdmin) {
    coursesQuery.eq('published', true);
  }

  const { data: coursesData } = await coursesQuery;

  // Filter courses based on user's groups
  // - Admins see all courses
  // - If user has no groups, show nothing (they need an invitation first)
  // - If course has no target_group, it's public (show to all)
  // - If course has target_group, only show if user has that group
  const courses = coursesData?.map(course => {
    const canAccess =
      isAdmin || // Admins can access all
      !course.target_group || // No restriction (public course)
      userGroups.includes(course.target_group as TargetGroup);

    return {
      id: course.id,
      title: course.title,
      description: course.description,
      tags: course.course_tags.map((ct: any) => ct.tag?.slug).filter(Boolean),
      targetGroup: course.target_group as TargetGroup | null,
      isLocked: !canAccess
    };
  }) || [];

  // Only show courses the user has access to
  const accessibleCourses = courses.filter(c => !c.isLocked);

  // Don't show locked courses from other groups at all
  // This keeps content completely separated as requested

  // Show message if user has no groups assigned (but not for admins)
  const hasNoGroups = userGroups.length === 0 && !isAdmin;

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="mb-12 text-center">
        <h1 className="text-4xl font-bold tracking-tight mb-4">{t('title')}</h1>
        <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
          {t('subtitle')}
        </p>
      </div>

      {/* Show which groups user has access to */}
      {userGroups.length > 0 && (
        <div className="mb-8 flex flex-wrap gap-2 justify-center">
          {userGroups.map(group => {
            const Icon = GROUP_ICONS[group];
            return (
              <span
                key={group}
                className="inline-flex items-center gap-2 px-4 py-2 bg-primary/10 border border-primary/20 rounded-full text-sm"
              >
                <Icon className="w-4 h-4" />
                {TARGET_GROUP_LABELS[group]}
              </span>
            );
          })}
        </div>
      )}

      {/* No groups assigned message */}
      {hasNoGroups && (
        <div className="mb-8 p-6 rounded-none border-2 border-amber-500 bg-amber-500/10 text-center">
          <h2 className="font-bold text-xl mb-2">Ingen tilgang registrert</h2>
          <p className="text-muted-foreground mb-4">
            Du har ikke fått tildelt tilgang til noen kursgruppe ennå.
            Kontakt din administrator eller bruk en invitasjonslenke for å få tilgang.
          </p>
        </div>
      )}

      {/* Accessible Courses */}
      {accessibleCourses.length > 0 && (
        <CourseList
          initialCourses={accessibleCourses}
          availableTags={tags || []}
          translations={{
            start_course: t('start_course'),
            no_courses: t('no_description'),
            filter_by_tags: t('filter_by_tags'),
            clear_filters: t('clear_filters'),
            no_results: t('no_results_filters')
          }}
        />
      )}

      {/* No courses available for user's groups */}
      {!hasNoGroups && accessibleCourses.length === 0 && (
        <div className="text-center py-12 text-muted-foreground">
          <p>Ingen kurs tilgjengelig for dine grupper ennå.</p>
        </div>
      )}
    </div>
  )
}
