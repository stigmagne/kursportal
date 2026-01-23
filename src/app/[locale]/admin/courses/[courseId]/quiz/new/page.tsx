'use client';

import { useState, use } from 'react';
import { useRouter } from '@/i18n/routing';
import { createClient } from '@/utils/supabase/client';
import { ArrowLeft, Save, Plus, Trash2, CheckCircle } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Quiz, Question, Option, QuestionType } from '@/types/quiz';
import { v4 as uuidv4 } from 'uuid';

export default function QuizBuilder({ params }: { params: Promise<{ courseId: string }> }) {
    const { courseId } = use(params);
    const router = useRouter();
    const supabase = createClient();
    const [isLoading, setIsLoading] = useState(false);

    // Initial State
    const [title, setTitle] = useState('New Quiz');
    const [questions, setQuestions] = useState<Question[]>([]);

    const addQuestion = () => {
        const newQuestion: Question = {
            id: uuidv4(),
            text: '',
            type: 'single',
            options: [
                { id: uuidv4(), text: '' },
                { id: uuidv4(), text: '' }
            ],
            correctOptionIds: []
        };
        setQuestions([...questions, newQuestion]);
    };

    const updateQuestion = (id: string, updates: Partial<Question>) => {
        setQuestions(questions.map(q => q.id === id ? { ...q, ...updates } : q));
    };

    const removeQuestion = (id: string) => {
        setQuestions(questions.filter(q => q.id !== id));
    };

    const addOption = (questionId: string) => {
        setQuestions(questions.map(q => {
            if (q.id === questionId) {
                return { ...q, options: [...q.options, { id: uuidv4(), text: '' }] };
            }
            return q;
        }));
    }

    const removeOption = (questionId: string, optionId: string) => {
        setQuestions(questions.map(q => {
            if (q.id === questionId) {
                return { ...q, options: q.options.filter(o => o.id !== optionId) };
            }
            return q;
        }));
    }

    const updateOptionText = (questionId: string, optionId: string, text: string) => {
        setQuestions(questions.map(q => {
            if (q.id === questionId) {
                return {
                    ...q,
                    options: q.options.map(o => o.id === optionId ? { ...o, text } : o)
                };
            }
            return q;
        }));
    }

    const toggleCorrectOption = (questionId: string, optionId: string, type: QuestionType) => {
        setQuestions(questions.map(q => {
            if (q.id === questionId) {
                let newCorrectIds = [...q.correctOptionIds];
                if (type === 'single') {
                    newCorrectIds = [optionId];
                } else {
                    if (newCorrectIds.includes(optionId)) {
                        newCorrectIds = newCorrectIds.filter(id => id !== optionId);
                    } else {
                        newCorrectIds.push(optionId);
                    }
                }
                return { ...q, correctOptionIds: newCorrectIds };
            }
            return q;
        }));
    }

    // Save to DB
    const handleSave = async () => {
        if (!title) return alert("Title required");
        setIsLoading(true);

        try {
            const quizData = {
                course_id: courseId,
                title,
                questions: questions // Store as JSONB
            };

            const { error } = await supabase.from('quizzes').insert(quizData);
            if (error) throw error;

            router.push(`/admin/courses/edit/${courseId}`);
            router.refresh();
        } catch (err) {
            console.error(err);
            alert("Failed to save quiz");
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="max-w-4xl mx-auto px-4 py-8 space-y-8">
            {/* Header */}
            <div className="flex items-center justify-between sticky top-0 bg-background/80 backdrop-blur-md z-10 py-4 border-b border-border">
                <div className="flex items-center gap-4">
                    <Link href={`/admin/courses/edit/${courseId}`} className="p-2 hover:bg-muted rounded-full">
                        <ArrowLeft className="w-5 h-5" />
                    </Link>
                    <input
                        value={title}
                        onChange={(e) => setTitle(e.target.value)}
                        className="text-2xl font-bold bg-transparent border-none focus:outline-none focus:ring-0 placeholder:text-muted-foreground w-full"
                        placeholder="Quiz Title"
                    />
                </div>
                <button
                    onClick={handleSave}
                    disabled={isLoading}
                    className="flex items-center gap-2 bg-primary text-primary-foreground px-6 py-2 rounded-lg font-medium hover:bg-primary/90"
                >
                    {isLoading ? "Saving..." : <><Save className="w-4 h-4" /> Save Quiz</>}
                </button>
            </div>

            {/* Questions List */}
            <div className="space-y-6">
                {questions.map((q, index) => (
                    <div key={q.id} className="glass p-6 rounded-xl border border-white/10 relative group">
                        <div className="absolute right-4 top-4 opacity-0 group-hover:opacity-100 transition-opacity">
                            <button onClick={() => removeQuestion(q.id)} className="text-destructive hover:bg-destructive/10 p-2 rounded-md">
                                <Trash2 className="w-4 h-4" />
                            </button>
                        </div>

                        <div className="flex gap-4 items-start mb-4">
                            <span className="text-muted-foreground font-mono mt-2">Q{index + 1}</span>
                            <div className="flex-1 space-y-4">
                                <input
                                    value={q.text}
                                    onChange={(e) => updateQuestion(q.id, { text: e.target.value })}
                                    placeholder="Enter question text..."
                                    className="w-full bg-transparent text-lg font-medium border-b border-border focus:border-primary focus:outline-none py-1"
                                />

                                <div className="flex items-center gap-4 text-sm">
                                    <label className="flex items-center gap-2 cursor-pointer">
                                        <input
                                            type="radio"
                                            name={`type-${q.id}`}
                                            checked={q.type === 'single'}
                                            onChange={() => updateQuestion(q.id, { type: 'single', correctOptionIds: [] })}
                                        />
                                        Single Choice
                                    </label>
                                    <label className="flex items-center gap-2 cursor-pointer">
                                        <input
                                            type="radio"
                                            name={`type-${q.id}`}
                                            checked={q.type === 'multiple'}
                                            onChange={() => updateQuestion(q.id, { type: 'multiple', correctOptionIds: [] })}
                                        />
                                        Multiple Choice
                                    </label>
                                </div>
                            </div>
                        </div>

                        {/* Options */}
                        <div className="pl-10 space-y-2">
                            {q.options.map((opt) => (
                                <div key={opt.id} className="flex items-center gap-3">
                                    <button
                                        onClick={() => toggleCorrectOption(q.id, opt.id, q.type)}
                                        className={`p-1 rounded-full border ${q.correctOptionIds.includes(opt.id) ? 'bg-green-500 border-green-500 text-white' : 'border-muted-foreground text-transparent hover:border-green-500'}`}
                                    >
                                        <CheckCircle className="w-4 h-4" />
                                    </button>
                                    <input
                                        value={opt.text}
                                        onChange={(e) => updateOptionText(q.id, opt.id, e.target.value)}
                                        placeholder="Option text..."
                                        className="flex-1 bg-muted/30 px-3 py-2 rounded-md border border-transparent focus:border-primary focus:outline-none text-sm"
                                    />
                                    <button onClick={() => removeOption(q.id, opt.id)} className="text-muted-foreground hover:text-destructive">
                                        <Trash2 className="w-4 h-4" />
                                    </button>
                                </div>
                            ))}
                            <button onClick={() => addOption(q.id)} className="text-sm text-primary hover:underline flex items-center gap-1 mt-2">
                                <Plus className="w-3 h-3" /> Add Option
                            </button>
                        </div>
                    </div>
                ))}

                <button
                    onClick={addQuestion}
                    className="w-full py-8 border-2 border-dashed border-border rounded-xl text-muted-foreground hover:border-primary/50 hover:text-primary transition-colors flex flex-col items-center justify-center gap-2"
                >
                    <Plus className="w-8 h-8" />
                    <span className="font-medium">Add New Question</span>
                </button>
            </div>
        </div>
    );
}
