'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronLeft, ChevronRight, Loader2 } from 'lucide-react';
import { useTranslations } from 'next-intl';

interface Question {
    id: string;
    statement_no: string;
    dimension_id: string;
    order_index: number;
}

interface AssessmentFlowProps {
    assessmentType: {
        id: string;
        slug: string;
        title_no: string;
    };
    questions: Question[];
    sessionId: string;
}

export default function AssessmentFlow({ assessmentType, questions, sessionId }: AssessmentFlowProps) {
    const t = useTranslations('Assessment');
    const router = useRouter();
    const supabase = createClient();

    const [currentIndex, setCurrentIndex] = useState(0);
    const [responses, setResponses] = useState<Record<string, number>>({});
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [direction, setDirection] = useState(0);

    const currentQuestion = questions[currentIndex];
    const progress = ((currentIndex + 1) / questions.length) * 100;
    const isLastQuestion = currentIndex === questions.length - 1;

    const scaleLabels = [
        { value: 1, label: 'Helt uenig', emoji: '😔' },
        { value: 2, label: 'Uenig', emoji: '🙁' },
        { value: 3, label: 'Litt uenig', emoji: '😕' },
        { value: 4, label: 'Nøytral', emoji: '😐' },
        { value: 5, label: 'Litt enig', emoji: '🙂' },
        { value: 6, label: 'Enig', emoji: '😊' },
        { value: 7, label: 'Helt enig', emoji: '😄' },
    ];

    const handleResponse = async (score: number) => {
        // Save response
        setResponses(prev => ({ ...prev, [currentQuestion.id]: score }));

        // Save to database
        await supabase.from('assessment_responses').upsert({
            session_id: sessionId,
            question_id: currentQuestion.id,
            score
        }, { onConflict: 'session_id,question_id' });

        // Auto-advance after short delay
        setTimeout(() => {
            if (!isLastQuestion) {
                setDirection(1);
                setCurrentIndex(prev => prev + 1);
            }
        }, 300);
    };

    const handlePrevious = () => {
        if (currentIndex > 0) {
            setDirection(-1);
            setCurrentIndex(prev => prev - 1);
        }
    };

    const handleSubmit = async () => {
        setIsSubmitting(true);

        try {
            // Calculate results using database function
            const { error } = await supabase.rpc('calculate_assessment_results', {
                p_session_id: sessionId
            });

            if (error) throw error;

            // Navigate to results
            router.push(`/assessment/results?session=${sessionId}`);
        } catch (error) {
            console.error('Error submitting assessment:', error);
            setIsSubmitting(false);
        }
    };

    const variants = {
        enter: (direction: number) => ({
            x: direction > 0 ? 300 : -300,
            opacity: 0
        }),
        center: {
            x: 0,
            opacity: 1
        },
        exit: (direction: number) => ({
            x: direction < 0 ? 300 : -300,
            opacity: 0
        })
    };

    return (
        <div className="min-h-screen flex flex-col">
            {/* Progress Bar */}
            <div className="fixed top-0 left-0 right-0 h-1 bg-muted z-50">
                <motion.div
                    className="h-full bg-primary"
                    initial={{ width: 0 }}
                    animate={{ width: `${progress}%` }}
                    transition={{ duration: 0.3 }}
                />
            </div>

            {/* Header */}
            <div className="p-4 border-b">
                <div className="max-w-2xl mx-auto flex items-center justify-between">
                    <h1 className="font-bold">{assessmentType.title_no}</h1>
                    <span className="text-sm text-muted-foreground">
                        {currentIndex + 1} / {questions.length}
                    </span>
                </div>
            </div>

            {/* Question Area */}
            <div className="flex-1 flex items-center justify-center p-4">
                <div className="w-full max-w-2xl">
                    <AnimatePresence mode="wait" custom={direction}>
                        <motion.div
                            key={currentQuestion.id}
                            custom={direction}
                            variants={variants}
                            initial="enter"
                            animate="center"
                            exit="exit"
                            transition={{ duration: 0.3, ease: "easeInOut" }}
                            className="space-y-8"
                        >
                            {/* Question */}
                            <h2 className="text-2xl md:text-3xl font-medium text-center leading-relaxed">
                                {currentQuestion.statement_no}
                            </h2>

                            {/* Likert Scale */}
                            <div className="space-y-4">
                                <div className="flex justify-between text-sm text-muted-foreground px-2">
                                    <span>Helt uenig</span>
                                    <span>Helt enig</span>
                                </div>

                                <div className="flex justify-center gap-2 md:gap-4">
                                    {scaleLabels.map(({ value, emoji }) => {
                                        const isSelected = responses[currentQuestion.id] === value;

                                        return (
                                            <button
                                                key={value}
                                                onClick={() => handleResponse(value)}
                                                className={`
                                                    w-12 h-12 md:w-14 md:h-14 rounded-none border-2 
                                                    flex items-center justify-center text-xl md:text-2xl
                                                    transition-all duration-200
                                                    ${isSelected
                                                        ? 'border-primary bg-primary text-primary-foreground scale-110 shadow-lg'
                                                        : 'border-border hover:border-primary/50 hover:scale-105'
                                                    }
                                                `}
                                            >
                                                {value}
                                            </button>
                                        );
                                    })}
                                </div>

                                {/* Emoji indicator */}
                                <div className="flex justify-center">
                                    <AnimatePresence mode="wait">
                                        {responses[currentQuestion.id] && (
                                            <motion.span
                                                key={responses[currentQuestion.id]}
                                                initial={{ scale: 0, opacity: 0 }}
                                                animate={{ scale: 1, opacity: 1 }}
                                                exit={{ scale: 0, opacity: 0 }}
                                                className="text-4xl"
                                            >
                                                {scaleLabels.find(s => s.value === responses[currentQuestion.id])?.emoji}
                                            </motion.span>
                                        )}
                                    </AnimatePresence>
                                </div>
                            </div>
                        </motion.div>
                    </AnimatePresence>
                </div>
            </div>

            {/* Navigation */}
            <div className="p-4 border-t">
                <div className="max-w-2xl mx-auto flex items-center justify-between">
                    <button
                        onClick={handlePrevious}
                        disabled={currentIndex === 0}
                        className="flex items-center gap-2 px-4 py-2 text-muted-foreground hover:text-foreground disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
                    >
                        <ChevronLeft className="w-5 h-5" />
                        {t('previous', { defaultMessage: 'Forrige' })}
                    </button>

                    {isLastQuestion && responses[currentQuestion.id] ? (
                        <button
                            onClick={handleSubmit}
                            disabled={isSubmitting}
                            className="flex items-center gap-2 px-6 py-3 bg-primary text-primary-foreground font-medium rounded-none border-2 border-primary hover:bg-primary/90 disabled:opacity-50 transition-colors"
                        >
                            {isSubmitting ? (
                                <>
                                    <Loader2 className="w-5 h-5 animate-spin" />
                                    {t('calculating', { defaultMessage: 'Beregner...' })}
                                </>
                            ) : (
                                <>
                                    {t('see_results', { defaultMessage: 'Se resultater' })}
                                    <ChevronRight className="w-5 h-5" />
                                </>
                            )}
                        </button>
                    ) : (
                        <button
                            onClick={() => {
                                if (responses[currentQuestion.id]) {
                                    setDirection(1);
                                    setCurrentIndex(prev => prev + 1);
                                }
                            }}
                            disabled={!responses[currentQuestion.id]}
                            className="flex items-center gap-2 px-4 py-2 text-muted-foreground hover:text-foreground disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
                        >
                            {t('next', { defaultMessage: 'Neste' })}
                            <ChevronRight className="w-5 h-5" />
                        </button>
                    )}
                </div>
            </div>
        </div>
    );
}
