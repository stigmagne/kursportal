'use client';

import { useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { useRouter } from 'next/navigation';
import { Loader2 } from 'lucide-react';
import { useTranslations } from 'next-intl';

interface EnrollButtonProps {
    courseId: string;
    courseName: string;
    isEnrolled: boolean;
    onEnroll?: () => void;
}

export default function EnrollButton({ courseId, courseName, isEnrolled, onEnroll }: EnrollButtonProps) {
    const t = useTranslations('EnrollButton');
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const router = useRouter();
    const supabase = createClient();

    const handleEnroll = async () => {
        setIsLoading(true);
        setError(null);

        try {
            // Get current user
            const { data: { user } } = await supabase.auth.getUser();

            if (!user) {
                console.log('No user found, redirecting to login');
                router.push('/login');
                return;
            }

            console.log('Enrolling user:', user.id, 'in course:', courseId);

            // Create enrollment record in user_progress
            const { error: enrollError } = await supabase
                .from('user_progress')
                .insert({
                    user_id: user.id,
                    course_id: courseId
                });

            if (enrollError) {
                // Check if already enrolled (conflict)
                if (enrollError.code === '23505') {
                    console.log('Already enrolled, redirecting to learn page');
                    router.push(`/courses/${courseId}/learn`);
                    return;
                }
                throw enrollError;
            }

            console.log('Enrollment successful!');

            // Call optional callback
            if (onEnroll) {
                onEnroll();
            }

            // Redirect to learning interface
            router.push(`/courses/${courseId}/learn`);
        } catch (error: any) {
            console.error('Enrollment error:', error);
            setError(error.message || t('error'));
        } finally {
            setIsLoading(false);
        }
    };

    const handleContinue = () => {
        router.push(`/courses/${courseId}/learn`);
    };

    if (isEnrolled) {
        return (
            <button
                onClick={handleContinue}
                className="px-6 py-3 bg-primary text-primary-foreground rounded-lg font-medium hover:bg-primary/90 transition-colors"
            >
                {t('continue')}
            </button>
        );
    }

    return (
        <div>
            <button
                onClick={handleEnroll}
                disabled={isLoading}
                className="px-6 py-3 bg-primary text-primary-foreground rounded-lg font-medium hover:bg-primary/90 disabled:opacity-50 transition-colors flex items-center gap-2"
            >
                {isLoading ? (
                    <>
                        <Loader2 className="w-5 h-5 animate-spin" />
                        {t('enrolling')}
                    </>
                ) : (
                    t('enroll')
                )}
            </button>
            {error && (
                <p className="text-red-600 text-sm mt-2">{error}</p>
            )}
        </div>
    );
}
