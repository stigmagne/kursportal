'use client';

import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { useTranslations } from 'next-intl';

interface CourseCompletionChartProps {
    data: {
        course_title: string;
        completion_rate: number;
        total_enrolled: number;
    }[];
}

export default function CourseCompletionChart({ data }: CourseCompletionChartProps) {
    const t = useTranslations('AdminAnalytics');
    const chartData = data.map(item => ({
        name: item.course_title.length > 20 ? item.course_title.substring(0, 20) + '...' : item.course_title,
        completionRate: Number(item.completion_rate),
        enrolled: item.total_enrolled
    }));

    return (
        <div className="glass p-6 rounded-xl border border-white/10">
            <h3 className="text-lg font-semibold mb-4">{t('charts.completion_rates')}</h3>
            <ResponsiveContainer width="100%" height={300}>
                <BarChart data={chartData}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#333" />
                    <XAxis dataKey="name" stroke="#888" />
                    <YAxis stroke="#888" />
                    <Tooltip
                        contentStyle={{ backgroundColor: '#1f1f1f', border: '1px solid #333' }}
                        formatter={(value: any, name: any) => {
                            if (name === 'completionRate') return [`${value.toFixed(1)}%`, t('charts.completion_rate')];
                            return [value, t('charts.enrolled')];
                        }}
                    />
                    <Bar dataKey="completionRate" fill="#2563eb" radius={[8, 8, 0, 0]} />
                </BarChart>
            </ResponsiveContainer>
        </div>
    );
}
