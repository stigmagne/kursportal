'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Plus, Trash2, GripVertical, Save, Eye } from 'lucide-react';

interface QuizBuilderProps {
    lessonId?: string;
    moduleId?: string;
}

interface Question {
    id?: string;
    question_text: string;
    question_type: 'multiple_choice' | 'true_false' | 'short_answer' | 'drag_and_drop';
    order_index: number;
    points: number;
    explanation: string;
    image_url?: string;
    video_url?: string;
    answers: Answer[];
}

interface Answer {
    id?: string;
    option_text: string;
    match_text?: string; // For drag and drop matching
    is_correct: boolean;
    order_index: number;
}

export default function QuizBuilder({ lessonId, moduleId }: QuizBuilderProps) {
    const supabase = createClient();
    const [quiz, setQuiz] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [saveSuccess, setSaveSuccess] = useState(false);

    // Quiz settings
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [passingScore, setPassingScore] = useState(70);
    const [timeLimit, setTimeLimit] = useState<number | null>(null);
    const [shuffleQuestions, setShuffleQuestions] = useState(false);
    const [shuffleAnswers, setShuffleAnswers] = useState(true);
    const [showCorrectAnswers, setShowCorrectAnswers] = useState(true);
    const [requiredForCompletion, setRequiredForCompletion] = useState(false);

    // Questions
    const [questions, setQuestions] = useState<Question[]>([]);

    useEffect(() => {
        if (lessonId || moduleId) {
            fetchQuiz();
        }
    }, [lessonId, moduleId]);

    const fetchQuiz = async () => {
        setLoading(true);
        let query = supabase.from('quizzes').select('*');

        if (lessonId) {
            query = query.eq('lesson_id', lessonId);
        } else if (moduleId) {
            query = query.eq('module_id', moduleId);
        } else {
            setLoading(false);
            return;
        }

        const { data: quizData } = await query.single();

        if (quizData) {
            setQuiz(quizData);
            setTitle(quizData.title);
            setDescription(quizData.description || '');
            setPassingScore(quizData.passing_score);
            setTimeLimit(quizData.time_limit_minutes);
            setShuffleQuestions(quizData.shuffle_questions);
            setShuffleAnswers(quizData.shuffle_answers);
            setShowCorrectAnswers(quizData.show_correct_answers);
            setRequiredForCompletion(quizData.required_for_completion);

            // Fetch questions
            const { data: questionsData } = await supabase
                .from('quiz_questions')
                .select(`
                    *,
                    answers:quiz_answer_options(*)
                `)
                .eq('quiz_id', quizData.id)
                .order('order_index');

            if (questionsData) {
                setQuestions(questionsData.map((q: any) => ({
                    ...q,
                    answers: q.answers.sort((a: any, b: any) => a.order_index - b.order_index)
                })));
            }
        }
        setLoading(false);
    };

    const handleSave = async () => {
        setSaving(true);
        try {
            let quizId = quiz?.id;

            const quizData = {
                title,
                description,
                passing_score: passingScore,
                time_limit_minutes: timeLimit,
                shuffle_questions: shuffleQuestions,
                shuffle_answers: shuffleAnswers,
                show_correct_answers: showCorrectAnswers,
                required_for_completion: requiredForCompletion,
                updated_at: new Date().toISOString()
            };

            // Create or update quiz
            if (quiz) {
                await supabase
                    .from('quizzes')
                    .update(quizData)
                    .eq('id', quiz.id);
            } else {
                const { data: newQuiz } = await supabase
                    .from('quizzes')
                    .insert({
                        ...quizData,
                        lesson_id: lessonId || null,
                        module_id: moduleId || null,
                    })
                    .select()
                    .single();

                quizId = newQuiz?.id;
                setQuiz(newQuiz);
            }

            // Save questions
            if (quizId) {
                // Delete removed questions
                const existingQuestionIds = questions.filter(q => q.id).map(q => q.id);
                if (existingQuestionIds.length > 0) {
                    await supabase
                        .from('quiz_questions')
                        .delete()
                        .eq('quiz_id', quizId)
                        .not('id', 'in', `(${existingQuestionIds.join(',')})`);
                }

                // Upsert questions
                for (const question of questions) {
                    let questionId = question.id;

                    const questionData = {
                        question_text: question.question_text,
                        question_type: question.question_type,
                        order_index: question.order_index,
                        points: question.points,
                        explanation: question.explanation,
                        image_url: question.image_url || null,
                        video_url: question.video_url || null
                    };

                    if (questionId) {
                        await supabase
                            .from('quiz_questions')
                            .update(questionData)
                            .eq('id', questionId);
                    } else {
                        const { data: newQuestion } = await supabase
                            .from('quiz_questions')
                            .insert({
                                quiz_id: quizId,
                                ...questionData
                            })
                            .select()
                            .single();

                        questionId = newQuestion?.id;
                    }

                    // Save answers
                    if (questionId) {
                        // Delete removed answers
                        const existingAnswerIds = question.answers.filter(a => a.id).map(a => a.id);
                        if (existingAnswerIds.length > 0) {
                            await supabase
                                .from('quiz_answer_options')
                                .delete()
                                .eq('question_id', questionId)
                                .not('id', 'in', `(${existingAnswerIds.join(',')})`);
                        }

                        // Upsert answers
                        for (const answer of question.answers) {
                            const answerData = {
                                option_text: answer.option_text,
                                match_text: answer.match_text || null,
                                is_correct: answer.is_correct,
                                order_index: answer.order_index
                            };

                            if (answer.id) {
                                await supabase
                                    .from('quiz_answer_options')
                                    .update(answerData)
                                    .eq('id', answer.id);
                            } else {
                                await supabase
                                    .from('quiz_answer_options')
                                    .insert({
                                        question_id: questionId,
                                        ...answerData
                                    });
                            }
                        }
                    }
                }
            }

            setSaveSuccess(true);
            setTimeout(() => setSaveSuccess(false), 3000);
            fetchQuiz();
        } catch (error) {
            console.error('Error saving quiz:', error);
            alert('Failed to save quiz');
        } finally {
            setSaving(false);
        }
    };

    const addQuestion = (type: 'multiple_choice' | 'true_false' | 'short_answer' | 'drag_and_drop') => {
        let answers: Answer[] = [];

        if (type === 'true_false') {
            answers = [
                { option_text: 'True', is_correct: false, order_index: 0 },
                { option_text: 'False', is_correct: false, order_index: 1 }
            ];
        } else if (type === 'drag_and_drop') {
            answers = [
                { option_text: '', match_text: '', is_correct: true, order_index: 0 },
                { option_text: '', match_text: '', is_correct: true, order_index: 1 },
                { option_text: '', match_text: '', is_correct: true, order_index: 2 }
            ];
        } else if (type === 'multiple_choice') {
            answers = [
                { option_text: '', is_correct: false, order_index: 0 },
                { option_text: '', is_correct: false, order_index: 1 },
                { option_text: '', is_correct: false, order_index: 2 },
                { option_text: '', is_correct: false, order_index: 3 }
            ];
        }

        const newQuestion: Question = {
            question_text: '',
            question_type: type,
            order_index: questions.length,
            points: 1,
            explanation: '',
            answers
        };
        setQuestions([...questions, newQuestion]);
    };

    const deleteQuestion = (index: number) => {
        if (confirm('Delete this question?')) {
            setQuestions(questions.filter((_, i) => i !== index));
        }
    };

    const updateQuestion = (index: number, updates: Partial<Question>) => {
        const updated = [...questions];
        updated[index] = { ...updated[index], ...updates };
        setQuestions(updated);
    };

    const updateAnswer = (qIndex: number, aIndex: number, updates: Partial<Answer>) => {
        const updated = [...questions];
        updated[qIndex].answers[aIndex] = { ...updated[qIndex].answers[aIndex], ...updates };
        setQuestions(updated);
    };

    const addAnswerOption = (qIndex: number) => {
        const updated = [...questions];
        const newOrderIndex = updated[qIndex].answers.length;
        updated[qIndex].answers.push({
            option_text: '',
            match_text: updated[qIndex].question_type === 'drag_and_drop' ? '' : undefined,
            is_correct: updated[qIndex].question_type === 'drag_and_drop', // Always correct for matching pairs
            order_index: newOrderIndex
        });
        setQuestions(updated);
    };

    const removeAnswerOption = (qIndex: number, aIndex: number) => {
        const updated = [...questions];
        updated[qIndex].answers = updated[qIndex].answers.filter((_, i) => i !== aIndex);
        setQuestions(updated);
    };

    const deleteQuiz = async () => {
        if (!quiz) return;
        if (!confirm('Delete this entire quiz? This cannot be undone.')) return;

        await supabase.from('quizzes').delete().eq('id', quiz.id);
        setQuiz(null);
        setQuestions([]);
        setTitle('');
        setDescription('');
    };

    if (loading) {
        return <div className="animate-pulse p-6">Loading quiz...</div>;
    }

    return (
        <div className="space-y-6">
            {/* Quiz Settings */}
            <div className="glass p-6 rounded-xl border border-white/10 space-y-4">
                <h3 className="text-xl font-semibold mb-4">Quiz Settings</h3>

                <div>
                    <label className="block text-sm font-medium mb-2">Quiz Title *</label>
                    <input
                        type="text"
                        value={title}
                        onChange={(e) => setTitle(e.target.value)}
                        className="w-full px-4 py-2 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                        placeholder={moduleId ? "e.g., Module Assessment" : "e.g., Lesson Quiz"}
                    />
                </div>

                <div>
                    <label className="block text-sm font-medium mb-2">Description</label>
                    <textarea
                        value={description}
                        onChange={(e) => setDescription(e.target.value)}
                        className="w-full px-4 py-2 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                        rows={3}
                        placeholder="Optional quiz instructions..."
                    />
                </div>

                <div className="grid grid-cols-2 gap-4">
                    <div>
                        <label className="block text-sm font-medium mb-2">Passing Score (%)</label>
                        <input
                            type="number"
                            value={passingScore}
                            onChange={(e) => setPassingScore(parseInt(e.target.value))}
                            min="0"
                            max="100"
                            className="w-full px-4 py-2 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium mb-2">Time Limit (minutes)</label>
                        <input
                            type="number"
                            value={timeLimit || ''}
                            onChange={(e) => setTimeLimit(e.target.value ? parseInt(e.target.value) : null)}
                            placeholder="No limit"
                            className="w-full px-4 py-2 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                        />
                    </div>
                </div>

                <div className="space-y-2">
                    <label className="flex items-center gap-2">
                        <input
                            type="checkbox"
                            checked={shuffleQuestions}
                            onChange={(e) => setShuffleQuestions(e.target.checked)}
                            className="w-4 h-4"
                        />
                        <span className="text-sm">Shuffle question order</span>
                    </label>

                    <label className="flex items-center gap-2">
                        <input
                            type="checkbox"
                            checked={shuffleAnswers}
                            onChange={(e) => setShuffleAnswers(e.target.checked)}
                            className="w-4 h-4"
                        />
                        <span className="text-sm">Shuffle answer order</span>
                    </label>

                    <label className="flex items-center gap-2">
                        <input
                            type="checkbox"
                            checked={showCorrectAnswers}
                            onChange={(e) => setShowCorrectAnswers(e.target.checked)}
                            className="w-4 h-4"
                        />
                        <span className="text-sm">Show correct answers after submission</span>
                    </label>

                    <label className="flex items-center gap-2">
                        <input
                            type="checkbox"
                            checked={requiredForCompletion}
                            onChange={(e) => setRequiredForCompletion(e.target.checked)}
                            className="w-4 h-4"
                        />
                        <span className="text-sm font-medium text-primary">Require passing this quiz to complete {moduleId ? 'module' : 'lesson'}</span>
                    </label>
                </div>
            </div>

            {/* Questions */}
            <div className="space-y-4">
                <div className="flex items-center justify-between">
                    <h3 className="text-xl font-semibold">Questions ({questions.length})</h3>
                    <div className="flex gap-2">
                        <button
                            onClick={() => addQuestion('multiple_choice')}
                            className="flex items-center gap-2 px-4 py-2 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-colors"
                        >
                            <Plus className="w-4 h-4" />
                            Multi-Choice
                        </button>
                        <button
                            onClick={() => addQuestion('true_false')}
                            className="flex items-center gap-2 px-4 py-2 bg-muted hover:bg-muted/80 rounded-lg transition-colors"
                        >
                            <Plus className="w-4 h-4" />
                            True/False
                        </button>
                        <button
                            onClick={() => addQuestion('drag_and_drop')}
                            className="flex items-center gap-2 px-4 py-2 bg-blue-100 text-blue-800 hover:bg-blue-200 rounded-lg transition-colors"
                        >
                            <Plus className="w-4 h-4" />
                            Drag & Drop
                        </button>
                        <button
                            onClick={() => addQuestion('short_answer')}
                            className="flex items-center gap-2 px-4 py-2 bg-muted hover:bg-muted/80 rounded-lg transition-colors"
                        >
                            <Plus className="w-4 h-4" />
                            Short Answer
                        </button>
                    </div>
                </div>

                {questions.map((question, qIndex) => (
                    <div key={qIndex} className="glass p-6 rounded-xl border border-white/10 space-y-4">
                        <div className="flex items-start justify-between">
                            <div className="flex items-center gap-2">
                                <GripVertical className="w-5 h-5 text-muted-foreground cursor-move" />
                                <span className="font-medium">Question {qIndex + 1}</span>
                                <span className="text-xs px-2 py-1 rounded bg-muted">
                                    {question.question_type.replace(/_/g, ' ').toUpperCase()}
                                </span>
                            </div>
                            <button
                                onClick={() => deleteQuestion(qIndex)}
                                className="text-red-500 hover:text-red-600"
                            >
                                <Trash2 className="w-5 h-5" />
                            </button>
                        </div>

                        <div>
                            <label className="block text-sm font-medium mb-2">Question Text *</label>
                            <textarea
                                value={question.question_text}
                                onChange={(e) => updateQuestion(qIndex, { question_text: e.target.value })}
                                className="w-full px-4 py-2 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                                rows={2}
                                placeholder="Enter your question here..."
                            />
                        </div>

                        {/* Media URLs */}
                        <div className="grid grid-cols-2 gap-4">
                            <div>
                                <label className="block text-sm font-medium mb-2">Image URL (optional)</label>
                                <input
                                    type="url"
                                    value={question.image_url || ''}
                                    onChange={(e) => updateQuestion(qIndex, { image_url: e.target.value })}
                                    className="w-full px-4 py-2 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                                    placeholder="https://..."
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-2">Video URL (optional)</label>
                                <input
                                    type="url"
                                    value={question.video_url || ''}
                                    onChange={(e) => updateQuestion(qIndex, { video_url: e.target.value })}
                                    className="w-full px-4 py-2 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                                    placeholder="https://..."
                                />
                            </div>
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                            <div>
                                <label className="block text-sm font-medium mb-2">Points</label>
                                <input
                                    type="number"
                                    value={question.points}
                                    onChange={(e) => updateQuestion(qIndex, { points: parseInt(e.target.value) || 1 })}
                                    min="1"
                                    className="w-full px-4 py-2 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                                />
                            </div>
                        </div>

                        {question.question_type === 'drag_and_drop' && (
                            <div>
                                <label className="block text-sm font-medium mb-2">Matching Pairs</label>
                                <div className="space-y-3">
                                    {question.answers.map((answer, aIndex) => (
                                        <div key={aIndex} className="flex items-center gap-2">
                                            <input
                                                type="text"
                                                value={answer.option_text}
                                                onChange={(e) => updateAnswer(qIndex, aIndex, { option_text: e.target.value })}
                                                className="flex-1 px-4 py-2 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                                                placeholder={`Item ${aIndex + 1}`}
                                            />
                                            <span className="text-muted-foreground">Matches</span>
                                            <input
                                                type="text"
                                                value={answer.match_text || ''}
                                                onChange={(e) => updateAnswer(qIndex, aIndex, { match_text: e.target.value })}
                                                className="flex-1 px-4 py-2 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                                                placeholder={`Match for Item ${aIndex + 1}`}
                                            />
                                            <button
                                                onClick={() => removeAnswerOption(qIndex, aIndex)}
                                                className="text-red-500 hover:text-red-600 px-2"
                                            >
                                                <Trash2 className="w-4 h-4" />
                                            </button>
                                        </div>
                                    ))}
                                </div>
                                <button
                                    onClick={() => addAnswerOption(qIndex)}
                                    className="mt-2 text-sm text-primary hover:text-primary/80 flex items-center gap-1"
                                >
                                    <Plus className="w-4 h-4" /> Add Pair
                                </button>
                            </div>
                        )}

                        {question.question_type !== 'short_answer' && question.question_type !== 'drag_and_drop' && (
                            <div>
                                <label className="block text-sm font-medium mb-2">Answer Options</label>
                                <div className="space-y-2">
                                    {question.answers.map((answer, aIndex) => (
                                        <div key={aIndex} className="flex items-center gap-2">
                                            <input
                                                type="radio"
                                                name={`correct-${qIndex}`}
                                                checked={answer.is_correct}
                                                onChange={() => {
                                                    const updated = [...questions];
                                                    updated[qIndex].answers.forEach((a, i) => {
                                                        a.is_correct = i === aIndex;
                                                    });
                                                    setQuestions(updated);
                                                }}
                                                className="w-4 h-4"
                                            />
                                            <input
                                                type="text"
                                                value={answer.option_text}
                                                onChange={(e) => updateAnswer(qIndex, aIndex, { option_text: e.target.value })}
                                                readOnly={question.question_type === 'true_false'}
                                                className="flex-1 px-4 py-2 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                                                placeholder={`Option ${aIndex + 1}`}
                                            />
                                            {question.question_type !== 'true_false' && (
                                                <button
                                                    onClick={() => removeAnswerOption(qIndex, aIndex)}
                                                    className="text-red-500 hover:text-red-600 px-2"
                                                >
                                                    <Trash2 className="w-4 h-4" />
                                                </button>
                                            )}
                                        </div>
                                    ))}
                                </div>
                                {question.question_type !== 'true_false' && (
                                    <button
                                        onClick={() => addAnswerOption(qIndex)}
                                        className="mt-2 text-sm text-primary hover:text-primary/80 flex items-center gap-1"
                                    >
                                        <Plus className="w-4 h-4" /> Add Option
                                    </button>
                                )}
                                <p className="text-xs text-muted-foreground mt-2">Select the radio button for the correct answer</p>
                            </div>
                        )}

                        {question.question_type === 'short_answer' && (
                            <div className="p-4 bg-muted/30 rounded-lg">
                                <p className="text-sm text-muted-foreground">
                                    ℹ️ Short answer questions require manual grading. Students will type their answer, and you'll review and score it later.
                                </p>
                            </div>
                        )}

                        <div>
                            <label className="block text-sm font-medium mb-2">Explanation (shown after answering)</label>
                            <textarea
                                value={question.explanation}
                                onChange={(e) => updateQuestion(qIndex, { explanation: e.target.value })}
                                className="w-full px-4 py-2 rounded-lg bg-background border border-border focus:outline-none focus:ring-2 focus:ring-primary"
                                rows={2}
                                placeholder="Optional explanation of the correct answer..."
                            />
                        </div>
                    </div>
                ))}

                {questions.length === 0 && (
                    <div className="text-center py-12 glass rounded-xl border border-white/10">
                        <p className="text-muted-foreground mb-4">No questions yet. Add your first question to get started!</p>
                        <div className="flex gap-2 justify-center">
                            <button
                                onClick={() => addQuestion('multiple_choice')}
                                className="px-4 py-2 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-colors"
                            >
                                Add Multiple Choice
                            </button>
                            <button
                                onClick={() => addQuestion('true_false')}
                                className="px-4 py-2 bg-muted hover:bg-muted/80 rounded-lg transition-colors"
                            >
                                Add True/False
                            </button>
                            <button
                                onClick={() => addQuestion('drag_and_drop')}
                                className="px-4 py-2 bg-blue-100 text-blue-800 rounded-lg transition-colors"
                            >
                                Add Drag & Drop
                            </button>
                        </div>
                    </div>
                )}
            </div>

            {/* Actions */}
            <div className="space-y-4">
                {saveSuccess && (
                    <div className="p-4 bg-green-600/20 border border-green-600/50 rounded-lg text-green-600 text-center">
                        ✅ Quiz saved successfully!
                    </div>
                )}

                <div className="flex justify-between">
                    <button
                        onClick={deleteQuiz}
                        disabled={!quiz}
                        className="px-6 py-3 bg-red-600 hover:bg-red-700 disabled:bg-red-600/50 text-white rounded-lg transition-colors"
                    >
                        Delete Quiz
                    </button>
                    <button
                        onClick={handleSave}
                        disabled={saving || !title || questions.length === 0}
                        className="flex items-center gap-2 px-6 py-3 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 disabled:opacity-50 transition-colors"
                    >
                        <Save className="w-5 h-5" />
                        {saving ? 'Saving...' : 'Save Quiz'}
                    </button>
                </div>
            </div>
        </div>
    );
}
