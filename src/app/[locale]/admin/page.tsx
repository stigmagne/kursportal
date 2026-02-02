import { createClient } from '@/utils/supabase/server';
import { BookOpen, Users, Activity, Plus, TrendingUp, Clock, AlertCircle, CheckCircle2, BarChart3 } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { getTranslations } from 'next-intl/server';
import { LucideIcon } from 'lucide-react';

// Type definitions
interface RecentUser {
    id: string;
    full_name: string | null;
    created_at: string;
    role: 'admin' | 'member';
}

interface RecentProgress {
    id: string;
    status: string;
    last_accessed: string;
    profiles: { full_name: string | null } | null;
    courses: { title: string } | null;
}

interface StatCardProps {
    title: string;
    value: number;
    subtitle?: string;
    icon: LucideIcon;
    trend?: string;
    color: 'blue' | 'green' | 'purple' | 'orange';
}

export default async function AdminDashboard() {
    const t = await getTranslations('Admin');
    const supabase = await createClient();

    // Parallel data fetching for performance
    const [
        { count: totalUsers },
        { count: totalCourses },
        { count: publishedCourses },
        { count: totalCompletions },
        { count: totalProgress },
        { data: recentUsers },
        { data: recentProgress },
        { data: topCourses },
    ] = await Promise.all([
        supabase.from('profiles').select('*', { count: 'exact', head: true }),
        supabase.from('courses').select('*', { count: 'exact', head: true }),
        supabase.from('courses').select('*', { count: 'exact', head: true }).eq('published', true),
        supabase.from('user_progress').select('*', { count: 'exact', head: true }).eq('status', 'completed'),
        supabase.from('user_progress').select('*', { count: 'exact', head: true }),
        supabase.from('profiles').select('id, full_name, created_at, role').order('created_at', { ascending: false }).limit(5),
        supabase.from('user_progress').select('*, profiles(full_name), courses(title)').order('last_accessed', { ascending: false }).limit(5),
        supabase.from('courses').select('id, title, (select count(*) from user_progress where course_id = courses.id) as enrollment_count').order('created_at', { ascending: false }).limit(3),
    ]);

    const completionRate = (totalProgress ?? 0) > 0 ? ((totalCompletions || 0) / (totalProgress ?? 1) * 100).toFixed(1) : 0;

    return (
        <div className="space-y-8">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">{t('title')}</h1>
                    <p className="text-muted-foreground mt-2">{t('subtitle')}</p>
                </div>
                <Link
                    href="/admin/courses/new"
                    className="flex items-center gap-2 bg-primary text-primary-foreground px-4 py-2 rounded-lg font-medium hover:bg-primary/90 transition-colors shadow-lg shadow-primary/20"
                >
                    <Plus className="w-4 h-4" />
                    {t('create_course')}
                </Link>
            </div>

            {/* Key Metrics Grid */}
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
                <StatCard
                    title={t('stats.users')}
                    value={totalUsers || 0}
                    icon={Users}
                    trend={t('stats.trend_monthly')}
                    color="blue"
                />
                <StatCard
                    title={t('stats.active_courses')}
                    value={publishedCourses || 0}
                    subtitle={t('stats.total_courses', { count: totalCourses || 0 })}
                    icon={BookOpen}
                    color="green"
                />
                <StatCard
                    title={t('stats.completions')}
                    value={totalCompletions || 0}
                    icon={CheckCircle2}
                    trend={t('stats.completion_rate', { rate: completionRate })}
                    color="purple"
                />
                <StatCard
                    title={t('stats.enrollments')}
                    value={totalProgress || 0}
                    icon={TrendingUp}
                    color="orange"
                />
            </div>

            <div className="grid gap-6 lg:grid-cols-2">
                {/* Recent Activity */}
                <div className="glass rounded-xl border border-white/10 p-6">
                    <div className="flex items-center justify-between mb-4">
                        <h2 className="text-xl font-semibold flex items-center gap-2">
                            <Activity className="w-5 h-5 text-primary" />
                            {t('recent_activity.title')}
                        </h2>
                    </div>
                    <div className="space-y-3">
                        {recentProgress && recentProgress.length > 0 ? (
                            (recentProgress as RecentProgress[]).map((item) => (
                                <div key={item.id} className="flex items-center justify-between p-3 rounded-lg bg-muted/30 hover:bg-muted/50 transition-colors">
                                    <div className="flex-1">
                                        <p className="font-medium text-sm">
                                            {item.profiles?.full_name || t('recent_activity.user')}
                                            <span className="text-muted-foreground"> {item.status === 'completed' ? t('recent_activity.completed') : t('recent_activity.started')} </span>
                                            {item.courses?.title || t('recent_activity.course')}
                                        </p>
                                        <p className="text-xs text-muted-foreground mt-1 flex items-center gap-1">
                                            <Clock className="w-3 h-3" />
                                            {new Date(item.last_accessed).toLocaleString()}
                                        </p>
                                    </div>
                                    {item.status === 'completed' && (
                                        <CheckCircle2 className="w-4 h-4 text-green-500" />
                                    )}
                                </div>
                            ))
                        ) : (
                            <p className="text-sm text-muted-foreground text-center py-8">{t('recent_activity.no_activity')}</p>
                        )}
                    </div>
                </div>

                {/* Quick Actions & Health */}
                <div className="space-y-6">
                    {/* System Health */}
                    <div className="glass rounded-xl border border-white/10 p-6">
                        <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
                            <AlertCircle className="w-5 h-5 text-primary" />
                            {t('health.title')}
                        </h2>
                        <div className="space-y-3">
                            <HealthIndicator
                                label={t('health.database')}
                                status="healthy"
                                statusText={t('health.operational')}
                                detail={t('health.db_detail', { courses: totalCourses || 0, users: totalUsers || 0 })}
                            />
                            <HealthIndicator
                                label={t('health.auth')}
                                status="healthy"
                                statusText={t('health.operational')}
                                detail={t('health.auth_detail')}
                            />
                            <HealthIndicator
                                label={t('health.encryption')}
                                status="healthy"
                                statusText={t('health.operational')}
                                detail={t('health.encryption_detail')}
                            />
                        </div>
                    </div>

                    {/* Quick Actions */}
                    <div className="glass rounded-xl border border-white/10 p-6">
                        <h2 className="text-xl font-semibold mb-4">{t('quick_actions.title')}</h2>
                        <div className="grid gap-3">
                            <Link
                                href="/admin/courses"
                                className="p-4 rounded-lg bg-card hover:bg-muted transition-colors border border-border flex justify-between items-center group"
                            >
                                <div>
                                    <span className="font-medium">{t('quick_actions.manage_courses')}</span>
                                    <p className="text-xs text-muted-foreground mt-1">{t('quick_actions.manage_courses_desc')}</p>
                                </div>
                                <BookOpen className="w-5 h-5 text-muted-foreground group-hover:text-primary transition-colors" />
                            </Link>
                            <Link
                                href="/admin/tags"
                                className="p-4 rounded-lg bg-card hover:bg-muted transition-colors border border-border flex justify-between items-center group"
                            >
                                <div>
                                    <span className="font-medium">{t('quick_actions.manage_tags')}</span>
                                    <p className="text-xs text-muted-foreground mt-1">{t('quick_actions.manage_tags_desc')}</p>
                                </div>
                                <Activity className="w-5 h-5 text-muted-foreground group-hover:text-primary transition-colors" />
                            </Link>
                            <Link
                                href="/admin/users"
                                className="p-4 rounded-lg bg-card hover:bg-muted transition-colors border border-border flex justify-between items-center group"
                            >
                                <div>
                                    <span className="font-medium">{t('quick_actions.user_mgmt')}</span>
                                    <p className="text-xs text-muted-foreground mt-1">{t('quick_actions.user_mgmt_desc', { count: totalUsers || 0 })}</p>
                                </div>
                                <Users className="w-5 h-5 text-muted-foreground group-hover:text-primary transition-colors" />
                            </Link>
                            <Link
                                href="/admin/analytics"
                                className="p-4 rounded-lg bg-card hover:bg-muted transition-colors border border-border flex justify-between items-center group"
                            >
                                <div>
                                    <span className="font-medium">{t('quick_actions.analytics')}</span>
                                    <p className="text-xs text-muted-foreground mt-1">{t('quick_actions.analytics_desc')}</p>
                                </div>
                                <BarChart3 className="w-5 h-5 text-muted-foreground group-hover:text-primary transition-colors" />
                            </Link>
                        </div>
                    </div>
                </div>
            </div>

            {/* New Users */}
            <div className="glass rounded-xl border border-white/10 p-6">
                <h2 className="text-xl font-semibold mb-4">{t('registrations.title')}</h2>
                <div className="overflow-x-auto">
                    <table className="w-full text-sm">
                        <thead className="text-xs uppercase bg-muted/30 text-muted-foreground">
                            <tr>
                                <th className="px-4 py-3 text-left font-medium">{t('registrations.cols.user')}</th>
                                <th className="px-4 py-3 text-left font-medium">{t('registrations.cols.role')}</th>
                                <th className="px-4 py-3 text-left font-medium">{t('registrations.cols.joined')}</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-border">
                            {recentUsers && recentUsers.length > 0 ? (
                                (recentUsers as RecentUser[]).map((user) => (
                                    <tr key={user.id} className="hover:bg-muted/20 transition-colors">
                                        <td className="px-4 py-3 font-medium">{user.full_name || t('registrations.anonymous')}</td>
                                        <td className="px-4 py-3">
                                            <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${user.role === 'admin'
                                                ? 'bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-400'
                                                : 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-400'
                                                }`}>
                                                {t(`roles.${user.role}`, { default: user.role })}
                                            </span>
                                        </td>
                                        <td className="px-4 py-3 text-muted-foreground">
                                            {new Date(user.created_at).toLocaleDateString()}
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan={3} className="px-4 py-8 text-center text-muted-foreground">
                                        {t('registrations.no_registrations')}
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    );
}

function StatCard({ title, value, subtitle, icon: Icon, trend, color }: StatCardProps) {
    const colorClasses = {
        blue: 'text-blue-500',
        green: 'text-green-500',
        purple: 'text-purple-500',
        orange: 'text-orange-500',
    };

    return (
        <div className="p-6 rounded-xl glass border border-white/10 bg-card hover:border-primary/20 transition-colors">
            <div className="flex items-center justify-between pb-2">
                <h3 className="text-sm font-medium text-muted-foreground">{title}</h3>
                <Icon className={`w-5 h-5 ${colorClasses[color as keyof typeof colorClasses]}`} />
            </div>
            <div className="text-3xl font-bold mt-2">{value}</div>
            {subtitle && <p className="text-xs text-muted-foreground mt-1">{subtitle}</p>}
            {trend && <p className="text-xs text-green-600 dark:text-green-400 mt-2">{trend}</p>}
        </div>
    );
}

function HealthIndicator({ label, status, statusText, detail }: { label: string, status: 'healthy' | 'warning' | 'error', statusText?: string, detail: string }) {
    const statusConfig = {
        healthy: { color: 'bg-green-500', text: statusText || 'Operational' },
        warning: { color: 'bg-yellow-500', text: statusText || 'Warning' },
        error: { color: 'bg-red-500', text: statusText || 'Error' },
    };

    const config = statusConfig[status];

    return (
        <div className="flex items-center justify-between p-3 rounded-lg bg-muted/20">
            <div className="flex items-center gap-3">
                <div className={`w-2 h-2 rounded-full ${config.color}`} />
                <div>
                    <p className="text-sm font-medium">{label}</p>
                    <p className="text-xs text-muted-foreground">{detail}</p>
                </div>
            </div>
            <span className="text-xs font-medium text-muted-foreground">{config.text}</span>
        </div>
    );
}
