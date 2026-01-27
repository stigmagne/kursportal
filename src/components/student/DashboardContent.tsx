'use client';

import { useState } from 'react';
import CourseCard from './CourseCard';
import EmptyDashboard from './EmptyDashboard';
import CertificatesList from './CertificatesList';
import { Search, Award, BookOpen, Clock, Activity } from 'lucide-react';
import { useTranslations } from 'next-intl';
import ContinueLearning from './ContinueLearning';
import RecentActivity from './RecentActivity';
import RecentBadges from './RecentBadges';
import RecentQuizResults from './RecentQuizResults';
import RecommendedCourses from './RecommendedCourses';

interface CourseEnrollment {
    id: string;
    course_id: string;
    course: {
        id: string;
        title: string;
        description: string;
        cover_image: string | null;
        slug: string;
    };
    progress: number;
    status: string;
    created_at: string;
}

interface ActivityItem {
    id: string;
    action: string;
    activity_type: string;
    description: string;
    created_at: string;
    metadata: Record<string, unknown>;
}

interface Badge {
    id: string;
    name: string;
    description: string;
    icon: string;
    tier: 'bronze' | 'silver' | 'gold' | 'platinum';
    earned_at: string;
}

interface QuizResult {
    id: string;
    quiz_id: string;
    quiz_title: string;
    quiz: { title: string; course: { title: string } };
    score: number;
    passed: boolean;
    created_at: string;
}

interface RecommendedCourse {
    id: string;
    title: string;
    description: string;
    slug: string;
    cover_image: string | null;
}

interface DashboardContentProps {
    courses: CourseEnrollment[];
    userId: string;
    activities: ActivityItem[];
    badges: Badge[];
    recentQuizzes: QuizResult[];
    recommendedCourses: RecommendedCourse[];
}

