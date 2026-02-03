'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Award, Lock, Star, Trophy, Medal, Zap, Target, BookOpen, MessageSquare, GraduationCap } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { motion } from 'framer-motion';

interface Badge {
    id: string;
    name: string;
    description: string;
    icon: string;
    tier: string;
    earned_at?: string;
}

interface BadgeProgress {
    badge: Badge;
    earned: boolean;
    progress?: number;
    total?: number;
}

export function BadgeCollection() {
    const [badges, setBadges] = useState<BadgeProgress[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const supabase = createClient();
    const t = useTranslations('Profile');

    useEffect(() => {
        fetchBadges();
    }, []);

    const fetchBadges = async () => {
        const { data: user } = await supabase.auth.getUser();
        if (!user.user) return;

        // Fetch all badges
        const { data: allBadges } = await supabase
            .from('badges')
            .select('*')
            .order('tier', { ascending: true });

        // Fetch user's earned badges
        const { data: earnedBadges } = await supabase
            .from('user_badges')
            .select('badge_id, earned_at')
            .eq('user_id', user.user.id);

        if (allBadges) {
            const earnedIds = new Set(earnedBadges?.map(b => b.badge_id) || []);

            // Get progress for each badge
            const badgesWithProgress = await Promise.all(
                allBadges.map(async (badge) => {
                    const earned = earnedIds.has(badge.id);
                    const earnedData = earnedBadges?.find(b => b.badge_id === badge.id);

                    let progress = 0;
                    let total = 0;

                    if (!earned) {
                        // Calculate progress based on criteria
                        const criteria = badge.criteria as any;
                        total = criteria.count || 0;

                        switch (criteria.type) {
                            case 'courses_completed':
                                const { count: coursesCount } = await supabase
                                    .from('user_progress')
                                    .select('*', { count: 'exact', head: true })
                                    .eq('user_id', user.user.id)
                                    .eq('completed', true);
                                progress = coursesCount || 0;
                                break;

                            case 'quizzes_passed':
                                const { count: quizzesCount } = await supabase
                                    .from('quiz_attempts')
                                    .select('*', { count: 'exact', head: true })
                                    .eq('user_id', user.user.id)
                                    .eq('passed', true);
                                progress = quizzesCount || 0;
                                break;

                            case 'perfect_quizzes':
                                const { count: perfectCount } = await supabase
                                    .from('quiz_attempts')
                                    .select('*', { count: 'exact', head: true })
                                    .eq('user_id', user.user.id)
                                    .eq('score', 100);
                                progress = perfectCount || 0;
                                break;

                            case 'certificates_earned':
                                const { count: certsCount } = await supabase
                                    .from('certificates')
                                    .select('*', { count: 'exact', head: true })
                                    .eq('user_id', user.user.id);
                                progress = certsCount || 0;
                                break;

                            case 'comments_posted':
                                const { count: commentsCount } = await supabase
                                    .from('lesson_comments')
                                    .select('*', { count: 'exact', head: true })
                                    .eq('user_id', user.user.id);
                                progress = commentsCount || 0;
                                break;
                        }
                    }

                    return {
                        badge,
                        earned,
                        progress: earned ? undefined : progress,
                        total: earned ? undefined : total,
                        earned_at: earnedData?.earned_at,
                    };
                })
            );

            setBadges(badgesWithProgress);
        }
        setIsLoading(false);
    };

    const getTierColor = (tier: string) => {
        switch (tier) {
            case 'bronze': return 'from-amber-600 to-amber-800 border-amber-900';
            case 'silver': return 'from-slate-400 to-slate-600 border-slate-700';
            case 'gold': return 'from-yellow-400 to-yellow-600 border-yellow-700';
            case 'platinum': return 'from-purple-400 to-purple-600 border-purple-900';
            default: return 'from-gray-400 to-gray-600 border-gray-700';
        }
    };

    const getBadgeIcon = (iconStr: string) => {
        // Map common emojis to Lucide icons
        const map: Record<string, React.ReactNode> = {
            '🏆': <Trophy className="w-8 h-8" />,
            '🥇': <Medal className="w-8 h-8" />,
            '🥈': <Medal className="w-8 h-8" />,
            '🥉': <Medal className="w-8 h-8" />,
            '⭐': <Star className="w-8 h-8" />,
            '🌟': <Star className="w-8 h-8" />,
            '⚡': <Zap className="w-8 h-8" />,
            '🎯': <Target className="w-8 h-8" />,
            '📚': <BookOpen className="w-8 h-8" />,
            '🎓': <GraduationCap className="w-8 h-8" />,
            '💬': <MessageSquare className="w-8 h-8" />,
        };

        return map[iconStr] || <Award className="w-8 h-8" />;
    };

    if (isLoading) {
        return (
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                {[1, 2, 3, 4, 5, 6, 7, 8].map(i => (
                    <div key={i} className="h-40 bg-gray-100 rounded-xl animate-pulse" />
                ))}
            </div>
        );
    }

    const earnedBadges = badges.filter(b => b.earned);
    const unearnedBadges = badges.filter(b => !b.earned);

    return (
        <div className="space-y-8">
            {/* Earned Badges */}
            {earnedBadges.length > 0 && (
                <div>
                    <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
                        <Award className="w-5 h-5 text-yellow-500" />
                        {t('earned_badges')} ({earnedBadges.length})
                    </h3>
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                        {earnedBadges.map(({ badge }) => (
                            <motion.div
                                key={badge.id}
                                initial={{ scale: 0.9, opacity: 0 }}
                                animate={{ scale: 1, opacity: 1 }}
                                className={`relative p-6 rounded-xl bg-linear-to-br ${getTierColor(badge.tier)} text-white shadow-lg border-2`}
                            >
                                <div className="mb-3 flex justify-center p-3 bg-white/20 rounded-full w-fit mx-auto backdrop-blur-sm">
                                    {getBadgeIcon(badge.icon)}
                                </div>
                                <h4 className="font-bold text-sm mb-1 text-center">{badge.name}</h4>
                                <p className="text-xs opacity-90 text-center">{badge.description}</p>
                                <div className="absolute top-2 right-2">
                                    <Award className="w-4 h-4" />
                                </div>
                            </motion.div>
                        ))}
                    </div>
                </div>
            )}

            {/* Unearned Badges */}
            {unearnedBadges.length > 0 && (
                <div>
                    <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
                        <Lock className="w-5 h-5 text-gray-400" />
                        {t('locked_badges')} ({unearnedBadges.length})
                    </h3>
                    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                        {unearnedBadges.map(({ badge, progress, total }) => (
                            <div
                                key={badge.id}
                                className="relative p-6 rounded-xl bg-gray-50 border-2 border-dashed border-gray-300 text-gray-500 hover:bg-gray-100 transition-colors"
                            >
                                <div className="mb-3 flex justify-center p-3 bg-gray-200 rounded-full w-fit mx-auto grayscale opacity-50">
                                    {getBadgeIcon(badge.icon)}
                                </div>
                                <h4 className="font-bold text-sm mb-1 text-center">{badge.name}</h4>
                                <p className="text-xs opacity-75 mb-2 text-center">{badge.description}</p>

                                {/* Progress bar */}
                                {progress !== undefined && total !== undefined && total > 0 && (
                                    <div className="mt-3">
                                        <div className="flex justify-between text-xs mb-1">
                                            <span>{progress}/{total}</span>
                                            <span>{Math.round((progress / total) * 100)}%</span>
                                        </div>
                                        <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
                                            <div
                                                className="h-full bg-blue-500 transition-all duration-300"
                                                style={{ width: `${Math.min((progress / total) * 100, 100)}%` }}
                                            />
                                        </div>
                                    </div>
                                )}

                                <div className="absolute top-2 right-2">
                                    <Lock className="w-4 h-4 opacity-40" />
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
}
