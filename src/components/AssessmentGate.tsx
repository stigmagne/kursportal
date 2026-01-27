'use client';

import { useEffect, useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import { ClipboardCheck, Loader2 } from 'lucide-react';

interface AssessmentGateProps {
    children: React.ReactNode;
    locale: string;
}

// Pages that should be accessible without completing assessment
const EXEMPT_PATHS = [
    '/login',
    '/auth',
    '/assessment',
    '/api',
    '/admin',
];

export function AssessmentGate({ children, locale }: AssessmentGateProps) {
    const [isLoading, setIsLoading] = useState(true);
    const [hasCompletedAssessment, setHasCompletedAssessment] = useState(true);
    const router = useRouter();
    const pathname = usePathname();

    useEffect(() => {
        const checkAssessment = async () => {
            const supabase = createClient();

            // Get current user
            const { data: { user } } = await supabase.auth.getUser();

            if (!user) {
                setIsLoading(false);
                return; // Not logged in, let normal auth handle it
            }

            // Check if current path is exempt
            const isExempt = EXEMPT_PATHS.some(path =>
                pathname.includes(path)
            );

            if (isExempt) {
                setIsLoading(false);
                return;
            }

            // Check if user has completed initial assessment
            const { data: profile } = await supabase
                .from('profiles')
                .select('initial_assessment_completed_at, role')
                .eq('id', user.id)
                .single();

            // Admins bypass assessment requirement
            if (profile?.role === 'admin') {
                setHasCompletedAssessment(true);
                setIsLoading(false);
                return;
            }

            if (!profile?.initial_assessment_completed_at) {
                setHasCompletedAssessment(false);
                // Redirect to assessment page
                router.push(`/${locale}/assessment`);
            } else {
                setHasCompletedAssessment(true);
            }

            setIsLoading(false);
        };

        checkAssessment();
    }, [pathname, locale, router]);

    // Show loading state
    if (isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <Loader2 className="w-8 h-8 animate-spin text-primary" />
            </div>
        );
    }

    // Show assessment required message (while redirecting)
    if (!hasCompletedAssessment) {
        return (
            <div className="min-h-screen flex items-center justify-center p-4">
                <div className="max-w-md text-center">
                    <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 text-primary mb-4">
                        <ClipboardCheck className="w-8 h-8" />
                    </div>
                    <h1 className="text-2xl font-bold mb-2">Vurdering påkrevd</h1>
                    <p className="text-muted-foreground mb-4">
                        For å gi deg personlig tilpassede kursanbefalinger,
                        må du først fullføre en kort vurdering.
                    </p>
                    <p className="text-sm text-muted-foreground">
                        Omdirigerer...
                    </p>
                </div>
            </div>
        );
    }

    return <>{children}</>;
}
