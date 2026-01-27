'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import { ClipboardCheck, X, Clock } from 'lucide-react';

interface ReassessmentPromptProps {
    locale: string;
}

export function ReassessmentPrompt({ locale }: ReassessmentPromptProps) {
    const [isOpen, setIsOpen] = useState(false);
    const [isDismissed, setIsDismissed] = useState(false);
    const router = useRouter();

    useEffect(() => {
        const checkReassessment = async () => {
            // Check if already dismissed in this session
            const dismissed = sessionStorage.getItem('reassessment-dismissed');
            if (dismissed) {
                setIsDismissed(true);
                return;
            }

            const supabase = createClient();

            const { data: { user } } = await supabase.auth.getUser();
            if (!user) return;

            const { data: profile } = await supabase
                .from('profiles')
                .select('next_assessment_due_at, last_assessment_prompt_at, role')
                .eq('id', user.id)
                .single();

            // Admins don't get prompts
            if (profile?.role === 'admin') return;

            // Check if re-assessment is due
            if (profile?.next_assessment_due_at) {
                const dueDate = new Date(profile.next_assessment_due_at);
                const now = new Date();

                if (dueDate <= now) {
                    setIsOpen(true);
                }
            }
        };

        checkReassessment();
    }, []);

    const handleTakeAssessment = () => {
        router.push(`/${locale}/assessment`);
        setIsOpen(false);
    };

    const handleRemindLater = async () => {
        const supabase = createClient();
        const { data: { user } } = await supabase.auth.getUser();

        if (user) {
            // Postpone by 1 week
            const oneWeekFromNow = new Date();
            oneWeekFromNow.setDate(oneWeekFromNow.getDate() + 7);

            await supabase
                .from('profiles')
                .update({
                    next_assessment_due_at: oneWeekFromNow.toISOString(),
                    last_assessment_prompt_at: new Date().toISOString()
                })
                .eq('id', user.id);
        }

        sessionStorage.setItem('reassessment-dismissed', 'true');
        setIsDismissed(true);
        setIsOpen(false);
    };

    if (!isOpen || isDismissed) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
            <div className="relative max-w-md w-full bg-background border-2 border-border rounded-none p-6 shadow-lg">
                {/* Close button */}
                <button
                    onClick={handleRemindLater}
                    className="absolute top-4 right-4 text-muted-foreground hover:text-foreground"
                >
                    <X className="w-5 h-5" />
                </button>

                {/* Icon */}
                <div className="flex justify-center mb-4">
                    <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center">
                        <ClipboardCheck className="w-8 h-8 text-primary" />
                    </div>
                </div>

                {/* Content */}
                <h2 className="text-xl font-bold text-center mb-2">
                    Tid for ny vurdering!
                </h2>
                <p className="text-center text-muted-foreground mb-6">
                    Det er 3 måneder siden sist du tok vurderingen.
                    Ta en ny for å se din progresjon og få oppdaterte anbefalinger.
                </p>

                {/* Buttons */}
                <div className="flex flex-col gap-3">
                    <button
                        onClick={handleTakeAssessment}
                        className="w-full py-3 px-4 bg-primary text-primary-foreground font-medium border-2 border-primary hover:bg-primary/90 transition-colors flex items-center justify-center gap-2"
                    >
                        <ClipboardCheck className="w-5 h-5" />
                        Ta ny vurdering
                    </button>
                    <button
                        onClick={handleRemindLater}
                        className="w-full py-3 px-4 bg-background text-foreground font-medium border-2 border-border hover:border-primary transition-colors flex items-center justify-center gap-2"
                    >
                        <Clock className="w-5 h-5" />
                        Påminn meg senere
                    </button>
                </div>
            </div>
        </div>
    );
}
