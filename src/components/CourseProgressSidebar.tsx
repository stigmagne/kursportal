'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Download, Loader2, CheckCircle } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { Link } from '@/i18n/routing';

export default function CourseProgressSidebar({ courseId, initialProgress = 0 }: { courseId: string; initialProgress?: number }) {
    const t = useTranslations('CourseSidebar');
    const supabase = createClient();
    const router = useRouter();
    const [status, setStatus] = useState<'not_started' | 'in_progress' | 'completed'>('not_started');
    const [progress, setProgress] = useState(initialProgress);
    const [isLoading, setIsLoading] = useState(true);
    const [isUpdating, setIsUpdating] = useState(false);
    const [certificateId, setCertificateId] = useState<string | null>(null);

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
            // Check for certificate
            const { data: certData } = await supabase
                .from('certificates')
                .select('id')
                .eq('course_id', courseId)
                .eq('user_id', user.id)
                .maybeSingle();

            if (certData) {
                setCertificateId(certData.id);
            }

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
        <div className="bg-white p-6 rounded-xl border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] sticky top-24">
            <h3 className="font-black text-lg mb-4 uppercase tracking-wide flex items-center gap-2">
                <span className="w-2 h-2 bg-black rounded-full" />
                {t('title')}
            </h3>
            <div className="space-y-6">
                <div>
                    <div className="w-full bg-gray-100 border-2 border-black rounded-full h-4 overflow-hidden mb-2">
                        <div
                            className="h-full transition-all duration-500 bg-blue-500 border-r-2 border-black"
                            style={{ width: `${progress}%` }}
                        />
                    </div>
                    <p className="text-xs font-bold text-right uppercase tracking-wider">
                        {progress}% {t('completed')}
                    </p>
                </div>

                <button
                    onClick={handleMarkComplete}
                    disabled={isComplete || isUpdating}
                    className={`w-full py-3 rounded-lg font-black uppercase tracking-wider border-2 flex items-center justify-center gap-2 transition-all ${isComplete
                        ? 'bg-green-100 text-green-700 border-green-700 cursor-default opacity-100'
                        : 'bg-black text-white border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:translate-x-[2px] hover:translate-y-[2px] active:shadow-none active:translate-x-[4px] active:translate-y-[4px]'
                        }`}
                >
                    {isUpdating && <Loader2 className="w-4 h-4 animate-spin" />}
                    {!isUpdating && isComplete && <><CheckCircle className="w-4 h-4" /> {t('completed')}</>}
                    {!isUpdating && !isComplete && t('mark_complete')}
                </button>
            </div>

            {certificateId && (
                <div className="mt-6 pt-6 border-t-2 border-dashed border-gray-300 animate-in fade-in slide-in-from-top-4 duration-700">
                    <Link
                        href={`/certificates/${certificateId}`}
                        className="w-full py-3 rounded-lg border-2 border-black bg-yellow-400 text-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:translate-x-[2px] hover:translate-y-[2px] active:shadow-none active:translate-x-[4px] active:translate-y-[4px] transition-all flex items-center justify-center gap-2 font-black uppercase tracking-wide text-sm"
                    >
                        <Download className="w-4 h-4" />
                        {t('download_certificate') || 'Last ned kursbevis'}
                    </Link>
                </div>
            )}

        </div>
    );
}
