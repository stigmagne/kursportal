'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Lock, Calendar, X } from 'lucide-react';

interface Lesson {
    id: string;
    title: string;
    module_id: string;
}

interface PrerequisiteEditorProps {
    lessonId: string;
    moduleId: string;
}

export default function PrerequisiteEditor({ lessonId, moduleId }: PrerequisiteEditorProps) {
    const [allLessons, setAllLessons] = useState<Lesson[]>([]);
    const [prerequisites, setPrerequisites] = useState<string[]>([]);
    const [dripSchedule, setDripSchedule] = useState<any>(null);
    const supabase = createClient();

    useEffect(() => {
        fetchData();
    }, [lessonId, moduleId]);

    const fetchData = async () => {
        // Fetch all lessons in the same module
        const { data: lessons } = await supabase
            .from('lessons')
            .select('id, title, module_id')
            .eq('module_id', moduleId)
            .neq('id', lessonId)
            .order('order_index');

        if (lessons) setAllLessons(lessons);

        // Fetch existing prerequisites
        const { data: prereqs } = await supabase
            .from('lesson_prerequisites')
            .select('prerequisite_lesson_id')
            .eq('lesson_id', lessonId);

        if (prereqs) {
            setPrerequisites(prereqs.map(p => p.prerequisite_lesson_id));
        }

        // Fetch drip schedule
        const { data: drip } = await supabase
            .from('drip_schedules')
            .select('*')
            .eq('lesson_id', lessonId)
            .single();

        if (drip) setDripSchedule(drip);
    };

    const togglePrerequisite = async (prerequisiteId: string) => {
        const isCurrentlyRequired = prerequisites.includes(prerequisiteId);

        if (isCurrentlyRequired) {
            // Remove prerequisite
            await supabase
                .from('lesson_prerequisites')
                .delete()
                .eq('lesson_id', lessonId)
                .eq('prerequisite_lesson_id', prerequisiteId);

            setPrerequisites(prerequisites.filter(p => p !== prerequisiteId));
        } else {
            // Add prerequisite
            await supabase
                .from('lesson_prerequisites')
                .insert({
                    lesson_id: lessonId,
                    prerequisite_lesson_id: prerequisiteId
                });

            setPrerequisites([...prerequisites, prerequisiteId]);
        }
    };

    const saveDripSchedule = async (type: 'days_after_enrollment' | 'specific_date', value: string) => {
        // Delete existing schedule
        await supabase
            .from('drip_schedules')
            .delete()
            .eq('lesson_id', lessonId);

        if (!value) {
            setDripSchedule(null);
            return;
        }

        // Create new schedule
        const schedule = {
            lesson_id: lessonId,
            type,
            [type === 'days_after_enrollment' ? 'days_after_enrollment' : 'unlock_date']:
                type === 'days_after_enrollment' ? parseInt(value) : value
        };

        const { data, error } = await supabase
            .from('drip_schedules')
            .insert(schedule)
            .select()
            .single();

        if (!error && data) {
            setDripSchedule(data);
        }
    };

    return (
        <div className="space-y-4 mt-4 p-3 border border-border rounded-lg bg-muted/5">
            {/* Prerequisites Section */}
            <div>
                <div className="flex items-center gap-2 mb-2">
                    <Lock className="w-4 h-4 text-muted-foreground" />
                    <h6 className="text-sm font-medium">Prerequisites</h6>
                </div>
                <p className="text-xs text-muted-foreground mb-3">
                    Require users to complete these lessons first
                </p>

                {allLessons.length === 0 ? (
                    <p className="text-xs text-muted-foreground italic">
                        No other lessons in this module
                    </p>
                ) : (
                    <div className="space-y-1">
                        {allLessons.map((lesson) => (
                            <label
                                key={lesson.id}
                                className="flex items-center gap-2 p-2 hover:bg-muted/50 rounded cursor-pointer text-xs"
                            >
                                <input
                                    type="checkbox"
                                    checked={prerequisites.includes(lesson.id)}
                                    onChange={() => togglePrerequisite(lesson.id)}
                                    className="rounded"
                                />
                                <span>{lesson.title}</span>
                            </label>
                        ))}
                    </div>
                )}
            </div>

            {/* Drip Schedule Section */}
            <div className="border-t border-border pt-4">
                <div className="flex items-center gap-2 mb-2">
                    <Calendar className="w-4 h-4 text-muted-foreground" />
                    <h6 className="text-sm font-medium">Drip Schedule</h6>
                </div>
                <p className="text-xs text-muted-foreground mb-3">
                    Control when this lesson becomes available
                </p>

                <div className="space-y-2">
                    {/* Days After Enrollment */}
                    <div>
                        <label className="flex items-center gap-2 text-xs mb-1">
                            <input
                                type="radio"
                                name="dripType"
                                checked={dripSchedule?.type === 'days_after_enrollment'}
                                onChange={() => { }}
                            />
                            Unlock X days after enrollment
                        </label>
                        {dripSchedule?.type === 'days_after_enrollment' && (
                            <div className="flex items-center gap-2 ml-5">
                                <input
                                    type="number"
                                    min="0"
                                    value={dripSchedule.days_after_enrollment || 0}
                                    onChange={(e) => saveDripSchedule('days_after_enrollment', e.target.value)}
                                    className="w-20 px-2 py-1 text-xs border border-border rounded bg-background"
                                />
                                <span className="text-xs text-muted-foreground">days</span>
                                <button
                                    onClick={() => saveDripSchedule('days_after_enrollment', '')}
                                    className="text-muted-foreground hover:text-destructive"
                                >
                                    <X className="w-3 h-3" />
                                </button>
                            </div>
                        )}
                        {!dripSchedule && (
                            <button
                                onClick={() => saveDripSchedule('days_after_enrollment', '7')}
                                className="ml-5 text-xs text-primary hover:underline"
                            >
                                Set days
                            </button>
                        )}
                    </div>

                    {/* Specific Date */}
                    <div>
                        <label className="flex items-center gap-2 text-xs mb-1">
                            <input
                                type="radio"
                                name="dripType"
                                checked={dripSchedule?.type === 'specific_date'}
                                onChange={() => { }}
                            />
                            Unlock on specific date
                        </label>
                        {dripSchedule?.type === 'specific_date' && (
                            <div className="flex items-center gap-2 ml-5">
                                <input
                                    type="datetime-local"
                                    value={dripSchedule.unlock_date ? new Date(dripSchedule.unlock_date).toISOString().slice(0, 16) : ''}
                                    onChange={(e) => saveDripSchedule('specific_date', e.target.value)}
                                    className="px-2 py-1 text-xs border border-border rounded bg-background"
                                />
                                <button
                                    onClick={() => saveDripSchedule('specific_date', '')}
                                    className="text-muted-foreground hover:text-destructive"
                                >
                                    <X className="w-3 h-3" />
                                </button>
                            </div>
                        )}
                        {!dripSchedule && (
                            <button
                                onClick={() => {
                                    const nextWeek = new Date();
                                    nextWeek.setDate(nextWeek.getDate() + 7);
                                    saveDripSchedule('specific_date', nextWeek.toISOString());
                                }}
                                className="ml-5 text-xs text-primary hover:underline"
                            >
                                Set date
                            </button>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
