'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Clock, CheckCircle, XCircle, AlertCircle } from 'lucide-react';

interface QuizTakerProps {
    lessonId: string;
    userId: string;
}

export default function QuizTaker({ lessonId, userId }: QuizTakerProps) {
    const supabase = createClient();
    const [quiz, setQuiz] = useState<any>(null);
    const [questions, setQuestions] = useState<any[]>([]);
    const [answers, setAnswers] = useState<Record<string, string>>({});
    const [submitted, setSubmitted] = useState(false);
    const [result, setResult] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);
    const [timeLeft, setTimeLeft] = useState<number | null>(null);

    useEffect(() => {
        fetchQuiz();
    }, [lessonId]);

    useEffect(() => {
        if (timeLeft === null || timeLeft <= 0 || submitted) return;

        const timer = setInterval(() => {
            setTimeLeft(prev => {
                if (prev === null || prev <= 1) {
                    handleSubmit(); // Auto-submit when time expires
                    return 0;
                }
                return prev - 1;
            });
        }, 1000);

        return () => clearInterval(timer);
    }, [timeLeft, submitted]);

    const fetchQuiz = async () => {
        setLoading(true);

        // Get quiz for this lesson
        const { data: quizData } = await supabase
            .from('quizzes')
            .select('*')
            .eq('lesson_id', lessonId)
            .single();

        if (quizData) {
            setQuiz(quizData);

            // Get questions with answers
            const { data: questionsData } = await supabase
                .from('quiz_questions')
                .select(`
                    *,
                    answers:quiz_answer_options(*)
                `)
                .eq('quiz_id', quizData.id)
                .order('order_index');

            if (questionsData) {
                let processedQuestions = questionsData.map((q: any) => ({
                    ...q,
                    answers: q.answers.sort((a: any, b: any) => a.order_index - b.order_index)
                }));

                // Shuffle questions if enabled
                if (quizData.shuffle_questions) {
                    processedQuestions = processedQuestions.sort(() => Math.random() - 0.5);
                }

                // Shuffle answers if enabled
                if (quizData.shuffle_answers) {
                    processedQuestions = processedQuestions.map(q => ({
                        ...q,
                        answers: [...q.answers].sort(() => Math.random() - 0.5)
                    }));
                }

                setQuestions(processedQuestions);
            }

            // Set timer if time limit exists
            if (quizData.time_limit_minutes) {
                setTimeLeft(quizData.time_limit_minutes * 60);
            }

            // Check if user has already attempted this quiz
            const { data: bestAttempt } = await supabase
                .from('quiz_attempts')
                .select('*')
                .eq('quiz_id', quizData.id)
                .eq('user_id', userId)
                .order('score', { ascending: false })
                .limit(1)
                .single();

            if (bestAttempt) {
                setResult(bestAttempt);
                setSubmitted(true);
            }
        }

        setLoading(false);
    };

    const handleAnswerChange = (questionId: string, answerId: string) => {
        setAnswers(prev => ({ ...prev, [questionId]: answerId }));
    };

    const handleSubmit = async () => {
        if (submitting) return;

        // Check if all questions answered
        const unanswered = questions.filter(q => !answers[q.id]);
        if (unanswered.length > 0 && !confirm(`You have ${unanswered.length} unanswered questions. Submit anyway?`)) {
            return;
        }

        setSubmitting(true);

        try {
            // Calculate score
            let earnedPoints = 0;
            let totalPoints = 0;

            questions.forEach(question => {
                totalPoints += question.points;
                const selectedAnswer = answers[question.id];
                const correctAnswer = question.answers.find((a: any) => a.is_correct);

                if (selectedAnswer && selectedAnswer === correctAnswer?.id) {
                    earnedPoints += question.points;
                }
            });

            const score = totalPoints > 0 ? (earnedPoints / totalPoints) * 100 : 0;
            const passed = score >= quiz.passing_score;

            // Save attempt
            const { data: attempt } = await supabase
                .from('quiz_attempts')
                .insert({
                    quiz_id: quiz.id,
                    user_id: userId,
                    score: score.toFixed(2),
                    total_points: totalPoints,
                    earned_points: earnedPoints,
                    passed,
                    started_at: new Date().toISOString(),
                    completed_at: new Date().toISOString(),
                    answers: answers
                })
                .select()
                .single();

            setResult(attempt);
            setSubmitted(true);
        } catch (error) {
            console.error('Error submitting quiz:', error);
            alert('Failed to submit quiz. Please try again.');
        } finally {
            setSubmitting(false);
        }
    };

    const handleRetake = () => {
        setAnswers({});
        setSubmitted(false);
        setResult(null);
        if (quiz.time_limit_minutes) {
            setTimeLeft(quiz.time_limit_minutes * 60);
        }
    };

    const formatTime = (seconds: number) => {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    };

    if (loading) {
        return <div className="animate-pulse p-6">Loading quiz...</div>;
    }

    if (!quiz) {
        return <div className="p-6 text-muted-foreground">No quiz available for this lesson.</div>;
    }

    if (submitted && result) {
        return (
            <div className="space-y-6">
                {/* Results Header */}
                <div className={`p-6 rounded-xl border-2 ${result.passed ? 'bg-green-600/10 border-green-600' : 'bg-red-600/10 border-red-600'}`}>
                    <div className="flex items-center gap-3 mb-3">
                        {result.passed ? (
                            <CheckCircle className="w-8 h-8 text-green-600" />
                        ) : (
                            <XCircle className="w-8 h-8 text-red-600" />
                        )}
                        <div>
                            <h3 className="text-2xl font-bold">{result.passed ? 'Passed!' : 'Not Passed'}</h3>
                            <p className="text-sm text-muted-foreground">
                                You scored {parseFloat(result.score).toFixed(0)}% (Passing score: {quiz.passing_score}%)
                            </p>
                        </div>
                    </div>
                    <div className="flex items-center gap-4 text-sm">
                        <span>Points: {result.earned_points}/{result.total_points}</span>
                        <span className="text-muted-foreground">•</span>
                        <span>Completed: {new Date(result.completed_at).toLocaleString()}</span>
                    </div>
                </div>

                {/* Question Review */}
                {quiz.show_correct_answers && (
                    <div className="space-y-4">
                        <h4 className="text-lg font-semibold">Review Your Answers</h4>
                        {questions.map((question, index) => {
                            const userAnswer = result.answers[question.id];
                            const correctAnswer = question.answers.find((a: any) => a.is_correct);
                            const isCorrect = userAnswer === correctAnswer?.id;

                            return (
                                <div key={question.id} className="glass p-6 rounded-xl border border-white/10">
                                    <div className="flex items-start gap-3 mb-4">
                                        {isCorrect ? (
                                            <CheckCircle className="w-5 h-5 text-green-600 mt-1" />
                                        ) : (
                                            <XCircle className="w-5 h-5 text-red-600 mt-1" />
                                        )}
                                        <div className="flex-1">
                                            <p className="font-medium mb-2">Question {index + 1}: {question.question_text}</p>
                                            <div className="space-y-2 text-sm">
                                                <p className={userAnswer === correctAnswer?.id ? 'text-green-600' : 'text-red-600'}>
                                                    Your answer: {question.answers.find((a: any) => a.id === userAnswer)?.option_text || 'No answer'}
                                                </p>
                                                {!isCorrect && (
                                                    <p className="text-green-600">
                                                        Correct answer: {correctAnswer?.option_text}
                                                    </p>
                                                )}
                                                {question.explanation && (
                                                    <p className="text-muted-foreground italic mt-2">
                                                        💡 {question.explanation}
                                                    </p>
                                                )}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                )}

                {/* Retake Button */}
                <button
                    onClick={handleRetake}
                    className="w-full py-3 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-colors font-medium"
                >
                    Retake Quiz
                </button>
            </div>
        );
    }

    return (
        <div className="space-y-6">
            {/* Quiz Header */}
            <div className="glass p-6 rounded-xl border border-white/10">
                <h2 className="text-2xl font-bold mb-2">{quiz.title}</h2>
                {quiz.description && (
                    <p className="text-muted-foreground mb-4">{quiz.description}</p>
                )}
                <div className="flex flex-wrap gap-4 text-sm">
                    <div className="flex items-center gap-2">
                        <AlertCircle className="w-4 h-4" />
                        <span>Passing Score: {quiz.passing_score}%</span>
                    </div>
                    {timeLeft !== null && (
                        <div className={`flex items-center gap-2 ${timeLeft < 60 ? 'text-red-600 font-bold' : ''}`}>
                            <Clock className="w-4 h-4" />
                            <span>Time Left: {formatTime(timeLeft)}</span>
                        </div>
                    )}
                    <div>
                        <span className="text-muted-foreground">{questions.length} questions</span>
                    </div>
                </div>
            </div>

            {/* Questions */}
            <div className="space-y-4">
                {questions.map((question, index) => (
                    <div key={question.id} className="glass p-6 rounded-xl border border-white/10">
                        <h3 className="font-semibold mb-4">
                            Question {index + 1} of {questions.length}
                        </h3>
                        <p className="mb-4">{question.question_text}</p>

                        <div className="space-y-2">
                            {question.answers.map((answer: any) => (
                                <label
                                    key={answer.id}
                                    className={`flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-colors ${answers[question.id] === answer.id
                                            ? 'border-primary bg-primary/10'
                                            : 'border-border hover:bg-muted/50'
                                        }`}
                                >
                                    <input
                                        type="radio"
                                        name={`question-${question.id}`}
                                        checked={answers[question.id] === answer.id}
                                        onChange={() => handleAnswerChange(question.id, answer.id)}
                                        className="w-4 h-4"
                                    />
                                    <span>{answer.option_text}</span>
                                </label>
                            ))}
                        </div>
                    </div>
                ))}
            </div>

            {/* Submit Button */}
            <button
                onClick={handleSubmit}
                disabled={submitting || Object.keys(answers).length === 0}
                className="w-full py-3 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 disabled:opacity-50 transition-colors font-medium"
            >
                {submitting ? 'Submitting...' : `Submit Quiz (${Object.keys(answers).length}/${questions.length} answered)`}
            </button>
        </div>
    );
}
