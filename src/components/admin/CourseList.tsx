'use client';

import { useState, useMemo } from 'react';
import { createClient } from '@/utils/supabase/client';
import { useRouter } from 'next/navigation';
import { Link } from '@/i18n/routing';
import { Edit, Trash, Archive, Pause, Play, Eye, Filter } from 'lucide-react';
import ConfirmDialog from '@/components/ConfirmDialog';
import { useTranslations } from 'next-intl';

type CourseStatus = 'active' | 'paused' | 'archived' | 'legacy';

// Target group labels for display
const TARGET_GROUP_LABELS: Record<string, string> = {
    'sibling': 'Søsken',
    'parent': 'Foreldre',
    'team-member': 'Teammedlem',
    'team-leader': 'Teamleder',
    'construction_worker': 'Håndverker',
    'site_manager': 'Bas/Byggeleder',
};

// Color rotation for groups
const GROUP_COLORS = [
    'bg-blue-100 text-blue-800 border-blue-800 dark:bg-blue-900/30 dark:text-blue-400 dark:border-blue-400',
    'bg-purple-100 text-purple-800 border-purple-800 dark:bg-purple-900/30 dark:text-purple-400 dark:border-purple-400',
    'bg-teal-100 text-teal-800 border-teal-800 dark:bg-teal-900/30 dark:text-teal-400 dark:border-teal-400',
    'bg-amber-100 text-amber-800 border-amber-800 dark:bg-amber-900/30 dark:text-amber-400 dark:border-amber-400',
    'bg-green-100 text-green-800 border-green-800 dark:bg-green-900/30 dark:text-green-400 dark:border-green-400',
    'bg-rose-100 text-rose-800 border-rose-800 dark:bg-rose-900/30 dark:text-rose-400 dark:border-rose-400'
];

interface Course {
    id: string;
    title: string;
    published: boolean;
    status?: CourseStatus;
    created_at: string;
    target_groups?: string[];
}

