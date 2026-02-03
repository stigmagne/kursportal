'use client';

import dynamic from 'next/dynamic';

const AnalyticsCharts = dynamic(() => import('@/components/admin/AnalyticsCharts').then(mod => mod.AnalyticsCharts), {
    ssr: false,
    loading: () => <div className="h-[300px] w-full animate-pulse bg-muted/20 rounded-xl" />
});

export default function AnalyticsChartsWrapper(props: React.ComponentProps<typeof AnalyticsCharts>) {
    return <AnalyticsCharts {...props} />;
}
