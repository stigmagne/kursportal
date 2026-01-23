'use client';

import { useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { useRouter } from 'next/navigation';
import { Link } from '@/i18n/routing';
import { Edit, Trash, Archive, Pause, Play, Eye, EyeOff } from 'lucide-react';
import ConfirmDialog from '@/components/ConfirmDialog';
import { useTranslations } from 'next-intl';

type CourseStatus = 'active' | 'paused' | 'archived' | 'legacy';

export default function CourseList({ initialCourses }: { initialCourses: any[] }) {
    const t = useTranslations('AdminCourses');
    const [courses, setCourses] = useState(initialCourses);
    const [confirmDialog, setConfirmDialog] = useState<{
        isOpen: boolean;
        title: string;
        message: string;
        onConfirm: () => void;
    }>({ isOpen: false, title: '', message: '', onConfirm: () => { } });
    const supabase = createClient();
    const router = useRouter();

    const handleDelete = async (id: string, title: string) => {
        try {
            // Check if course has any user progress
            const { data: progress, error: progressError } = await supabase
                .from('user_progress')
                .select('id')
                .eq('course_id', id)
                .limit(1);

            if (progressError) throw progressError;

            if (progress && progress.length > 0) {
                // Course has user data - show warning
                // Note: Using hardcoded explanation for safety reasons logic not fully translated yet in message format or just use the new keys
                // For now, I'll direct map to the new keys which cover this logic relatively well
                setConfirmDialog({
                    isOpen: true,
                    title: t('delete_blocked.title'),
                    message: t('delete_blocked.message', { title }),
                    onConfirm: () => setConfirmDialog({ ...confirmDialog, isOpen: false })
                });
                return;
            }

            // Course has no data - confirm deletion
            setConfirmDialog({
                isOpen: true,
                title: t('delete_confirm.title'),
                message: t('delete_confirm.message', { title }),
                onConfirm: async () => {
                    setConfirmDialog({ ...confirmDialog, isOpen: false });

                    const { error } = await supabase
                        .from('courses')
                        .delete()
                        .eq('id', id);

                    if (error) throw error;

                    setCourses(courses.filter(c => c.id !== id));
                }
            });
        } catch (error: any) {
            alert('Error: ' + error.message);
        }
    };

    const handleStatusChange = async (id: string, newStatus: CourseStatus) => {
        try {
            const { error } = await supabase
                .from('courses')
                .update({ status: newStatus })
                .eq('id', id);

            if (error) throw error;

            // Update local state
            setCourses(courses.map(c =>
                c.id === id ? { ...c, status: newStatus } : c
            ));
        } catch (error: any) {
            alert('Error updating status: ' + error.message);
        }
    };

    const getStatusBadge = (course: any) => {
        const status = course.status || 'active';
        const published = course.published;

        if (status === 'archived') {
            return (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-400">
                    {t('status.archived')}
                </span>
            );
        }
        if (status === 'paused') {
            return (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-400">
                    {t('status.paused')}
                </span>
            );
        }
        return (
            <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${published
                ? 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400'
                : 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400'
                }`}>
                {published ? t('status.published') : t('status.draft')}
            </span>
        );
    };

    return (
        <>
            <div className="glass rounded-xl border border-white/10 overflow-hidden">
                <table className="w-full text-sm text-left">
                    <thead className="text-xs uppercase bg-muted/50 text-muted-foreground">
                        <tr>
                            <th className="px-6 py-4 font-medium">{t('table.title')}</th>
                            <th className="px-6 py-4 font-medium">{t('table.status')}</th>
                            <th className="px-6 py-4 font-medium">{t('table.created')}</th>
                            <th className="px-6 py-4 text-right">{t('table.actions')}</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-border">
                        {courses.map((course) => {
                            const status = course.status || 'active';
                            const isArchived = status === 'archived';
                            const isPaused = status === 'paused';
                            const hasStatusField = 'status' in course; // Check if migration is run

                            return (
                                <tr key={course.id} className="hover:bg-muted/30 transition-colors">
                                    <td className="px-6 py-4 font-medium">
                                        {course.title}
                                        {isArchived && <span className="text-xs text-muted-foreground ml-2">({t('status.read_only')})</span>}
                                    </td>
                                    <td className="px-6 py-4">
                                        {getStatusBadge(course)}
                                    </td>
                                    <td className="px-6 py-4 text-muted-foreground">
                                        {new Date(course.created_at).toISOString().split('T')[0]}
                                    </td>
                                    <td className="px-6 py-4 text-right">
                                        <div className="flex items-center justify-end gap-2">
                                            {/* Preview as Student */}
                                            <Link
                                                href={`/courses/${course.id}`}
                                                className="p-2 hover:bg-muted rounded-md transition-colors group"
                                                title={t('actions.view')}
                                                target="_blank"
                                            >
                                                <Eye className="w-4 h-4 text-muted-foreground group-hover:text-primary" />
                                            </Link>

                                            <Link
                                                href={`/admin/courses/edit/${course.id}`}
                                                className="p-2 hover:bg-muted rounded-md transition-colors"
                                                title={t('actions.edit')}
                                            >
                                                <Edit className="w-4 h-4 text-muted-foreground" />
                                            </Link>

                                            {/* Pause/Resume toggle - only if migration run */}
                                            {hasStatusField && !isArchived && (
                                                <button
                                                    onClick={() => handleStatusChange(course.id, isPaused ? 'active' : 'paused')}
                                                    className="p-2 hover:bg-muted rounded-md transition-colors group"
                                                    title={isPaused ? t('actions.resume') : t('actions.pause')}
                                                >
                                                    {isPaused ? (
                                                        <Play className="w-4 h-4 text-muted-foreground group-hover:text-green-500" />
                                                    ) : (
                                                        <Pause className="w-4 h-4 text-muted-foreground group-hover:text-orange-500" />
                                                    )}
                                                </button>
                                            )}

                                            {/* Archive button - only if migration run */}
                                            {hasStatusField && !isArchived && (
                                                <button
                                                    onClick={() => {
                                                        if (confirm(t('archive_confirm', { title: course.title }))) {
                                                            handleStatusChange(course.id, 'archived');
                                                        }
                                                    }}
                                                    className="p-2 hover:bg-muted rounded-md transition-colors group"
                                                    title={t('actions.archive')}
                                                >
                                                    <Archive className="w-4 h-4 text-muted-foreground group-hover:text-blue-500" />
                                                </button>
                                            )}

                                            {/* Delete button */}
                                            <button
                                                onClick={() => handleDelete(course.id, course.title)}
                                                className="p-2 hover:bg-destructive/10 rounded-md transition-colors group"
                                                title={isArchived ? 'Cannot delete archived course' : t('actions.delete')}
                                                disabled={isArchived}
                                            >
                                                <Trash className={`w-4 h-4 ${isArchived ? 'text-muted-foreground/50' : 'text-muted-foreground group-hover:text-destructive'}`} />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            );
                        })}
                        {courses.length === 0 && (
                            <tr>
                                <td colSpan={4} className="px-6 py-8 text-center text-muted-foreground">
                                    {t('empty')}
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            <ConfirmDialog
                isOpen={confirmDialog.isOpen}
                title={confirmDialog.title}
                message={confirmDialog.message}
                onConfirm={confirmDialog.onConfirm}
                onCancel={() => setConfirmDialog({ ...confirmDialog, isOpen: false })}
                variant="danger"
                confirmText={t('delete_confirm.confirm')}
            />
        </>
    );
}
