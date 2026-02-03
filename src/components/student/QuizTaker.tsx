'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Clock, CheckCircle, XCircle, AlertCircle, RefreshCw, GripVertical } from 'lucide-react';
import { Reorder } from 'framer-motion';

interface QuizTakerProps {
    lessonId?: string;
    moduleId?: string;
    userId: string;
}

export default function QuizTaker({ lessonId, moduleId, userId }: QuizTakerProps) {
    const supabase = createClient();
    const [quiz, setQuiz] = useState<any>(null);
    const [questions, setQuestions] = useState<any[]>([]);
    const [answers, setAnswers] = useState<Record<string, any>>({}); // Stores answer IDs or complex objects
    const [submitted, setSubmitted] = useState(false);
    const [result, setResult] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);
    const [timeLeft, setTimeLeft] = useState<number | null>(null);

    // State for drag and drop orderings: questionId -> array of answer objects (the shuffled/ordered right side)
    const [dndState, setDndState] = useState<Record<string, any[]>>({});

    useEffect(() => {
        if (lessonId || moduleId) {
            fetchQuiz();
        }
    }, [lessonId, moduleId]);

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

        const query = supabase.from('quizzes').select('*');
        if (lessonId) query.eq('lesson_id', lessonId);
        else if (moduleId) query.eq('module_id', moduleId);
        else {
            setLoading(false);
            return;
        }

        const { data: quizData } = await query.single();

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

                // Initialize DnD state and Shuffle answers if enabled for non-DnD
                const initialDndState: Record<string, any[]> = {};

                processedQuestions = processedQuestions.map(q => {
                    if (q.question_type === 'drag_and_drop') {
                        // For DnD, we keep original order for left side (questions.answers)
                        // And create a shuffled copy for the right side (initialDndState)
                        initialDndState[q.id] = [...q.answers].sort(() => Math.random() - 0.5);
                        // Also initialize answer for DnD to the shuffled state
                        return q;
                    } else if (quizData.shuffle_answers) {
                        return {
                            ...q,
                            answers: [...q.answers].sort(() => Math.random() - 0.5)
                        };
                    }
                    return q;
                });

                setQuestions(processedQuestions);
                setDndState(initialDndState);

                // Initialize answers for DnD questions with the shuffled order
                const initialAnswers: Record<string, any> = {};
                Object.keys(initialDndState).forEach(qId => {
                    initialAnswers[qId] = initialDndState[qId];
                });
                setAnswers(prev => ({ ...prev, ...initialAnswers }));
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

    const handleAnswerChange = (questionId: string, value: any) => {
        setAnswers(prev => ({ ...prev, [questionId]: value }));
    };

    const handleDndUpdate = (questionId: string, newOrder: any[]) => {
        setDndState(prev => ({ ...prev, [questionId]: newOrder }));
        handleAnswerChange(questionId, newOrder);
    };

    const handleSubmit = async () => {
        if (submitting) return;

        // Check if all questions answered
        // For DnD, they are always "answered" as there is an order.
        // For MCQ/Text, checks if key exists.
        const unanswered = questions.filter(q => {
            if (q.question_type === 'drag_and_drop') return false; // Always has a state
            return !answers[q.id];
        });

        if (unanswered.length > 0 && !confirm(`You have ${unanswered.length} unanswered questions. Submit anyway?`)) {
            return;
        }

        setSubmitting(true);

        try {
            // Calculate score
            let earnedPoints = 0;
            let totalPoints = 0;

            questions.forEach(question => {
                const qPoints = question.points || 1;
                totalPoints += qPoints;

                if (question.question_type === 'drag_and_drop') {
                    // Score based on correct matches
                    const userOrder = answers[question.id] as any[];
                    // question.answers is the "correct" order (Left items)
                    // userOrder is the Right items.
                    // Correct match: userOrder[i].id === question.answers[i].id

                    if (userOrder && userOrder.length > 0) {
                        let matches = 0;
                        question.answers.forEach((correctPair: any, index: number) => {
                            if (userOrder[index]?.id === correctPair.id) {
                                matches++;
                            }
                        });

                        const matchPercentage = matches / question.answers.length;
                        earnedPoints += qPoints * matchPercentage;
                    }

                } else if (question.question_type === 'short_answer') {
                    // Manual grading needed often, but for now 0 points until graded? 
                    // Or exact match if we had a correct text field.
                    // Current schema doesn't seem to hold "correct short answer text" for auto-grading easily unless `is_correct` on an option holds it.
                    // Assuming manual grading or simple exact match if an option is provided.
                    const userText = answers[question.id];
                    const correctOption = question.answers.find((a: any) => a.is_correct);
                    if (correctOption && userText?.toLowerCase().trim() === correctOption.option_text.toLowerCase().trim()) {
                        earnedPoints += qPoints;
                    }
                } else {
                    const selectedAnswerId = answers[question.id];
                    const correctAnswer = question.answers.find((a: any) => a.is_correct);

                    if (selectedAnswerId && selectedAnswerId === correctAnswer?.id) {
                        earnedPoints += qPoints;
                    }
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
        // Reshuffle for retake?
        fetchQuiz();
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
        return <div className="p-6 text-muted-foreground">No quiz available.</div>;
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
                        <span>Points: {parseFloat(result.earned_points).toFixed(1)}/{result.total_points}</span>
                        <span className="text-muted-foreground">•</span>
                        <span>Completed: {new Date(result.completed_at).toLocaleString()}</span>
                    </div>
                </div>

                {/* Retake Button */}
                <button
                    onClick={handleRetake}
                    className="w-full py-3 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-colors font-medium flex items-center justify-center gap-2"
                >
                    <RefreshCw className="w-4 h-4" />
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
                        <p className="mb-4 text-lg">{question.question_text}</p>

                        {question.image_url && (
                            <img src={question.image_url} alt="Question" className="mb-4 rounded-lg max-h-64 object-cover" />
                        )}

                        {question.question_type === 'drag_and_drop' ? (
                            <div className="grid grid-cols-2 gap-8">
                                <div className="space-y-3">
                                    <h4 className="text-sm font-medium text-muted-foreground uppercase tracking-wider mb-2">Items</h4>
                                    {question.answers.map((answer: any) => (
                                        <div key={`left-${answer.id}`} className="h-14 flex items-center px-4 bg-muted/30 border border-border rounded-lg">
                                            {answer.option_text}
                                        </div>
                                    ))}
                                </div>
                                <div>
                                    <h4 className="text-sm font-medium text-muted-foreground uppercase tracking-wider mb-2">Matches (Drag to reorder)</h4>
                                    <Reorder.Group
                                        axis="y"
                                        values={dndState[question.id] || []}
                                        onReorder={(newOrder) => handleDndUpdate(question.id, newOrder)}
                                        className="space-y-3"
                                    >
                                        {dndState[question.id]?.map((item: any) => (
                                            <Reorder.Item
                                                key={item.id}
                                                value={item}
                                                className="h-14 flex items-center px-4 bg-background border border-border rounded-lg cursor-grab active:cursor-grabbing shadow-sm hover:border-primary/50 transition-colors gap-3"
                                            >
                                                <GripVertical className="w-4 h-4 text-muted-foreground" />
                                                {item.match_text}
                                            </Reorder.Item>
                                        ))}
                                    </Reorder.Group>
                                </div>
                            </div>
                        ) : question.question_type === 'short_answer' ? (
                            <input
                                type="text"
                                className="w-full px-4 py-3 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                                placeholder="Type your answer..."
                                onChange={(e) => handleAnswerChange(question.id, e.target.value)}
                                value={answers[question.id] || ''}
                            />
                        ) : (
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
                        )}
                    </div>
                ))}
            </div>

            {/* Submit Button */}
            <button
                onClick={handleSubmit}
                disabled={submitting}
                className="w-full py-3 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 disabled:opacity-50 transition-colors font-medium"
            >
                {submitting ? 'Submitting...' : 'Submit Quiz'}
            </button>
        </div>
    );
}
