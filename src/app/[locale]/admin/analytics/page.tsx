import { createClient } from '@/utils/supabase/server';
import { Users, BookOpen, GraduationCap, Activity, Award, CheckCircle, TrendingUp, Target, RefreshCcw } from 'lucide-react';
import StatsCard from '@/components/admin/analytics/StatsCard';
import CourseCompletionChart from '@/components/admin/analytics/CourseCompletionChart';
import { getTranslations } from 'next-intl/server';
import AnalyticsDashboardClient from '@/components/admin/analytics/AnalyticsDashboardClient';

export default async function AnalyticsPage() {
    const t = await getTranslations('AdminAnalytics');
    // We need to move the client-side logic (useState/useEffect) to a client component
    // OR keep this as server component and fetch data server side.
    // The original file was 'use client' (Line 1).
    // If I keep it 'use client', I cannot use 'getTranslations' (async server only) nicely without passing it as props or using useTranslations.
    // However, the original file was checking supabase RPCs.
    // Let's refactor: Make this page a Server Component that wraps a Client Component.

    // Actually, to minimize refactoring risk, I'll keep it 'use client' and use `useTranslations`.
    // But `src/app/[locale]/...` pages are usually Server Components by default in Next.js 13+ app dir unless "use client" is at top.
    // The previous file HAD "use client" at top.
    // So I should use `useTranslations` from `next-intl`.

    return <AnalyticsDashboardClient />;
}