export default function DashboardContent({
    courses,
    userId,
    activities,
    badges,
    recentQuizzes,
    recommendedCourses
}: DashboardContentProps) {
    const t = useTranslations('Dashboard');
    const [activeTab, setActiveTab] = useState<'courses' | 'certificates'>('courses');
    const [searchQuery, setSearchQuery] = useState('');
    const [filterTab, setFilterTab] = useState<'all' | 'in-progress' | 'completed'>('all');
    const [sortBy, setSortBy] = useState<'recent' | 'progress' | 'name'>('recent');

    // Find the most recent active course for "Continue Learning"
    const lastActiveCourse = courses
        .filter(c => c.progress > 0 && c.progress < 100)
        .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())[0];

    // Apply filters and sorting
    let filteredCourses = [...courses];

    // Filter by search query
    if (searchQuery) {
        filteredCourses = filteredCourses.filter(c =>
            c.course.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
            c.course.description?.toLowerCase().includes(searchQuery.toLowerCase())
        );
    }

    // Filter by status
    if (filterTab === 'in-progress') {
        filteredCourses = filteredCourses.filter(c => c.progress > 0 && c.progress < 100);
    } else if (filterTab === 'completed') {
        filteredCourses = filteredCourses.filter(c => c.progress >= 100);
    }

    // Sort
    filteredCourses.sort((a, b) => {
        if (sortBy === 'progress') {
            return b.progress - a.progress; // Highest progress first
        } else if (sortBy === 'name') {
            return a.course.title.localeCompare(b.course.title);
        } else {
            // Sort by enrollment date (most recent first)
            return new Date(b.created_at).getTime() - new Date(a.created_at).getTime();
        }
    });

    const showEmptyState = courses.length === 0 && recommendedCourses.length === 0;

    if (showEmptyState) {
        return <EmptyDashboard />;
    }

    return (
        <div className="min-h-screen bg-linear-to-b from-background to-muted/20 py-12">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
                {/* Header */}
                <div>
                    <h1 className="text-4xl font-bold mb-2">{t('title')}</h1>
                    <p className="text-muted-foreground">
                        {t('subtitle_courses')}
                    </p>
                </div>

                {/* Continue Learning Section */}
                {lastActiveCourse && (
                    <section>
                        <ContinueLearning course={lastActiveCourse} />
                    </section>
                )}

                {/* Dashboard Widgets Grid */}
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    {/* Main Content Column (2/3) */}
                    <div className="lg:col-span-2 space-y-6">
                        {/* Course & Certificate Tabs */}
                        <div className="bg-card rounded-xl border shadow-sm overflow-hidden">
                            <div className="flex border-b">
                                <button
                                    onClick={() => setActiveTab('courses')}
                                    className={`flex-1 flex items-center justify-center gap-2 px-4 py-4 font-medium transition-colors ${activeTab === 'courses'
                                        ? 'bg-primary/5 text-primary border-b-2 border-primary'
                                        : 'text-muted-foreground hover:bg-muted/50'
                                        }`}
                                >
                                    <BookOpen className="w-4 h-4" />
                                    {t('tab_courses')}
                                </button>
                                <button
                                    onClick={() => setActiveTab('certificates')}
                                    className={`flex-1 flex items-center justify-center gap-2 px-4 py-4 font-medium transition-colors ${activeTab === 'certificates'
                                        ? 'bg-primary/5 text-primary border-b-2 border-primary'
                                        : 'text-muted-foreground hover:bg-muted/50'
                                        }`}
                                >
                                    <Award className="w-4 h-4" />
                                    {t('tab_certificates')}
                                </button>
                            </div>

                            <div className="p-6">
                                {activeTab === 'courses' && (
                                    <>
                                        {/* Search and Filters */}
                                        <div className="space-y-4 mb-6">
                                            <div className="flex flex-col sm:flex-row gap-4">
                                                <div className="relative flex-1">
                                                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                                                    <input
                                                        type="text"
                                                        placeholder={t('search_placeholder')}
                                                        value={searchQuery}
                                                        onChange={(e) => setSearchQuery(e.target.value)}
                                                        className="w-full pl-9 pr-4 py-2 rounded-lg bg-background border text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                                                    />
                                                </div>
                                                <select
                                                    value={filterTab}
                                                    onChange={(e) => setFilterTab(e.target.value as any)}
                                                    className="px-3 py-2 rounded-lg bg-background border text-sm"
                                                >
                                                    <option value="all">{t('filter_all')}</option>
                                                    <option value="in-progress">{t('filter_in_progress')}</option>
                                                    <option value="completed">{t('filter_completed')}</option>
                                                </select>
                                            </div>
                                        </div>

                                        {filteredCourses.length === 0 ? (
                                            <div className="text-center py-12 text-muted-foreground">
                                                {searchQuery ? t('no_match') : t('no_courses')}
                                            </div>
                                        ) : (
                                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                                {filteredCourses.map((enrollment) => (
                                                    <CourseCard
                                                        key={enrollment.id}
                                                        course={enrollment.course}
                                                        progress={enrollment.progress}
                                                        status={enrollment.status}
                                                        enrolledDate={enrollment.created_at}
                                                        userId={userId}
                                                    />
                                                ))}
                                            </div>
                                        )}
                                    </>
                                )}

                                {activeTab === 'certificates' && (
                                    <CertificatesList userId={userId} />
                                )}
                            </div>
                        </div>

                        {/* Recommended Courses */}
                        {recommendedCourses.length > 0 && (
                            <section>
                                <RecommendedCourses courses={recommendedCourses} />
                            </section>
                        )}
                    </div>

                    {/* Sidebar Column (1/3) - Hidden on mobile for focused experience */}
                    <div className="hidden lg:block space-y-6">
                        <RecentBadges badges={badges} />
                        <RecentQuizResults results={recentQuizzes} />
                        <RecentActivity activities={activities} />
                    </div>
                </div>
            </div>
        </div>
    );
}
