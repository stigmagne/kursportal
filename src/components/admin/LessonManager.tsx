'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Plus, Pencil, Trash2, Clock, FileText, Video, HelpCircle, File, ChevronDown, ChevronRight } from 'lucide-react';
import ContentBlockEditor from './ContentBlockEditor';
import PrerequisiteEditor from './PrerequisiteEditor';
import QuizBuilder from './QuizBuilder';
import { useTranslations } from 'next-intl';

interface Lesson {
    id: string;
    module_id: string;
    title: string;
    description: string | null;
    order_index: number;
    duration_minutes: number | null;
}

export default function LessonManager({ moduleId }: { moduleId: string }) {
    const t = useTranslations('CourseEditor');
    const [lessons, setLessons] = useState<Lesson[]>([]);
    const [expandedLessons, setExpandedLessons] = useState<Set<string>>(new Set());
    const [isLoading, setIsLoading] = useState(false);
    const [newLessonTitle, setNewLessonTitle] = useState('');
    const [editingLesson, setEditingLesson] = useState<string | null>(null);
    const [draggedLesson, setDraggedLesson] = useState<string | null>(null);
    const supabase = createClient();

    const reorderLessons = async (newOrder: Lesson[]) => {
        setLessons(newOrder);

        // Update order_index in database
        try {
            const updates = newOrder.map((lesson, index) =>
                supabase
                    .from('lessons')
                    .update({ order_index: index })
                    .eq('id', lesson.id)
            );
            await Promise.all(updates);
        } catch (error: any) {
            console.error('Error reordering lessons:', error);
        }
    };

    const handleDragStart = (lessonId: string) => {
        setDraggedLesson(lessonId);
    };

    const handleDragOver = (e: React.DragEvent, targetLessonId: string) => {
        e.preventDefault();
        if (!draggedLesson || draggedLesson === targetLessonId) return;

        const draggedIdx = lessons.findIndex(l => l.id === draggedLesson);
        const targetIdx = lessons.findIndex(l => l.id === targetLessonId);

        if (draggedIdx === -1 || targetIdx === -1) return;

        const newLessons = [...lessons];
        const [removed] = newLessons.splice(draggedIdx, 1);
        newLessons.splice(targetIdx, 0, removed);

        reorderLessons(newLessons);
    };

    const handleDragEnd = () => {
        setDraggedLesson(null);
    };

    useEffect(() => {
        fetchLessons();
    }, [moduleId]);

    const fetchLessons = async () => {
        const { data } = await supabase
            .from('lessons')
            .select('*')
            .eq('module_id', moduleId)
            .order('order_index');

        if (data) {
            setLessons(data);
        }
    };

    const addLesson = async () => {
        if (!newLessonTitle.trim()) return;

        setIsLoading(true);
        try {
            const { data, error } = await supabase
                .from('lessons')
                .insert({
                    module_id: moduleId,
                    title: newLessonTitle,
                    order_index: lessons.length
                })
                .select()
                .single();

            if (error) throw error;

            setLessons([...lessons, data]);
            setNewLessonTitle('');
        } catch (error: any) {
            alert('Error creating lesson: ' + error.message);
        } finally {
            setIsLoading(false);
        }
    };

    const updateLesson = async (lessonId: string, updates: Partial<Lesson>) => {
        try {
            const { error } = await supabase
                .from('lessons')
                .update(updates)
                .eq('id', lessonId);

            if (error) throw error;

            setLessons(lessons.map(l =>
                l.id === lessonId ? { ...l, ...updates } : l
            ));
        } catch (error: any) {
            alert('Error updating lesson: ' + error.message);
        }
    };

    const deleteLesson = async (lessonId: string, title: string) => {
        if (!confirm(t('lessons.delete_confirm', { title }))) {
            return;
        }

        try {
            const { error } = await supabase
                .from('lessons')
                .delete()
                .eq('id', lessonId);

            if (error) throw error;

            setLessons(lessons.filter(l => l.id !== lessonId));
        } catch (error: any) {
            alert('Error deleting lesson: ' + error.message);
        }
    };

    return (
        <div className="space-y-3 pl-8">
            {/* Add New Lesson */}
            <div className="flex gap-2">
                <input
                    type="text"
                    value={newLessonTitle}
                    onChange={(e) => setNewLessonTitle(e.target.value)}
                    onKeyPress={(e) => e.key === 'Enter' && addLesson()}
                    placeholder={t('lessons.new_placeholder')}
                    className="flex-1 px-3 py-2 text-sm rounded-md border border-border bg-background focus:border-primary focus:outline-none"
                />
                <button
                    onClick={addLesson}
                    disabled={isLoading || !newLessonTitle.trim()}
                    className="px-3 py-2 bg-primary/20 text-primary rounded-md text-sm font-medium hover:bg-primary/30 disabled:opacity-50 flex items-center gap-2"
                >
                    <Plus className="w-3 h-3" />
                    {t('lessons.add_btn')}
                </button>
            </div>

            {/* Lesson List */}
            {lessons.length === 0 ? (
                <div className="text-center py-4 text-sm text-muted-foreground">
                    {t('lessons.empty')}
                </div>
            ) : (
                <div className="space-y-2">
                    {lessons.map((lesson, index) => {
                        const isExpanded = expandedLessons.has(lesson.id);
                        const toggleLesson = () => {
                            const newExpanded = new Set(expandedLessons);
                            if (newExpanded.has(lesson.id)) {
                                newExpanded.delete(lesson.id);
                            } else {
                                newExpanded.add(lesson.id);
                            }
                            setExpandedLessons(newExpanded);
                        };

                        return (
                            <div
                                key={lesson.id}
                                draggable
                                onDragStart={() => handleDragStart(lesson.id)}
                                onDragOver={(e) => handleDragOver(e, lesson.id)}
                                onDragEnd={handleDragEnd}
                                className={`rounded-lg border overflow-hidden transition-all ${draggedLesson === lesson.id
                                    ? 'border-primary opacity-50'
                                    : 'border-border bg-background/50'
                                    }`}
                            >
                                {/* Lesson Header */}
                                <div className="flex items-center gap-3 p-3 hover:bg-muted/30 transition-colors">
                                    {/* Expand Toggle */}
                                    <button
                                        onClick={toggleLesson}
                                        className="p-1 hover:bg-muted rounded"
                                    >
                                        {isExpanded ? (
                                            <ChevronDown className="w-3.5 h-3.5" />
                                        ) : (
                                            <ChevronRight className="w-3.5 h-3.5" />
                                        )}
                                    </button>

                                    {/* Drag Handle */}
                                    <div className="cursor-grab active:cursor-grabbing">
                                        <div className="w-1 h-4 bg-muted-foreground/30 rounded-full" />
                                    </div>

                                    {/* Lesson Icon */}
                                    <div className="p-1.5 rounded bg-primary/10 text-primary">
                                        <FileText className="w-3.5 h-3.5" />
                                    </div>

                                    {/* Lesson Info */}
                                    <div className="flex-1 min-w-0">
                                        {editingLesson === lesson.id ? (
                                            <input
                                                type="text"
                                                value={lesson.title}
                                                onChange={(e) => updateLesson(lesson.id, { title: e.target.value })}
                                                onBlur={() => setEditingLesson(null)}
                                                onKeyPress={(e) => e.key === 'Enter' && setEditingLesson(null)}
                                                className="w-full px-2 py-1 text-sm bg-background border border-primary rounded"
                                                autoFocus
                                            />
                                        ) : (
                                            <div>
                                                <h5 className="text-sm font-medium truncate">
                                                    {index + 1}. {lesson.title}
                                                </h5>
                                                {lesson.duration_minutes && (
                                                    <div className="flex items-center gap-1 text-xs text-muted-foreground mt-0.5">
                                                        <Clock className="w-3 h-3" />
                                                        {t('lessons.duration', { minutes: lesson.duration_minutes })}
                                                    </div>
                                                )}
                                            </div>
                                        )}
                                    </div>

                                    {/* Actions */}
                                    <div className="flex items-center gap-1">
                                        <button
                                            onClick={() => setEditingLesson(lesson.id)}
                                            className="p-1.5 hover:bg-muted rounded transition-colors"
                                            title={t('lessons.tooltips.edit')}
                                        >
                                            <Pencil className="w-3.5 h-3.5 text-muted-foreground" />
                                        </button>
                                        <button
                                            onClick={() => deleteLesson(lesson.id, lesson.title)}
                                            className="p-1.5 hover:bg-destructive/10 rounded transition-colors"
                                            title={t('lessons.tooltips.delete')}
                                        >
                                            <Trash2 className="w-3.5 h-3.5 text-muted-foreground hover:text-destructive" />
                                        </button>
                                    </div>
                                </div>

                                {/* Content Blocks (shown when expanded) */}
                                {isExpanded && (
                                    <div className="border-t border-border px-3 pb-3 bg-muted/5 space-y-4">
                                        <ContentBlockEditor lessonId={lesson.id} />
                                        <PrerequisiteEditor lessonId={lesson.id} moduleId={moduleId} />

                                        {/* Quiz Section */}
                                        <div className="mt-6 pt-6 border-t border-border">
                                            <h4 className="text-sm font-semibold mb-4 text-primary">{t('lessons.quiz_title')}</h4>
                                            <QuizBuilder lessonId={lesson.id} />
                                        </div>
                                    </div>
                                )}
                            </div>
                        );
                    })}
                </div>
            )}
        </div>
    );
}
