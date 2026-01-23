'use client';

import { useState, useEffect, useRef } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Quiz, Question, Option } from '@/types/quiz';
import { Loader2, CheckCircle, XCircle, ArrowRight, Clock, RotateCcw, History } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { useParams, useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { showToast } from '@/lib/toast';

export default function QuizTaker() {
    const t = useTranslations('Quiz');
    const params = useParams();
    const router = useRouter();
    const supabase = createClient();
    const [quiz, setQuiz] = useState<Quiz | null>(null);
    const [answers, setAnswers] = useState<Record<string, string[]>>({});
    const [submitted, setSubmitted] = useState(false);
    const [isLoading, setIsLoading] = useState(true);
    const [score, setScore] = useState(0);
    const [timeLeft, setTimeLeft] = useState<number | null>(null);
    const [startTime, setStartTime] = useState<number>(Date.now());
    const [showReview, setShowReview] = useState(false);
    const [attempts, setAttempts] = useState<any[]>([]);
    const [showHistory, setShowHistory] = useState(false);
    const timerRef = useRef<NodeJS.Timeout | null>(null);

    useEffect(() => {
        const fetchQuiz = async () => {
            const { data } = await supabase
                .from('quizzes')
                .select(`
                    *,
                    questions:quiz_questions(
                        *,
                        options:quiz_answer_options(*)
                    )
                `)
                .eq('course_id', params.id)
                .limit(1)
                .single();

            if (data) {
                setQuiz(data as any);

                // Set timer if quiz has time limit
                if (data.time_limit) {
                    setTimeLeft(data.time_limit * 60); // Convert minutes to seconds
                }

                // Fetch previous attempts
                const { data: user } = await supabase.auth.getUser();
                if (user.user) {
                    const { data: attemptsData } = await supabase
                        .from('quiz_attempts')
                        .select('*')
                        .eq('quiz_id', data.id)
                        .eq('user_id', user.user.id)
                        .order('completed_at', { ascending: false });

                    if (attemptsData) setAttempts(attemptsData);
                }
            }
            setIsLoading(false);
        };
        fetchQuiz();
    }, [params.id]);

    // Timer countdown
    useEffect(() => {
        if (timeLeft !== null && timeLeft > 0 && !submitted) {
            timerRef.current = setInterval(() => {
                setTimeLeft(prev => {
                    if (prev === null || prev <= 1) {
                        handleSubmit(true); // Auto-submit when time runs out
                        return 0;
                    }
                    return prev - 1;
                });
            }, 1000);

            return () => {
                if (timerRef.current) clearInterval(timerRef.current);
            };
        }
    }, [timeLeft, submitted]);

    const formatTime = (seconds: number) => {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    };

    const toggleAnswer = (questionId: string, optionId: string, type: string) => {
        if (submitted) return;

        setAnswers(prev => {
            const current = prev[questionId] || [];
            if (type === 'single') {
                return { ...prev, [questionId]: [optionId] };
            } else {
                if (current.includes(optionId)) {
                    return { ...prev, [questionId]: current.filter(id => id !== optionId) };
                } else {
                    return { ...prev, [questionId]: [...current, optionId] };
                }
            }
        });
    };

    const handleSubmit = async (autoSubmit = false) => {
        if (!quiz) return;

        // Stop timer
        if (timerRef.current) clearInterval(timerRef.current);

        // Calculate score
        let correctCount = 0;
        quiz.questions.forEach((q: any) => {
            const userAns = answers[q.id] || [];
            const correctAns = q.options.filter((o: any) => o.is_correct).map((o: any) => o.id);

            const isCorrect = userAns.length === correctAns.length &&
                userAns.every(id => correctAns.includes(id));

            if (isCorrect) correctCount++;
        });

        const finalScore = (correctCount / quiz.questions.length) * 100;
        setScore(finalScore);
        setSubmitted(true);

        // Calculate time taken
        const timeTaken = Math.floor((Date.now() - startTime) / 1000);

        // Save to database
        const { data: user } = await supabase.auth.getUser();
        if (user.user) {
            const { error } = await supabase
                .from('quiz_attempts')
                .insert({
                    quiz_id: quiz.id,
                    user_id: user.user.id,
                    score: finalScore,
                    total_points: quiz.questions.length,
                    earned_points: correctCount,
                    passed: finalScore >= 70,
                    started_at: new Date(startTime).toISOString(),
                    completed_at: new Date().toISOString(),
                    answers: answers,
                    time_taken: timeTaken,
                });

            if (error) {
                console.error('Error saving quiz attempt:', error);
                showToast.error(t('error_saving'));
            } else {
                showToast.success(autoSubmit ? t('time_up') : t('submitted'));
            }
        }
    };

    const handleRetry = () => {
        setAnswers({});
        setSubmitted(false);
        setScore(0);
        setShowReview(false);
        setStartTime(Date.now());

        // Reset timer
        if (quiz?.time_limit) {
            setTimeLeft(quiz.time_limit * 60);
        }
    };

    if (isLoading) return <div className="p-12 flex justify-center"><Loader2 className="w-8 h-8 animate-spin" /></div>;
    if (!quiz) return <div className="p-6 text-muted-foreground border border-dashed rounded-xl text-center">{t('no_quiz')}</div>;

    return (
        <div className="space-y-8 max-w-2xl mx-auto py-8">
            {/* Header */}
            <div className="text-center">
                <h2 className="text-2xl font-bold">{quiz.title}</h2>
                <p className="text-muted-foreground">{quiz.description || t('subtitle')}</p>

                {/* Timer */}
                {timeLeft !== null && !submitted && (
                    <div className={`mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-lg ${timeLeft < 60 ? 'bg-red-500/10 text-red-500' : 'bg-blue-500/10 text-blue-500'
                        }`}>
                        <Clock className="w-4 h-4" />
                        <span className="font-mono font-bold">{formatTime(timeLeft)}</span>
                    </div>
                )}

                {/* History Button */}
                {attempts.length > 0 && !submitted && (
                    <button
                        onClick={() => setShowHistory(!showHistory)}
                        className="mt-4 ml-4 inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200 transition-colors"
                    >
                        <History className="w-4 h-4" />
                        {t('history')} ({attempts.length})
                    </button>
                )}
            </div>

            {/* Quiz History */}
            <AnimatePresence>
                {showHistory && (
                    <motion.div
                        initial={{ opacity: 0, height: 0 }}
                        animate={{ opacity: 1, height: 'auto' }}
                        exit={{ opacity: 0, height: 0 }}
                        className="bg-white text-gray-900 rounded-xl p-6 border border-gray-200"
                    >
                        <h3 className="font-semibold mb-4">{t('previous_attempts')}</h3>
                        <div className="space-y-2">
                            {attempts.map((attempt, idx) => (
                                <div key={attempt.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                                    <div>
                                        <span className="font-medium">#{attempts.length - idx}</span>
                                        <span className="text-sm text-gray-600 ml-2">
                                            {new Date(attempt.completed_at).toLocaleDateString()}
                                        </span>
                                    </div>
                                    <div className="flex items-center gap-4">
                                        {attempt.time_taken && (
                                            <span className="text-sm text-gray-600">
                                                {formatTime(attempt.time_taken)}
                                            </span>
                                        )}
                                        <span className={`font-bold ${attempt.score >= 70 ? 'text-green-600' : 'text-yellow-600'
                                            }`}>
                                            {attempt.score.toFixed(0)}%
                                        </span>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>

            {/* Results */}
            {submitted && (
                <motion.div
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className={`p-6 rounded-xl text-center ${score >= 70 ? 'bg-green-500/10 text-green-600' : 'bg-yellow-500/10 text-yellow-600'}`}
                >
                    <h3 className="text-xl font-bold mb-2">{t('complete_title')}</h3>
                    <div className="text-4xl font-black mb-2">{score.toFixed(0)}%</div>
                    <p className="text-sm opacity-80 mb-4">
                        {score >= 70 ? t('passed') : t('failed')}
                    </p>
                    <div className="flex gap-2">
                        <button
                            onClick={() => setShowReview(!showReview)}
                            className="flex-1 px-4 py-2 bg-white text-gray-900 rounded-lg text-sm font-medium hover:bg-gray-100 transition-colors"
                        >
                            {showReview ? t('hide_review') : t('show_review')}
                        </button>
                        <button
                            onClick={handleRetry}
                            className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors flex items-center justify-center gap-2"
                        >
                            <RotateCcw className="w-4 h-4" />
                            {t('retry')}
                        </button>
                    </div>
                </motion.div>
            )}

            {/* Questions */}
            <div className="space-y-8">
                {quiz.questions.map((q: any, idx: number) => {
                    const userAns = answers[q.id] || [];
                    const correctAns = q.options.filter((o: any) => o.is_correct).map((o: any) => o.id);
                    const isCorrect = submitted &&
                        userAns.length === correctAns.length &&
                        userAns.every(id => correctAns.includes(id));

                    return (
                        <div key={q.id} className={`bg-white text-gray-900 p-6 rounded-xl border-2 ${submitted ? (isCorrect ? 'border-green-500' : 'border-yellow-500') : 'border-gray-200'
                            }`}>
                            <h4 className="font-semibold text-lg mb-4 flex gap-3">
                                <span className="text-gray-500 select-none">{idx + 1}.</span>
                                {q.text}
                            </h4>

                            <div className="space-y-3 pl-8">
                                {q.options.map((opt: any) => {
                                    const isSelected = userAns.includes(opt.id);
                                    const isTrueCorrect = opt.is_correct;

                                    let optionStyle = "border-gray-300 hover:border-blue-500 bg-white";
                                    if (isSelected && !submitted) optionStyle = "border-blue-500 bg-blue-50 text-blue-700";
                                    if (submitted) {
                                        if (isTrueCorrect) optionStyle = "border-green-500 bg-green-50 text-green-700";
                                        else if (isSelected && !isTrueCorrect) optionStyle = "border-red-500 bg-red-50 text-red-700";
                                        else optionStyle = "border-gray-200 opacity-50";
                                    }

                                    return (
                                        <button
                                            key={opt.id}
                                            onClick={() => toggleAnswer(q.id, opt.id, q.type)}
                                            disabled={submitted}
                                            className={`w-full text-left p-4 rounded-lg border-2 transition-all flex items-center justify-between ${optionStyle}`}
                                        >
                                            <span>{opt.text}</span>
                                            {submitted && isTrueCorrect && <CheckCircle className="w-5 h-5" />}
                                            {submitted && isSelected && !isTrueCorrect && <XCircle className="w-5 h-5" />}
                                        </button>
                                    );
                                })}
                            </div>

                            {/* Explanation */}
                            {submitted && showReview && q.explanation && (
                                <motion.div
                                    initial={{ opacity: 0, height: 0 }}
                                    animate={{ opacity: 1, height: 'auto' }}
                                    className="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-lg"
                                >
                                    <p className="text-sm text-blue-900">
                                        <strong>{t('explanation')}:</strong> {q.explanation}
                                    </p>
                                </motion.div>
                            )}
                        </div>
                    );
                })}
            </div>

            {/* Submit Button */}
            {!submitted && (
                <button
                    onClick={() => handleSubmit(false)}
                    className="w-full py-4 bg-blue-600 text-white rounded-xl font-bold text-lg hover:bg-blue-700 transition-colors shadow-lg"
                >
                    {t('submit')}
                </button>
            )}
        </div>
    );
}
