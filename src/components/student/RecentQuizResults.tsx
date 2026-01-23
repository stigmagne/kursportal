'use client';

import { Card } from '@/components/ui/card';
import { useTranslations } from 'next-intl';
import { CheckCircle2, XCircle, BrainCircuit } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { useLocale } from 'next-intl';
import { format } from 'date-fns';
import { nb, enUS } from 'date-fns/locale';

interface QuizResult {
    id: string;
    quiz_id: string;
    score: number;
    passed: boolean;
    created_at: string;
    quiz: {
        title: string;
        course: {
            title: string;
        }
    };
}

export default function RecentQuizResults({ results }: { results: QuizResult[] }) {
    const t = useTranslations('Dashboard');
    const locale = useLocale();
    const dateLocale = locale === 'no' ? nb : enUS;

    return (
        <Card className="p-6">
            <h3 className="font-semibold text-lg mb-4 flex items-center gap-2">
                <BrainCircuit className="w-5 h-5 text-primary" />
                {t('quiz_results_title', { defaultMessage: 'Siste quiz-resultater' })}
            </h3>

            <div className="space-y-3">
                {results.length === 0 ? (
                    <p className="text-sm text-muted-foreground text-center py-4">
                        {t('no_quiz_results', { defaultMessage: 'Ingen quizer tatt enda' })}
                    </p>
                ) : (
                    results.map((result) => (
                        <div key={result.id} className="flex items-center justify-between p-3 rounded-lg bg-muted/50 hover:bg-muted transition-colors">
                            <div className="flex items-start gap-3">
                                <div className="mt-1">
                                    {result.passed ? (
                                        <CheckCircle2 className="w-5 h-5 text-emerald-500" />
                                    ) : (
                                        <XCircle className="w-5 h-5 text-red-500" />
                                    )}
                                </div>
                                <div>
                                    <p className="font-medium text-sm">{result.quiz.title}</p>
                                    <p className="text-xs text-muted-foreground">{result.quiz.course?.title}</p>
                                </div>
                            </div>
                            <div className="text-right">
                                <Badge variant={result.passed ? 'default' : 'destructive'} className={result.passed ? 'bg-emerald-500 hover:bg-emerald-600' : ''}>
                                    {result.score}%
                                </Badge>
                                <p className="text-[10px] text-muted-foreground mt-1">
                                    {format(new Date(result.created_at), 'd. MMM', { locale: dateLocale })}
                                </p>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </Card>
    );
}
