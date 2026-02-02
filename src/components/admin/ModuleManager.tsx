'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Plus, GripVertical, Pencil, Trash2, ChevronDown, ChevronRight } from 'lucide-react';
import LessonManager from './LessonManager';
import { useTranslations } from 'next-intl';

interface Module {
    id: string;
    title: string;
    description: string | null;
    order_index: number;
    lessons?: Lesson[];
}

interface Lesson {
    id: string;
    module_id: string;
    title: string;
    description: string | null;
    order_index: number;
    duration_minutes: number | null;
}

export default function ModuleManager({ courseId }: { courseId: string }) {
    const t = useTranslations('CourseEditor');
    const [modules, setModules] = useState<Module[]>([]);
    const [expandedModules, setExpandedModules] = useState<Set<string>>(new Set());
    const [isLoading, setIsLoading] = useState(true);
    const [editingModule, setEditingModule] = useState<string | null>(null);
    const [newModuleTitle, setNewModuleTitle] = useState('');
    const [draggedModule, setDraggedModule] = useState<string | null>(null);
    const supabase = createClient();

    // Auto-fetch modules on mount
    useEffect(() => {
        fetchModules();
    }, [courseId]);

    const reorderModules = async (newOrder: Module[]) => {
        setModules(newOrder);

        // Update order_index in database
        try {
            const updates = newOrder.map((module, index) =>
                supabase
                    .from('course_modules')
                    .update({ order_index: index })
                    .eq('id', module.id)
            );
            await Promise.all(updates);
        } catch (error: any) {
            console.error('Error reordering modules:', error);
        }
    };

    const handleDragStart = (moduleId: string) => {
        setDraggedModule(moduleId);
    };

    const handleDragOver = (e: React.DragEvent, targetModuleId: string) => {
        e.preventDefault();
        if (!draggedModule || draggedModule === targetModuleId) return;

        const draggedIdx = modules.findIndex(m => m.id === draggedModule);
        const targetIdx = modules.findIndex(m => m.id === targetModuleId);

        if (draggedIdx === -1 || targetIdx === -1) return;

        const newModules = [...modules];
        const [removed] = newModules.splice(draggedIdx, 1);
        newModules.splice(targetIdx, 0, removed);

        reorderModules(newModules);
    };

    const handleDragEnd = () => {
        setDraggedModule(null);
    };

    const fetchModules = async () => {
        setIsLoading(true);
        try {
            const { data: modulesData } = await supabase
                .from('course_modules')
                .select(`
                    *,
                    lessons (*)
                `)
                .eq('course_id', courseId)
                .order('order_index');

            if (modulesData) {
                setModules(modulesData as Module[]);
            }
        } finally {
            setIsLoading(false);
        }
    };

    const addModule = async () => {
        if (!newModuleTitle.trim()) return;

        setIsLoading(true);
        try {
            const { data, error } = await supabase
                .from('course_modules')
                .insert({
                    course_id: courseId,
                    title: newModuleTitle,
                    order_index: modules.length
                })
                .select()
                .single();

            if (error) throw error;

            setModules([...modules, data as Module]);
            setNewModuleTitle('');
        } catch (error: any) {
            alert('Error creating module: ' + error.message);
        } finally {
            setIsLoading(false);
        }
    };

    const updateModule = async (moduleId: string, updates: Partial<Module>) => {
        try {
            const { error } = await supabase
                .from('course_modules')
                .update(updates)
                .eq('id', moduleId);

            if (error) throw error;

            setModules(modules.map(m =>
                m.id === moduleId ? { ...m, ...updates } : m
            ));
        } catch (error: any) {
            alert('Error updating module: ' + error.message);
        }
    };

    const deleteModule = async (moduleId: string, title: string) => {
        if (!confirm(t('modules.delete_confirm', { title }))) {
            return;
        }

        try {
            const { error } = await supabase
                .from('course_modules')
                .delete()
                .eq('id', moduleId);

            if (error) throw error;

            setModules(modules.filter(m => m.id !== moduleId));
        } catch (error: any) {
            alert('Error deleting module: ' + error.message);
        }
    };

    const toggleModule = (moduleId: string) => {
        const newExpanded = new Set(expandedModules);
        if (newExpanded.has(moduleId)) {
            newExpanded.delete(moduleId);
        } else {
            newExpanded.add(moduleId);
        }
        setExpandedModules(newExpanded);
    };

    return (
        <div className="space-y-4">
            <div className="flex items-center justify-between">
                <h3 className="text-lg font-semibold">{t('modules.title')}</h3>
                <button
                    onClick={fetchModules}
                    className="text-sm text-primary hover:underline"
                >
                    {t('modules.refresh')}
                </button>
            </div>

            {/* Add New Module */}
            <div className="flex gap-2">
                <input
                    type="text"
                    value={newModuleTitle}
                    onChange={(e) => setNewModuleTitle(e.target.value)}
                    onKeyPress={(e) => e.key === 'Enter' && addModule()}
                    placeholder={t('modules.new_placeholder')}
                    className="flex-1 px-4 py-2 rounded-lg border border-border bg-background focus:border-primary focus:outline-none"
                />
                <button
                    onClick={addModule}
                    disabled={isLoading || !newModuleTitle.trim()}
                    className="px-4 py-2 bg-primary text-primary-foreground rounded-lg font-medium hover:bg-primary/90 disabled:opacity-50 flex items-center gap-2"
                >
                    <Plus className="w-4 h-4" />
                    {t('modules.add_btn')}
                </button>
            </div>

            {/* Module List */}
            <div className="space-y-2">
                {isLoading ? (
                    <div className="text-center py-8 text-muted-foreground">
                        <p>Laster moduler...</p>
                    </div>
                ) : modules.length === 0 ? (
                    <div className="text-center py-8 text-muted-foreground">
                        <p>{t('modules.empty')}</p>
                    </div>
                ) : (
                    modules.map((module, index) => (
                        <div
                            key={module.id}
                            draggable
                            onDragStart={() => handleDragStart(module.id)}
                            onDragOver={(e) => handleDragOver(e, module.id)}
                            onDragEnd={handleDragEnd}
                            className={`glass rounded-lg border overflow-hidden transition-all ${draggedModule === module.id
                                ? 'border-primary opacity-50'
                                : 'border-white/10'
                                }`}
                        >
                            {/* Module Header */}
                            <div className="flex items-center gap-3 p-4 hover:bg-muted/30 transition-colors">
                                <button
                                    onClick={() => toggleModule(module.id)}
                                    className="p-1 hover:bg-muted rounded"
                                >
                                    {expandedModules.has(module.id) ? (
                                        <ChevronDown className="w-4 h-4" />
                                    ) : (
                                        <ChevronRight className="w-4 h-4" />
                                    )}
                                </button>

                                <GripVertical className="w-4 h-4 text-muted-foreground cursor-grab active:cursor-grabbing" />

                                <div className="flex-1">
                                    {editingModule === module.id ? (
                                        <input
                                            type="text"
                                            value={module.title}
                                            onChange={(e) => updateModule(module.id, { title: e.target.value })}
                                            onBlur={() => setEditingModule(null)}
                                            onKeyPress={(e) => e.key === 'Enter' && setEditingModule(null)}
                                            className="w-full px-2 py-1 bg-background border border-primary rounded"
                                            autoFocus
                                        />
                                    ) : (
                                        <div>
                                            <h4 className="font-medium">
                                                {index + 1}. {module.title}
                                            </h4>
                                            <p className="text-xs text-muted-foreground">
                                                {module.lessons?.length || 0} lessons
                                            </p>
                                        </div>
                                    )}
                                </div>

                                <div className="flex items-center gap-1">
                                    <button
                                        onClick={() => setEditingModule(module.id)}
                                        className="p-2 hover:bg-muted rounded-md transition-colors"
                                        title={t('modules.tooltips.edit')}
                                    >
                                        <Pencil className="w-4 h-4 text-muted-foreground" />
                                    </button>
                                    <button
                                        onClick={() => deleteModule(module.id, module.title)}
                                        className="p-2 hover:bg-destructive/10 rounded-md transition-colors"
                                        title={t('modules.tooltips.delete')}
                                    >
                                        <Trash2 className="w-4 h-4 text-muted-foreground hover:text-destructive" />
                                    </button>
                                </div>
                            </div>

                            {/* Lessons (shown when expanded) */}
                            {expandedModules.has(module.id) && (
                                <div className="border-t border-border bg-muted/5 p-4">
                                    <LessonManager moduleId={module.id} />
                                </div>
                            )}
                        </div>
                    ))
                )}
            </div>
        </div>
    );
}
