'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Trash2, AlertCircle, User } from 'lucide-react';
import ConfirmDialog from '@/components/ConfirmDialog';
import { useTranslations } from 'next-intl';

interface EnrollmentManagerProps {
    courseId: string;
}

interface Enrollment {
    id: string;
    user_id: string;
    status: string;
    created_at: string;
    completed_at: string | null;
    profile: {
        email: string;
        full_name: string | null;
        user_category: string | null;
    };
}

export default function EnrollmentManager({ courseId }: EnrollmentManagerProps) {
    const t = useTranslations('CourseEditor');
    const [enrollments, setEnrollments] = useState<Enrollment[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [allUsers, setAllUsers] = useState<any[]>([]);
    const [showAddUser, setShowAddUser] = useState(false);
    const [selectedUserId, setSelectedUserId] = useState<string>('');
    const [isEnrolling, setIsEnrolling] = useState(false);
    const [confirmDialog, setConfirmDialog] = useState({
        isOpen: false,
        title: '',
        message: '',
        onConfirm: () => { }
    });
    const supabase = createClient();

    useEffect(() => {
        fetchEnrollments();
        fetchAllUsers();
    }, [courseId]);

    const fetchEnrollments = async () => {
        setIsLoading(true);

        const { data, error } = await supabase
            .from('user_progress')
            .select(`
                *,
                profile:profiles!user_progress_user_id_fkey (
                    email,
                    full_name,
                    user_category
                )
            `)
            .eq('course_id', courseId)
            .order('created_at', { ascending: false });

        if (!error && data) {
            setEnrollments(data as any);
        }

        setIsLoading(false);
    };

    const fetchAllUsers = async () => {
        const { data, error } = await supabase
            .from('profiles')
            .select('id, full_name, user_category, role')
            .order('full_name');

        if (!error && data) {
            console.log('All users fetched:', data);
            setAllUsers(data);
        } else {
            console.error('Error fetching users:', {
                error,
                code: error?.code,
                message: error?.message,
                details: error?.details,
                hint: error?.hint
            });
        }
    };

    const handleEnrollUser = async () => {
        if (!selectedUserId) {
            alert('Please select a user');
            return;
        }

        setIsEnrolling(true);

        try {
            const { error } = await supabase
                .from('user_progress')
                .insert({
                    user_id: selectedUserId,
                    course_id: courseId
                });

            if (error) {
                if (error.code === '23505') {
                    alert('User is already enrolled');
                } else {
                    throw error;
                }
            } else {
                // Success - refresh list and reset form
                fetchEnrollments();
                setShowAddUser(false);
                setSelectedUserId('');
            }
        } catch (error: any) {
            console.error('Error enrolling user:', error);
            alert('Failed to enroll user: ' + error.message);
        } finally {
            setIsEnrolling(false);
        }
    };

    const handleUnenroll = async (enrollmentId: string, userEmail: string) => {
        setConfirmDialog({
            isOpen: true,
            title: t('enrollments.confirm.title'),
            message: t('enrollments.confirm.message', { email: userEmail }),
            onConfirm: async () => {
                setConfirmDialog({ ...confirmDialog, isOpen: false });

                try {
                    const { error } = await supabase
                        .from('user_progress')
                        .delete()
                        .eq('id', enrollmentId);

                    if (error) throw error;

                    // Refresh list
                    fetchEnrollments();
                } catch (error: any) {
                    console.error('Error un-enrolling user:', error);
                    alert('Failed to un-enroll user: ' + error.message);
                }
            }
        });
    };

    const getProgressPercentage = (userId: string) => {
        // This would ideally call the calculate_course_progress function
        // For now, we'll calculate it client-side would need lesson completion data
        return 0; // Placeholder
    };

    if (isLoading) {
        return (
            <div className="flex items-center justify-center py-12">
                <div className="text-muted-foreground">Loading enrollments...</div>
            </div>
        );
    }

    return (
        <>
            <div className="space-y-4">
                <div className="flex items-center justify-between mb-4">
                    <h3 className="text-lg font-semibold">
                        {t('enrollments.title')} ({enrollments.length})
                    </h3>
                    <button
                        onClick={() => setShowAddUser(!showAddUser)}
                        className="px-4 py-2 bg-primary text-primary-foreground rounded-lg font-medium hover:bg-primary/90 transition-colors"
                    >
                        {t('enrollments.add_btn')}
                    </button>
                </div>

                {/* Add User Form */}
                {showAddUser && (
                    <div className="glass rounded-xl border border-white/10 p-6 space-y-4">
                        <h4 className="font-medium">{t('enrollments.form_title')}</h4>
                        <div className="flex gap-3">
                            <select
                                value={selectedUserId}
                                onChange={(e) => setSelectedUserId(e.target.value)}
                                className="flex-1 px-4 py-2 rounded-lg bg-background border border-border focus:border-primary focus:outline-none"
                                disabled={isEnrolling}
                            >
                                <option value="">{t('enrollments.select_placeholder')}</option>
                                {allUsers
                                    .filter(user => !enrollments.some(e => e.user_id === user.id))
                                    .map(user => (
                                        <option key={user.id} value={user.id}>
                                            {user.full_name || user.id}
                                            {user.user_category && ` - ${user.user_category}`}
                                        </option>
                                    ))}
                            </select>
                            <button
                                onClick={handleEnrollUser}
                                disabled={!selectedUserId || isEnrolling}
                                className="px-6 py-2 bg-primary text-primary-foreground rounded-lg font-medium hover:bg-primary/90 disabled:opacity-50 transition-colors"
                            >
                                {isEnrolling ? t('enrollments.enrolling') : t('enrollments.enroll_btn')}
                            </button>
                            <button
                                onClick={() => {
                                    setShowAddUser(false);
                                    setSelectedUserId('');
                                }}
                                className="px-4 py-2 rounded-lg border border-border hover:bg-muted transition-colors"
                            >
                                {t('enrollments.cancel')}
                            </button>
                        </div>
                    </div>
                )}

                {enrollments.length === 0 ? (
                    <div className="text-center py-12 glass rounded-xl border border-white/10">
                        <User className="w-12 h-12 mx-auto mb-4 text-muted-foreground opacity-50" />
                        <p className="text-muted-foreground">{t('enrollments.empty')}</p>
                        <p className="text-sm text-muted-foreground mt-2">
                            {t('enrollments.empty_desc')}
                        </p>
                    </div>
                ) : (
                    /* Enrollments Table */
                    <div className="glass rounded-xl border border-white/10 overflow-hidden">
                        <table className="w-full text-sm">
                            <thead className="text-xs uppercase bg-muted/50 text-muted-foreground">
                                <tr>
                                    <th className="px-6 py-4 font-medium text-left">{t('enrollments.table.user')}</th>
                                    <th className="px-6 py-4 font-medium text-left">{t('enrollments.table.category')}</th>
                                    <th className="px-6 py-4 font-medium text-left">{t('enrollments.table.status')}</th>
                                    <th className="px-6 py-4 font-medium text-left">{t('enrollments.table.enrolled')}</th>
                                    <th className="px-6 py-4 font-medium text-right">{t('enrollments.table.actions')}</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-border">
                                {enrollments.map((enrollment) => (
                                    <tr key={enrollment.id} className="hover:bg-muted/30 transition-colors">
                                        <td className="px-6 py-4">
                                            <div>
                                                <div className="font-medium">
                                                    {enrollment.profile.full_name || 'Unknown'}
                                                </div>
                                                <div className="text-xs text-muted-foreground">
                                                    {enrollment.profile.email}
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className="px-2 py-1 text-xs rounded-full bg-primary/10 text-primary">
                                                {enrollment.profile.user_category || 'N/A'}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4">
                                            <span className={`px-2 py-1 text-xs rounded-full ${enrollment.status === 'completed'
                                                ? 'bg-green-500/10 text-green-600'
                                                : 'bg-blue-500/10 text-blue-600'
                                                }`}>
                                                {enrollment.status}
                                            </span>
                                        </td>
                                        <td className="px-6 py-4 text-muted-foreground">
                                            {new Date(enrollment.created_at).toLocaleDateString()}
                                        </td>
                                        <td className="px-6 py-4 text-right">
                                            <button
                                                onClick={() => handleUnenroll(enrollment.id, enrollment.profile.email)}
                                                className="p-2 hover:bg-red-500/10 rounded-md transition-colors group"
                                                title={t('enrollments.tooltips.unenroll')}
                                            >
                                                <Trash2 className="w-4 h-4 text-muted-foreground group-hover:text-red-600" />
                                            </button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}

                {/* Info Box */}
                <div className="flex items-start gap-3 p-4 rounded-lg bg-blue-500/10 border border-blue-500/20">
                    <AlertCircle className="w-5 h-5 text-blue-600 shrink-0 mt-0.5" />
                    <div className="text-sm">
                        <p className="font-medium text-blue-600 mb-1">{t('enrollments.info.title')}</p>
                        <p className="text-muted-foreground">
                            {t('enrollments.info.desc')}
                        </p>
                    </div>
                </div>
            </div>

            <ConfirmDialog
                isOpen={confirmDialog.isOpen}
                title={confirmDialog.title}
                message={confirmDialog.message}
                onConfirm={confirmDialog.onConfirm}
                onCancel={() => setConfirmDialog({ ...confirmDialog, isOpen: false })}
                variant="danger"
                confirmText={t('enrollments.confirm.btn')}
            />
        </>
    );
}
