'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import StatsCard from '@/components/admin/analytics/StatsCard';
import CourseCompletionChart from '@/components/admin/analytics/CourseCompletionChart';
import { Users, BookOpen, TrendingUp, Award, Target, RefreshCcw } from 'lucide-react';
import { useTranslations } from 'next-intl';

export default function AnalyticsDashboardClient() {
    const t = useTranslations('AdminAnalytics');
    const supabase = createClient();
    const [loading, setLoading] = useState(true);
    const [stats, setStats] = useState<any>({
        total_students: 0,
        total_courses: 0,
        total_enrollments: 0,
        total_certificates: 0,
        avg_completion_rate: 0
    });
    const [courseData, setCourseData] = useState<any[]>([]);
    const [quizData, setQuizData] = useState<any[]>([]);
    const [avgQuizPassRate, setAvgQuizPassRate] = useState(0);

    const fetchData = async () => {
        setLoading(true);

        // Fetch platform stats
        const { data: statsData } = await supabase.rpc('get_platform_stats');
        if (statsData) {
            setStats(statsData);
        }

        // Fetch course completion rates
        const { data: courseRates } = await supabase.rpc('get_course_completion_rates');
        setCourseData(courseRates || []);

        // Fetch quiz stats
        const { data: quizStats } = await supabase.rpc('get_quiz_stats');
        setQuizData(quizStats || []);

        const avgPassRate = quizStats && quizStats.length > 0
            ? (quizStats.reduce((sum: number, q: any) => sum + Number(q.pass_rate), 0) / quizStats.length).toFixed(1)
            : 0;
        setAvgQuizPassRate(Number(avgPassRate));

        setLoading(false);
    };

    useEffect(() => {
        fetchData();
    }, []);

    if (loading) {
        return (
            <div className="min-h-screen bg-linear-to-b from-background to-muted/20 py-12">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="animate-pulse space-y-8">
                        <div className="h-20 bg-muted rounded-xl"></div>
                        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                            {[1, 2, 3, 4, 5, 6].map(i => (
                                <div key={i} className="h-32 bg-muted rounded-xl"></div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-linear-to-b from-background to-muted/20 py-12">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                {/* Header */}
                <div className="mb-8 flex items-center justify-between">
                    <div>
                        <h1 className="text-4xl font-bold mb-2">{t('title')}</h1>
                        <p className="text-muted-foreground">
                            {t('subtitle')}
                        </p>
                    </div>
                    <button
                        onClick={fetchData}
                        disabled={loading}
                        className="flex items-center gap-2 px-4 py-2 bg-muted hover:bg-muted/80 rounded-lg transition-colors disabled:opacity-50"
                        title={t('refresh')}
                    >
                        <RefreshCcw className="w-4 h-4" />
                        {t('refresh')}
                    </button>
                </div>

                {/* Stats Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
                    <StatsCard
                        title={t('stats.students')}
                        value={stats.total_students}
                        icon={Users}
                        iconColor="text-blue-500"
                    />
                    <StatsCard
                        title={t('stats.published_courses')}
                        value={stats.total_courses}
                        icon={BookOpen}
                        iconColor="text-purple-500"
                    />
                    <StatsCard
                        title={t('stats.enrollments')}
                        value={stats.total_enrollments}
                        icon={TrendingUp}
                        iconColor="text-green-500"
                    />
                    <StatsCard
                        title={t('stats.completion')}
                        value={`${Number(stats.avg_completion_rate).toFixed(1)}%`}
                        icon={Target}
                        iconColor="text-orange-500"
                    />
                    <StatsCard
                        title={t('stats.certificates')}
                        value={stats.total_certificates}
                        icon={Award}
                        iconColor="text-yellow-500"
                    />
                    <StatsCard
                        title={t('stats.quiz_rate')}
                        value={`${avgQuizPassRate}%`}
                        icon={Target}
                        iconColor="text-cyan-500"
                    />
                </div>

                {/* Course Completion Chart */}
                {courseData && courseData.length > 0 && (
                    <div className="mb-8">
                        <CourseCompletionChart data={courseData} />
                    </div>
                )}

                {/* Quiz Stats Table */}
                {quizData && quizData.length > 0 && (
                    <div className="glass p-6 rounded-xl border border-white/10">
                        <h3 className="text-lg font-semibold mb-4">{t('quiz_table.title')}</h3>
                        <div className="overflow-x-auto">
                            <table className="w-full">
                                <thead>
                                    <tr className="border-b border-border">
                                        <th className="text-left py-3 px-4 text-sm font-medium text-muted-foreground">{t('quiz_table.quiz')}</th>
                                        <th className="text-left py-3 px-4 text-sm font-medium text-muted-foreground">{t('quiz_table.course')}</th>
                                        <th className="text-center py-3 px-4 text-sm font-medium text-muted-foreground">{t('quiz_table.attempts')}</th>
                                        <th className="text-center py-3 px-4 text-sm font-medium text-muted-foreground">{t('quiz_table.pass_rate')}</th>
                                        <th className="text-center py-3 px-4 text-sm font-medium text-muted-foreground">{t('quiz_table.avg_score')}</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {quizData.map((quiz: any) => (
                                        <tr key={quiz.quiz_id} className="border-b border-border/50 hover:bg-muted/30">
                                            <td className="py-3 px-4 text-sm">{quiz.quiz_title}</td>
                                            <td className="py-3 px-4 text-sm text-muted-foreground">{quiz.course_title}</td>
                                            <td className="py-3 px-4 text-sm text-center">{quiz.total_attempts}</td>
                                            <td className="py-3 px-4 text-sm text-center">
                                                <span className={`px-2 py-1 rounded ${Number(quiz.pass_rate) >= 70 ? 'bg-green-600/20 text-green-600' : 'bg-red-600/20 text-red-600'
                                                    }`}>
                                                    {Number(quiz.pass_rate).toFixed(1)}%
                                                </span>
                                            </td>
                                            <td className="py-3 px-4 text-sm text-center">{Number(quiz.avg_score).toFixed(1)}%</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                )}

                {/* No data states */}
                {(!courseData || courseData.length === 0) && (!quizData || quizData.length === 0) && (
                    <div className="text-center py-12 text-muted-foreground">
                        <p>{t('empty')}</p>
                    </div>
                )}
            </div>
        </div>
    );
}
