'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { TrendingUp, TrendingDown, Minus, History, ChevronDown, ChevronUp } from 'lucide-react';

interface AssessmentResult {
    dimension_id: string;
    dimension_name: string;
    normalized_score: number;
}

interface AssessmentSession {
    id: string;
    completed_at: string;
    results: AssessmentResult[];
}

interface Props {
    currentSessionId: string;
    userId: string;
    assessmentTypeId: string;
}

export function AssessmentHistory({ currentSessionId, userId, assessmentTypeId }: Props) {
    const [sessions, setSessions] = useState<AssessmentSession[]>([]);
    const [isExpanded, setIsExpanded] = useState(false);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        const fetchHistory = async () => {
            const supabase = createClient();

            // Get all completed sessions for this user and assessment type
            const { data: sessionData } = await supabase
                .from('assessment_sessions')
                .select(`
                    id,
                    completed_at,
                    assessment_results (
                        dimension_id,
                        normalized_score,
                        dimension:assessment_dimensions(name_no)
                    )
                `)
                .eq('user_id', userId)
                .eq('assessment_type_id', assessmentTypeId)
                .eq('status', 'completed')
                .order('completed_at', { ascending: false });

            if (sessionData) {
                const formattedSessions = sessionData.map(session => ({
                    id: session.id,
                    completed_at: session.completed_at,
                    results: session.assessment_results?.map((r: any) => ({
                        dimension_id: r.dimension_id,
                        dimension_name: r.dimension?.name_no || 'Ukjent',
                        normalized_score: r.normalized_score
                    })) || []
                }));
                setSessions(formattedSessions);
            }
            setIsLoading(false);
        };

        fetchHistory();
    }, [userId, assessmentTypeId]);

    if (isLoading || sessions.length <= 1) return null;

    const currentSession = sessions.find(s => s.id === currentSessionId);
    const previousSession = sessions.find(s => s.id !== currentSessionId);

    if (!currentSession || !previousSession) return null;

    // Calculate comparison for each dimension
    const comparisons = currentSession.results.map(current => {
        const previous = previousSession.results.find(
            p => p.dimension_id === current.dimension_id
        );
        const change = previous
            ? current.normalized_score - previous.normalized_score
            : 0;

        return {
            dimension_name: current.dimension_name,
            current_score: current.normalized_score,
            previous_score: previous?.normalized_score || 0,
            change
        };
    });

    return (
        <div className="mt-8 p-4 border-2 border-border bg-card rounded-none">
            <button
                onClick={() => setIsExpanded(!isExpanded)}
                className="w-full flex items-center justify-between text-left"
            >
                <div className="flex items-center gap-2">
                    <History className="w-5 h-5 text-primary" />
                    <span className="font-medium">
                        Sammenligning med forrige vurdering
                    </span>
                    <span className="text-sm text-muted-foreground">
                        ({new Date(previousSession.completed_at).toLocaleDateString('no-NO')})
                    </span>
                </div>
                {isExpanded ? (
                    <ChevronUp className="w-5 h-5 text-muted-foreground" />
                ) : (
                    <ChevronDown className="w-5 h-5 text-muted-foreground" />
                )}
            </button>

            {isExpanded && (
                <div className="mt-4 space-y-3">
                    {comparisons.map((comp, index) => (
                        <div key={index} className="flex items-center justify-between py-2 border-b border-border last:border-0">
                            <span className="text-sm">{comp.dimension_name}</span>
                            <div className="flex items-center gap-3">
                                <span className="text-sm text-muted-foreground">
                                    {Math.round(comp.previous_score)}%
                                </span>
                                <span className="text-muted-foreground">→</span>
                                <span className="text-sm font-medium">
                                    {Math.round(comp.current_score)}%
                                </span>
                                <ChangeIndicator change={comp.change} />
                            </div>
                        </div>
                    ))}

                    {/* Overall trend */}
                    <div className="pt-3 border-t-2 border-border">
                        <div className="flex items-center justify-between">
                            <span className="font-medium">Generell endring</span>
                            <OverallChange comparisons={comparisons} />
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}

function ChangeIndicator({ change }: { change: number }) {
    const rounded = Math.round(change);

    if (rounded > 0) {
        return (
            <span className="flex items-center gap-1 text-green-600 dark:text-green-400 text-sm font-medium">
                <TrendingUp className="w-4 h-4" />
                +{rounded}%
            </span>
        );
    }

    if (rounded < 0) {
        return (
            <span className="flex items-center gap-1 text-red-600 dark:text-red-400 text-sm font-medium">
                <TrendingDown className="w-4 h-4" />
                {rounded}%
            </span>
        );
    }

    return (
        <span className="flex items-center gap-1 text-muted-foreground text-sm">
            <Minus className="w-4 h-4" />
            0%
        </span>
    );
}

function OverallChange({ comparisons }: { comparisons: Array<{ change: number }> }) {
    const totalChange = comparisons.reduce((sum, c) => sum + c.change, 0);
    const avgChange = totalChange / comparisons.length;
    const rounded = Math.round(avgChange);

    if (rounded > 0) {
        return (
            <span className="flex items-center gap-2 px-3 py-1 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 rounded-full text-sm font-medium">
                <TrendingUp className="w-4 h-4" />
                +{rounded}% fremgang
            </span>
        );
    }

    if (rounded < 0) {
        return (
            <span className="flex items-center gap-2 px-3 py-1 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-full text-sm font-medium">
                <TrendingDown className="w-4 h-4" />
                {rounded}% tilbakegang
            </span>
        );
    }

    return (
        <span className="flex items-center gap-2 px-3 py-1 bg-muted text-muted-foreground rounded-full text-sm font-medium">
            <Minus className="w-4 h-4" />
            Ingen endring
        </span>
    );
}
