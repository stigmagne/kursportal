import { createClient } from '@/utils/supabase/server';
import { createClient } from '@/utils/supabase/server';
import dynamicClient from 'next/dynamic';
const AnalyticsCharts = dynamicClient(() => import('@/components/admin/AnalyticsCharts').then(mod => mod.AnalyticsCharts), {
    ssr: false,
    loading: () => <div className="h-[300px] w-full animate-pulse bg-muted/20 rounded-xl" />
});
import { getTranslations } from 'next-intl/server';
import { ArrowLeft } from 'lucide-react';
import { Link } from '@/i18n/routing';

export const dynamic = 'force-dynamic'; // Ensure real-time data

export default async function AnalyticsPage() {
    const t = await getTranslations('Admin');
    const supabase = await createClient();

    // Fetch daily activity stats via RPC
    const { data: activityData, error: activityError } = await supabase.rpc('get_daily_activity_stats', { days_lookback: 30 });

    if (activityError) console.error('Error fetching activity stats:', activityError);

    // Fetch Top 5 Courses by enrollment with completion rates
    // We fetch courses and their progress stats
    const { data: courses, error: coursesError } = await supabase
        .from('courses')
        .select('id, title')
        .order('created_at', { ascending: false }); // Get all, we filter in JS for now or top 5

    // Get aggregate stats for courses (manual aggregation for now as SQL view might be overkill for MVP)
    const { data: allProgress } = await supabase
        .from('user_progress')
        .select('course_id, status');

    const courseStats = courses?.map(course => {
        const enrollments = allProgress?.filter(p => p.course_id === course.id) || [];
        const completed = enrollments.filter(p => p.status === 'completed').length;
        const total = enrollments.length;

        return {
            title: course.title,
            enrollment_count: total,
            completion_rate: total > 0 ? Math.round((completed / total) * 100) : 0
        };
    })
        .sort((a, b) => b.enrollment_count - a.enrollment_count)
        .slice(0, 5) || [];

    return (
        <div className="space-y-8">
            <div className="flex items-center gap-4">
                <Link
                    href="/admin"
                    className="p-2 hover:bg-white/5 rounded-full transition-colors"
                >
                    <ArrowLeft className="w-5 h-5" />
                </Link>
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">Analyse & Statistikk</h1>
                    <p className="text-muted-foreground mt-2">Dybdeinnsikt i plattformbruk og læring</p>
                </div>
            </div>

            <AnalyticsCharts
                activityData={activityData || []}
                courseData={courseStats}
            />
        </div>
    );
}
