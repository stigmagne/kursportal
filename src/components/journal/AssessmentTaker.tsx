'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { deriveKey, encryptJournalEntry } from '@/utils/crypto';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Textarea } from '@/components/ui/textarea';
import { Loader2, CheckCircle, Lock } from 'lucide-react';
import { useTranslations } from 'next-intl';

interface Question {
    id: string;
    type: 'scale' | 'text' | 'choice';
    text: string;
    min?: number;
    max?: number;
    labels?: Record<string, string>;
    options?: string[];
}

interface AssessmentTemplate {
    id: string;
    title: string;
    description: string;
    questions: Question[];
}

interface AssessmentTakerProps {
    template: AssessmentTemplate;
    cryptoKey: CryptoKey | null;
    passphrase: string;
    onComplete: () => void;
    onNeedUnlock: () => void;
}

export default function AssessmentTaker({
    template,
    cryptoKey,
    passphrase,
    onComplete,
    onNeedUnlock
}: AssessmentTakerProps) {
    const t = useTranslations('Journal');
    const [responses, setResponses] = useState<Record<string, any>>({});
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [isComplete, setIsComplete] = useState(false);
    const supabase = createClient();

    const handleScaleChange = (questionId: string, value: number) => {
        setResponses(prev => ({ ...prev, [questionId]: value }));
    };

    const handleTextChange = (questionId: string, value: string) => {
        setResponses(prev => ({ ...prev, [questionId]: value }));
    };

    const handleChoiceChange = (questionId: string, value: string) => {
        setResponses(prev => ({ ...prev, [questionId]: value }));
    };

    const handleSubmit = async () => {
        if (!cryptoKey && !passphrase) {
            onNeedUnlock();
            return;
        }

        setIsSubmitting(true);

        try {
            const key = cryptoKey || await deriveKey(passphrase);

            // Encrypt all responses
            const responsesJson = JSON.stringify(responses);
            const { ciphertext, iv } = await encryptJournalEntry(responsesJson, key);

            // Extract numeric values for optional aggregation
            const numericSummary: Record<string, any> = {};
            template.questions.forEach(q => {
                if (q.type === 'scale' && responses[q.id] !== undefined) {
                    numericSummary[q.id] = responses[q.id];
                }
                if (q.type === 'choice' && responses[q.id] !== undefined) {
                    numericSummary[q.id] = responses[q.id];
                }
            });

            // Save to database
            const { error } = await supabase
                .from('journal_assessments')
                .insert({
                    template_id: template.id,
                    responses_encrypted: ciphertext,
                    iv: iv,
                    numeric_summary: Object.keys(numericSummary).length > 0 ? numericSummary : null
                });

            if (error) throw error;

            setIsComplete(true);
            setTimeout(() => {
                onComplete();
            }, 1500);

        } catch (err) {
            console.error('Failed to save assessment:', err);
            alert(t('alerts.save_failed') || 'Failed to save assessment');
        } finally {
            setIsSubmitting(false);
        }
    };

    if (isComplete) {
        return (
            <Card className="border-green-500/50 bg-green-500/5">
                <CardContent className="flex flex-col items-center justify-center py-12">
                    <CheckCircle className="w-16 h-16 text-green-500 mb-4" />
                    <h3 className="text-xl font-bold">{t('assessment_complete') || 'Vurdering fullført!'}</h3>
                    <p className="text-muted-foreground">{t('assessment_saved') || 'Svarene dine er trygt lagret.'}</p>
                </CardContent>
            </Card>
        );
    }

    return (
        <Card>
            <CardHeader>
                <CardTitle>{template.title}</CardTitle>
                <CardDescription>{template.description}</CardDescription>
            </CardHeader>
            <CardContent className="space-y-8">
                {template.questions.map((question, index) => (
                    <div key={question.id} className="space-y-3">
                        <label className="text-sm font-medium">
                            {index + 1}. {question.text}
                        </label>

                        {question.type === 'scale' && (
                            <div className="space-y-2">
                                <div className="flex justify-between text-xs text-muted-foreground">
                                    <span>{question.labels?.[String(question.min || 1)] || question.min || 1}</span>
                                    <span>{question.labels?.[String(question.max || 10)] || question.max || 10}</span>
                                </div>
                                <div className="flex gap-1">
                                    {Array.from({ length: (question.max || 10) - (question.min || 1) + 1 }, (_, i) => {
                                        const value = (question.min || 1) + i;
                                        const isSelected = responses[question.id] === value;
                                        return (
                                            <button
                                                key={value}
                                                type="button"
                                                onClick={() => handleScaleChange(question.id, value)}
                                                className={`flex-1 py-3 text-sm font-bold border-2 transition-all ${isSelected
                                                        ? 'bg-primary text-primary-foreground border-primary'
                                                        : 'bg-background border-black dark:border-white hover:bg-muted'
                                                    }`}
                                            >
                                                {value}
                                            </button>
                                        );
                                    })}
                                </div>
                            </div>
                        )}

                        {question.type === 'choice' && (
                            <div className="flex flex-wrap gap-2">
                                {question.options?.map(option => {
                                    const isSelected = responses[question.id] === option;
                                    return (
                                        <button
                                            key={option}
                                            type="button"
                                            onClick={() => handleChoiceChange(question.id, option)}
                                            className={`px-4 py-2 text-sm font-medium border-2 transition-all ${isSelected
                                                    ? 'bg-primary text-primary-foreground border-primary'
                                                    : 'bg-background border-black dark:border-white hover:bg-muted'
                                                }`}
                                        >
                                            {option}
                                        </button>
                                    );
                                })}
                            </div>
                        )}

                        {question.type === 'text' && (
                            <Textarea
                                placeholder={t('write_here') || 'Skriv her...'}
                                value={responses[question.id] || ''}
                                onChange={(e) => handleTextChange(question.id, e.target.value)}
                                className="min-h-[100px]"
                            />
                        )}
                    </div>
                ))}

                <div className="flex justify-end gap-3 pt-4 border-t">
                    {!cryptoKey && (
                        <p className="flex items-center gap-2 text-sm text-muted-foreground mr-auto">
                            <Lock className="w-4 h-4" />
                            {t('will_encrypt') || 'Svarene krypteres ved lagring'}
                        </p>
                    )}
                    <Button
                        onClick={handleSubmit}
                        disabled={isSubmitting || Object.keys(responses).length === 0}
                    >
                        {isSubmitting ? (
                            <>
                                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                                {t('saving') || 'Lagrer...'}
                            </>
                        ) : (
                            t('save_assessment') || 'Lagre vurdering'
                        )}
                    </Button>
                </div>
            </CardContent>
        </Card>
    );
}
