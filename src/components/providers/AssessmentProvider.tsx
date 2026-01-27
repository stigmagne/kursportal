'use client';

import { AssessmentGate } from '@/components/AssessmentGate';
import { ReassessmentPrompt } from '@/components/ReassessmentPrompt';

interface AssessmentProviderProps {
    children: React.ReactNode;
    locale: string;
}

export function AssessmentProvider({ children, locale }: AssessmentProviderProps) {
    return (
        <AssessmentGate locale={locale}>
            {children}
            <ReassessmentPrompt locale={locale} />
        </AssessmentGate>
    );
}