export default function CourseList({ initialCourses }: { initialCourses: Course[] }) {
    const t = useTranslations('AdminCourses');
    const [courses, setCourses] = useState(initialCourses);
    const [selectedGroup, setSelectedGroup] = useState<string>('all');
    const [confirmDialog, setConfirmDialog] = useState<{
        isOpen: boolean;
        title: string;
        message: string;
        onConfirm: () => void;
    }>({ isOpen: false, title: '', message: '', onConfirm: () => { } });
    const supabase = createClient();
    const router = useRouter();

    // Filter courses by selected group
    const filteredCourses = useMemo(() => {
        if (selectedGroup === 'all') return courses;
        return courses.filter(course =>
            course.target_groups?.includes(selectedGroup)
        );
    }, [courses, selectedGroup]);

    // Get unique groups for filter
    const availableGroups = useMemo(() => {
        const groupSet = new Set<string>();
        courses.forEach(course => {
            course.target_groups?.forEach(group => groupSet.add(group));
        });
        return Array.from(groupSet).map(value => ({
            value,
            label: TARGET_GROUP_LABELS[value] || value
        }));
    }, [courses]);

    // Get color for a group
    const getGroupColor = (groupValue: string) => {
        const allGroupKeys = Object.keys(TARGET_GROUP_LABELS);
        const index = allGroupKeys.indexOf(groupValue);
        return GROUP_COLORS[index >= 0 ? index % GROUP_COLORS.length : 0];
    };

    const handleDelete = async (id: string, title: string) => {
        try {
            const { data: progress, error: progressError } = await supabase
                .from('user_progress')
                .select('id')
                .eq('course_id', id)
                .limit(1);

            if (progressError) throw progressError;

            if (progress && progress.length > 0) {
                setConfirmDialog({
                    isOpen: true,
                    title: t('delete_blocked.title'),
                    message: t('delete_blocked.message', { title }),
                    onConfirm: () => setConfirmDialog({ ...confirmDialog, isOpen: false })
                });
                return;
            }

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
        } catch (error: unknown) {
            const errMsg = error instanceof Error ? error.message : 'Ukjent feil';
            alert('Error: ' + errMsg);
        }
    };

    const handleStatusChange = async (id: string, newStatus: CourseStatus) => {
        try {
            const { error } = await supabase
                .from('courses')
                .update({ status: newStatus })
                .eq('id', id);

            if (error) throw error;

            setCourses(courses.map(c =>
                c.id === id ? { ...c, status: newStatus } : c
            ));
        } catch (error: unknown) {
            const errMsg = error instanceof Error ? error.message : 'Ukjent feil';
            alert('Error updating status: ' + errMsg);
        }
    };

    const getStatusBadge = (course: Course) => {
        const status = course.status || 'active';
        const published = course.published;

        if (status === 'archived') {
            return (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-none border text-xs font-medium bg-gray-100 text-gray-800 border-gray-800 dark:bg-gray-900/30 dark:text-gray-400 dark:border-gray-400">
                    {t('status.archived')}
                </span>
            );
        }
        if (status === 'paused') {
            return (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-none border text-xs font-medium bg-orange-100 text-orange-800 border-orange-800 dark:bg-orange-900/30 dark:text-orange-400 dark:border-orange-400">
                    {t('status.paused')}
                </span>
            );
        }
        return (
            <span className={`inline-flex items-center px-2.5 py-0.5 rounded-none border text-xs font-medium ${published
                ? 'bg-green-100 text-green-800 border-green-800 dark:bg-green-900/30 dark:text-green-400 dark:border-green-400'
                : 'bg-yellow-100 text-yellow-800 border-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-400 dark:border-yellow-400'
                }`}>
                {published ? t('status.published') : t('status.draft')}
            </span>
        );
    };

    const getGroupBadges = (course: Course) => {
        if (!course.target_groups || course.target_groups.length === 0) {
            return (
                <span className="text-xs text-muted-foreground italic">Ingen gruppe</span>
            );
        }
        return (
            <div className="flex flex-wrap gap-1">
                {course.target_groups.map((group, idx) => (
                    <span
                        key={idx}
                        className={`inline-flex items-center px-2 py-0.5 rounded-none border text-xs font-medium ${getGroupColor(group)}`}
                    >
                        {TARGET_GROUP_LABELS[group] || group}
                    </span>
                ))}
            </div>
        );
    };

    return (
        <>
            {/* Filter Bar */}
            <div className="flex items-center gap-3 mb-4">
                <Filter className="w-4 h-4 text-muted-foreground" />
                <div className="flex gap-2 flex-wrap">
                    <button
                        onClick={() => setSelectedGroup('all')}
                        className={`px-3 py-1.5 rounded-none border-2 border-black dark:border-white text-xs font-medium transition-colors ${selectedGroup === 'all'
                            ? 'bg-primary text-primary-foreground'
                            : 'bg-muted hover:bg-muted/80 text-muted-foreground'
                            }`}
                    >
                        Alle ({courses.length})
                    </button>
                    {availableGroups.map(group => {
                        const count = courses.filter(c =>
                            c.target_groups?.includes(group.value)
                        ).length;
                        return (
                            <button
                                key={group.value}
                                onClick={() => setSelectedGroup(group.value)}
                                className={`px-3 py-1.5 rounded-none border-2 border-black dark:border-white text-xs font-medium transition-colors ${selectedGroup === group.value
                                    ? getGroupColor(group.value)
                                    : 'bg-muted hover:bg-muted/80 text-muted-foreground'
                                    }`}
                            >
                                {group.label} ({count})
                            </button>
                        );
                    })}
                </div>
            </div>

            <div className="glass rounded-none border-2 border-black dark:border-white overflow-hidden">
                <table className="w-full text-sm text-left">
                    <thead className="text-xs uppercase bg-muted/50 text-muted-foreground">
                        <tr>
                            <th className="px-6 py-4 font-medium">{t('table.title')}</th>
                            <th className="px-6 py-4 font-medium">Gruppe</th>
                            <th className="px-6 py-4 font-medium">{t('table.status')}</th>
                            <th className="px-6 py-4 font-medium">{t('table.created')}</th>
                            <th className="px-6 py-4 text-right">{t('table.actions')}</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-border">
                        {filteredCourses.map((course) => {
                            const status = course.status || 'active';
                            const isArchived = status === 'archived';
                            const isPaused = status === 'paused';
                            const hasStatusField = 'status' in course;

                            return (
                                <tr key={course.id} className="hover:bg-muted/30 transition-colors">
                                    <td className="px-6 py-4 font-medium">
                                        {course.title}
                                        {isArchived && <span className="text-xs text-muted-foreground ml-2">({t('status.read_only')})</span>}
                                    </td>
                                    <td className="px-6 py-4">
                                        {getGroupBadges(course)}
                                    </td>
                                    <td className="px-6 py-4">
                                        {getStatusBadge(course)}
                                    </td>
                                    <td className="px-6 py-4 text-muted-foreground">
                                        {new Date(course.created_at).toISOString().split('T')[0]}
                                    </td>
                                    <td className="px-6 py-4 text-right">
                                        <div className="flex items-center justify-end gap-2">
                                            <Link
                                                href={`/courses/${course.id}`}
                                                className="p-2 hover:bg-muted rounded-none transition-colors group"
                                                title={t('actions.view')}
                                                target="_blank"
                                            >
                                                <Eye className="w-4 h-4 text-muted-foreground group-hover:text-primary" />
                                            </Link>

                                            <Link
                                                href={`/admin/courses/edit/${course.id}`}
                                                className="p-2 hover:bg-muted rounded-none transition-colors"
                                                title={t('actions.edit')}
                                            >
                                                <Edit className="w-4 h-4 text-muted-foreground" />
                                            </Link>

                                            {hasStatusField && !isArchived && (
                                                <button
                                                    onClick={() => handleStatusChange(course.id, isPaused ? 'active' : 'paused')}
                                                    className="p-2 hover:bg-muted rounded-none transition-colors group"
                                                    title={isPaused ? t('actions.resume') : t('actions.pause')}
                                                >
                                                    {isPaused ? (
                                                        <Play className="w-4 h-4 text-muted-foreground group-hover:text-green-500" />
                                                    ) : (
                                                        <Pause className="w-4 h-4 text-muted-foreground group-hover:text-orange-500" />
                                                    )}
                                                </button>
                                            )}

                                            {hasStatusField && !isArchived && (
                                                <button
                                                    onClick={() => {
                                                        if (confirm(t('archive_confirm', { title: course.title }))) {
                                                            handleStatusChange(course.id, 'archived');
                                                        }
                                                    }}
                                                    className="p-2 hover:bg-muted rounded-none transition-colors group"
                                                    title={t('actions.archive')}
                                                >
                                                    <Archive className="w-4 h-4 text-muted-foreground group-hover:text-blue-500" />
                                                </button>
                                            )}

                                            <button
                                                onClick={() => handleDelete(course.id, course.title)}
                                                className="p-2 hover:bg-destructive/10 rounded-none transition-colors group"
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
                        {filteredCourses.length === 0 && (
                            <tr>
                                <td colSpan={5} className="px-6 py-8 text-center text-muted-foreground">
                                    {selectedGroup === 'all' ? t('empty') : `Ingen kurs for ${TARGET_GROUP_LABELS[selectedGroup] || selectedGroup}`}
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
