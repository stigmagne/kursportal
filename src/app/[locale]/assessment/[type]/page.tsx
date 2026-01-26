import { createClient } from '@/utils/supabase/server';
import { redirect } from '@/i18n/routing';
import { notFound } from 'next/navigation';
import AssessmentFlow from '@/components/assessment/AssessmentFlow';

interface Props {
    params: { locale: string; type: string };
}

export default async function AssessmentTypePage({ params }: Props) {
    const { locale, type } = await params;
    const supabase = await createClient();

    // Check authentication
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return redirect({ href: '/login', locale });
    }

    // Get assessment type
    const { data: assessmentType } = await supabase
        .from('assessment_types')
        .select('*')
        .eq('slug', type)
        .single();

    if (!assessmentType) {
        return notFound();
    }

    // Get all questions for this assessment type
    const { data: dimensions } = await supabase
        .from('assessment_dimensions')
        .select('id')
        .eq('assessment_type_id', assessmentType.id);

    const dimensionIds = dimensions?.map(d => d.id) || [];

    const { data: questions } = await supabase
        .from('assessment_questions')
        .select('*')
        .in('dimension_id', dimensionIds)
        .order('dimension_id')
        .order('order_index');

    if (!questions || questions.length === 0) {
        return (
            <div className="min-h-screen flex items-center justify-center">
                <p className="text-muted-foreground">Ingen spørsmål funnet for denne vurderingen.</p>
            </div>
        );
    }

    // Shuffle questions for variety but keep them grouped by dimension
    // For now, just use the natural order

    // Create or get existing session
    let session;

    // Check for existing in-progress session
    const { data: existingSession } = await supabase
        .from('assessment_sessions')
        .select('id')
        .eq('user_id', user.id)
        .eq('assessment_type_id', assessmentType.id)
        .eq('status', 'in_progress')
        .single();

    if (existingSession) {
        session = existingSession;
    } else {
        // Create new session
        const { data: newSession, error } = await supabase
            .from('assessment_sessions')
            .insert({
                user_id: user.id,
                assessment_type_id: assessmentType.id,
                status: 'in_progress'
            })
            .select()
            .single();

        if (error || !newSession) {
            console.error('Error creating session:', error);
            return (
                <div className="min-h-screen flex items-center justify-center">
                    <p className="text-red-500">Kunne ikke starte vurdering. Prøv igjen.</p>
                </div>
            );
        }
        session = newSession;
    }

    return (
        <AssessmentFlow
            assessmentType={assessmentType}
            questions={questions}
            sessionId={session.id}
        />
    );
}
