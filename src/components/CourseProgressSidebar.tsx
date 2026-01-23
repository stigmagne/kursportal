'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Loader2, CheckCircle } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';

export default function CourseProgressSidebar({ courseId, initialProgress = 0 }: { courseId: string; initialProgress?: number }) {
    const t = useTranslations('CourseSidebar');
    const supabase = createClient();
    const router = useRouter();
    const [status, setStatus] = useState<'not_started' | 'in_progress' | 'completed'>('not_started');
    const [progress, setProgress] = useState(initialProgress);
    const [isLoading, setIsLoading] = useState(true);
    const [isUpdating, setIsUpdating] = useState(false);

    useEffect(() => {
        const fetchProgress = async () => {
            const { data: { user } } = await supabase.auth.getUser();
            if (!user) return;

            const { data } = await supabase
                .from('user_progress')
                .select('status')
                .eq('course_id', courseId)
                .eq('user_id', user.id)
                .single();

            if (data) {
                setStatus(data.status);
            }

            // Calculate actual progress
            const { data: progressData } = await supabase
                .rpc('calculate_course_progress', {
                    p_user_id: user.id,
                    p_course_id: courseId
                });

            setProgress(progressData || 0);
            setIsLoading(false);
        };
        fetchProgress();
    }, [courseId]);

    const handleMarkComplete = async () => {
        setIsUpdating(true);
        try {
            const { data: { user } } = await supabase.auth.getUser();
            if (!user) return;

            // Upsert progress
            const { error } = await supabase
                .from('user_progress')
                .upsert({
                    course_id: courseId,
                    user_id: user.id,
                    status: 'completed',
                    completed_at: new Date().toISOString(),
                    last_accessed: new Date().toISOString()
                }, { onConflict: 'user_id, course_id' }); // Assuming composite key/constraint exists, or just rely on RLS/ID

            if (error) throw error;

            setStatus('completed');
            try {
                router.refresh(); // Refresh server stats if needed
            } catch (e) {
                // ignore
            }
        } catch (err) {
            console.error(err);
            alert(t('error'));
        } finally {
            setIsUpdating(false);
        }
    }

    if (isLoading) return <div className="animate-pulse h-20 bg-muted/50 rounded-xl" />;

    const isComplete = status === 'completed';

    return (
        <div className="glass p-6 rounded-xl border border-white/10 sticky top-24">
            <h3 className="font-semibold mb-4">{t('title')}</h3>
            <div className="space-y-4">
                <div className="w-full bg-muted rounded-full h-2 overflow-hidden">
                    <div
                        className="h-full transition-all duration-500 bg-primary"
                        style={{ width: `${progress}%` }}
                    />
                </div>
                <p className="text-sm text-muted-foreground">
                    {progress}% {t('completed')}
                </p>

                <button
                    onClick={handleMarkComplete}
                    disabled={isComplete || isUpdating}
                    className={`w-full py-2.5 rounded-lg font-medium transition-colors flex items-center justify-center gap-2 ${isComplete
                        ? 'bg-green-500/20 text-green-500 cursor-default'
                        : 'bg-primary text-primary-foreground hover:bg-primary/90 shadow-lg shadow-primary/20'
                        }`}
                >
                    {isUpdating && <Loader2 className="w-4 h-4 animate-spin" />}
                    {!isUpdating && isComplete && <><CheckCircle className="w-4 h-4" /> {t('completed')}</>}
                    {!isUpdating && !isComplete && t('mark_complete')}
                </button>
            </div>
        </div>
    );
}
