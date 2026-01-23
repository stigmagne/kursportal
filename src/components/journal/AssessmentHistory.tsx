'use client';

import { useState, useEffect, useMemo } from 'react';
import { createClient } from '@/utils/supabase/client';
import { deriveKey, decryptJournalEntry } from '@/utils/crypto';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Calendar, TrendingUp, Eye, EyeOff, Lock } from 'lucide-react';
import { useTranslations } from 'next-intl';

interface AssessmentRecord {
    id: string;
    template_id: string;
    responses_encrypted: string;
    iv: string;
    numeric_summary: Record<string, any> | null;
    created_at: string;
}

interface AssessmentHistoryProps {
    cryptoKey: CryptoKey | null;
}

export default function AssessmentHistory({ cryptoKey }: AssessmentHistoryProps) {
    const t = useTranslations('Journal');
    const [assessments, setAssessments] = useState<AssessmentRecord[]>([]);
    const [templates, setTemplates] = useState<Record<string, any>>({});
    const [isLoading, setIsLoading] = useState(true);
    const [expandedId, setExpandedId] = useState<string | null>(null);
    const [decryptedResponses, setDecryptedResponses] = useState<Record<string, any>>({});
    const supabase = createClient();

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        // Fetch assessments
        const { data: assessmentData } = await supabase
            .from('journal_assessments')
            .select('*')
            .order('created_at', { ascending: false });

        // Fetch templates
        const { data: templateData } = await supabase
            .from('assessment_templates')
            .select('*');

        if (assessmentData) setAssessments(assessmentData);
        if (templateData) {
            const templateMap: Record<string, any> = {};
            templateData.forEach(t => { templateMap[t.id] = t; });
            setTemplates(templateMap);
        }
        setIsLoading(false);
    };

    const handleExpand = async (assessment: AssessmentRecord) => {
        if (expandedId === assessment.id) {
            setExpandedId(null);
            return;
        }

        setExpandedId(assessment.id);

        if (cryptoKey && !decryptedResponses[assessment.id]) {
            try {
                const decrypted = await decryptJournalEntry(
                    assessment.responses_encrypted,
                    assessment.iv,
                    cryptoKey
                );
                setDecryptedResponses(prev => ({
                    ...prev,
                    [assessment.id]: JSON.parse(decrypted)
                }));
            } catch (err) {
                console.error('Decryption failed:', err);
            }
        }
    };

    // Calculate trend data from numeric summaries
    const trendData = useMemo(() => {
        const trends: Record<string, { dates: string[], values: number[] }> = {};

        // Sort by date ascending for trend calculation
        const sortedAssessments = [...assessments].reverse();

        sortedAssessments.forEach(a => {
            if (a.numeric_summary) {
                Object.entries(a.numeric_summary).forEach(([key, value]) => {
                    if (typeof value === 'number') {
                        if (!trends[key]) {
                            trends[key] = { dates: [], values: [] };
                        }
                        trends[key].dates.push(new Date(a.created_at).toLocaleDateString());
                        trends[key].values.push(value);
                    }
                });
            }
        });

        return trends;
    }, [assessments]);

    if (isLoading) {
        return (
            <Card>
                <CardContent className="py-8 text-center text-muted-foreground">
                    {t('loading') || 'Laster...'}
                </CardContent>
            </Card>
        );
    }

    if (assessments.length === 0) {
        return (
            <Card>
                <CardContent className="py-8 text-center text-muted-foreground">
                    <TrendingUp className="w-12 h-12 mx-auto mb-4 opacity-50" />
                    <p>{t('no_assessments') || 'Ingen vurderinger enda. Ta din første test!'}</p>
                </CardContent>
            </Card>
        );
    }

    return (
        <div className="space-y-6">
            {/* Trend Overview */}
            {Object.keys(trendData).length > 0 && (
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <TrendingUp className="w-5 h-5" />
                            {t('trend_overview') || 'Trendoversikt'}
                        </CardTitle>
                        <CardDescription>
                            {t('trend_description') || 'Siste verdier fra dine vurderinger'}
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                            {Object.entries(trendData).map(([key, data]) => {
                                const lastValue = data.values[data.values.length - 1];
                                const prevValue = data.values.length > 1 ? data.values[data.values.length - 2] : null;
                                const trend = prevValue ? lastValue - prevValue : 0;

                                // Get question label from template
                                const questionLabel = Object.values(templates).reduce((label, tmpl) => {
                                    const q = tmpl.questions?.find((q: any) => q.id === key);
                                    return q ? q.text : label;
                                }, key);

                                return (
                                    <div key={key} className="p-4 border-2 border-black dark:border-white">
                                        <div className="text-2xl font-bold">{lastValue}</div>
                                        <div className="text-xs text-muted-foreground truncate" title={questionLabel}>
                                            {questionLabel}
                                        </div>
                                        {trend !== 0 && (
                                            <div className={`text-xs mt-1 ${trend > 0 ? 'text-green-500' : 'text-red-500'}`}>
                                                {trend > 0 ? '↑' : '↓'} {Math.abs(trend)} siden sist
                                            </div>
                                        )}
                                    </div>
                                );
                            })}
                        </div>
                    </CardContent>
                </Card>
            )}

            {/* Assessment History List */}
            <Card>
                <CardHeader>
                    <CardTitle>{t('assessment_history') || 'Vurderingshistorikk'}</CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                    {assessments.map(assessment => {
                        const template = templates[assessment.template_id];
                        const isExpanded = expandedId === assessment.id;
                        const responses = decryptedResponses[assessment.id];

                        return (
                            <div
                                key={assessment.id}
                                className="border-2 border-black dark:border-white p-4 transition-all"
                            >
                                <button
                                    onClick={() => handleExpand(assessment)}
                                    className="w-full flex items-center justify-between text-left"
                                >
                                    <div className="flex items-center gap-3">
                                        <Calendar className="w-4 h-4 text-muted-foreground" />
                                        <div>
                                            <div className="font-medium">
                                                {template?.title || 'Vurdering'}
                                            </div>
                                            <div className="text-sm text-muted-foreground">
                                                {new Date(assessment.created_at).toLocaleDateString()} kl. {new Date(assessment.created_at).toLocaleTimeString()}
                                            </div>
                                        </div>
                                    </div>
                                    {isExpanded ? (
                                        <EyeOff className="w-4 h-4" />
                                    ) : cryptoKey ? (
                                        <Eye className="w-4 h-4" />
                                    ) : (
                                        <Lock className="w-4 h-4 text-muted-foreground" />
                                    )}
                                </button>

                                {isExpanded && (
                                    <div className="mt-4 pt-4 border-t space-y-3">
                                        {cryptoKey ? (
                                            responses ? (
                                                template?.questions?.map((q: any) => (
                                                    <div key={q.id} className="text-sm">
                                                        <div className="font-medium">{q.text}</div>
                                                        <div className="text-muted-foreground mt-1">
                                                            {responses[q.id] !== undefined ? (
                                                                q.type === 'scale' ? (
                                                                    <span className="font-bold text-primary">{responses[q.id]}/10</span>
                                                                ) : (
                                                                    responses[q.id]
                                                                )
                                                            ) : (
                                                                <span className="italic">Ikke besvart</span>
                                                            )}
                                                        </div>
                                                    </div>
                                                ))
                                            ) : (
                                                <div className="text-sm text-muted-foreground">
                                                    {t('decrypting') || 'Dekrypterer...'}
                                                </div>
                                            )
                                        ) : (
                                            <div className="flex items-center gap-2 text-sm text-muted-foreground">
                                                <Lock className="w-4 h-4" />
                                                {t('unlock_to_view') || 'Lås opp journalen for å se detaljer'}
                                            </div>
                                        )}
                                    </div>
                                )}
                            </div>
                        );
                    })}
                </CardContent>
            </Card>
        </div>
    );
}
