'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import ReactMarkdown from 'react-markdown';
import { Clock, CheckCircle } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { showToast } from '@/lib/toast';

interface LessonContentProps {
    lesson: {
        id: string;
        title: string;
        description: string | null;
        duration_minutes: number | null;
    };
}

export function LessonContent({ lesson }: LessonContentProps) {
    const t = useTranslations('Lesson');
    const [contentBlocks, setContentBlocks] = useState<any[]>([]);
    const [isCompleted, setIsCompleted] = useState(false);
    const [isLoading, setIsLoading] = useState(true);
    const supabase = createClient();

    useEffect(() => {
        fetchContentBlocks();
        checkCompletion();
    }, [lesson.id]);

    const fetchContentBlocks = async () => {
        const { data } = await supabase
            .from('content_blocks')
            .select('*')
            .eq('lesson_id', lesson.id)
            .order('order_index');

        if (data) setContentBlocks(data);
        setIsLoading(false);
    };

    const checkCompletion = async () => {
        const { data: user } = await supabase.auth.getUser();
        if (!user.user) return;

        const { data } = await supabase
            .from('lesson_completion')
            .select('id')
            .eq('lesson_id', lesson.id)
            .eq('user_id', user.user.id)
            .single();

        setIsCompleted(!!data);
    };

    const markAsComplete = async () => {
        const { data: user } = await supabase.auth.getUser();
        if (!user.user) return;

        const { error } = await supabase
            .from('lesson_completion')
            .insert({
                lesson_id: lesson.id,
                user_id: user.user.id,
            });

        if (!error) {
            setIsCompleted(true);
            showToast.success(t('marked_complete'));
        } else {
            showToast.error(t('error_marking_complete'));
        }
    };

    return (
        <div className="glass rounded-xl p-8 space-y-6">
            {/* Header */}
            <div className="space-y-2">
                <h1 className="text-3xl font-bold">{lesson.title}</h1>
                {lesson.description && (
                    <p className="text-muted-foreground">{lesson.description}</p>
                )}
                <div className="flex items-center gap-4 text-sm text-muted-foreground">
                    {lesson.duration_minutes && (
                        <div className="flex items-center gap-1">
                            <Clock className="w-4 h-4" />
                            <span>{lesson.duration_minutes} min</span>
                        </div>
                    )}
                    {isCompleted && (
                        <div className="flex items-center gap-1 text-green-600">
                            <CheckCircle className="w-4 h-4" />
                            <span>{t('completed')}</span>
                        </div>
                    )}
                </div>
            </div>

            {/* Content Blocks */}
            {isLoading ? (
                <div className="space-y-4">
                    <div className="h-4 bg-muted rounded animate-pulse"></div>
                    <div className="h-4 bg-muted rounded animate-pulse"></div>
                    <div className="h-4 bg-muted rounded w-5/6 animate-pulse"></div>
                </div>
            ) : (
                <div className="prose prose-invert max-w-none">
                    {contentBlocks.map((block) => (
                        <div key={block.id} className="mb-6">
                            {block.type === 'text' && (
                                <ReactMarkdown>{block.content}</ReactMarkdown>
                            )}
                            {block.type === 'video' && (
                                <div className="aspect-video rounded-lg overflow-hidden bg-muted">
                                    <iframe
                                        src={block.content}
                                        className="w-full h-full"
                                        allowFullScreen
                                        title={block.title || 'Video'}
                                    />
                                </div>
                            )}
                            {block.type === 'image' && (
                                <img
                                    src={block.content}
                                    alt={block.title || ''}
                                    className="rounded-lg w-full"
                                />
                            )}
                        </div>
                    ))}
                </div>
            )}

            {/* Mark as Complete */}
            {!isCompleted && (
                <button
                    onClick={markAsComplete}
                    className="w-full px-6 py-3 bg-primary text-primary-foreground rounded-lg font-medium hover:bg-primary/90 transition-colors flex items-center justify-center gap-2"
                >
                    <CheckCircle className="w-5 h-5" />
                    {t('mark_complete')}
                </button>
            )}
        </div>
    );
}
