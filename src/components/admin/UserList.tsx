'use client';

import { useState, useRef, useEffect } from 'react';
import { useTranslations } from 'next-intl';
import {
    Search,
    Filter,
    ChevronDown,
    ChevronUp,
    MoreHorizontal,
    Shield,
    ShieldAlert,
    UserX,
    Pencil,
    Ban
} from 'lucide-react';
import { AdminUser, AdminUserUpdate, BanDuration } from '@/types/admin';
import { Badge } from '@/components/ui/badge';
import ConfirmDialog from '@/components/ConfirmDialog';
import { toggleBanUser, anonymizeUser, updateUser } from '@/app/actions/admin-user-actions';
import { useRouter } from 'next/navigation';
import { USER_GROUPS } from '@/config/groups';

interface UserListProps {
    initialUsers: AdminUser[];
}

interface SortConfig {
    key: keyof AdminUser;
    direction: 'asc' | 'desc';
}

interface FilterConfig {
    category: string;
    subgroup: string;
    role: string;
}

export default function UserList({ initialUsers }: UserListProps) {
    const t = useTranslations('AdminUsers');
    const router = useRouter();
    const [users, setUsers] = useState<AdminUser[]>(initialUsers);
    const [searchTerm, setSearchTerm] = useState('');
    const [sortConfig, setSortConfig] = useState<SortConfig | null>(null);
    const [filters, setFilters] = useState<FilterConfig>({
        category: 'all',
        subgroup: 'all',
        role: 'all'
    });

    // Action States
    const [selectedUser, setSelectedUser] = useState<AdminUser | null>(null);
    const [showEditModal, setShowEditModal] = useState(false);
    const [showBanModal, setShowBanModal] = useState(false);
    const [showAnonymizeModal, setShowAnonymizeModal] = useState(false);
    const [isLoading, setIsLoading] = useState(false);
    const [openMenuId, setOpenMenuId] = useState<string | null>(null);
    const [editForm, setEditForm] = useState<AdminUserUpdate>({});
    const [banDuration, setBanDuration] = useState<BanDuration>('24h');

    // Close menu on click outside
    useEffect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            if (openMenuId && !(event.target as Element).closest('.action-menu-trigger')) {
                setOpenMenuId(null);
            }
        };
        document.addEventListener('click', handleClickOutside);
        return () => document.removeEventListener('click', handleClickOutside);
    }, [openMenuId]);

    // Derived values for filters
    const validUsers = users.filter(user => user.full_name !== 'Unknown User');
    const categories = Array.from(new Set(validUsers.map(u => u.category).filter(Boolean)));
    const subgroups = Array.from(new Set(validUsers.map(u => u.subgroup).filter(Boolean)));

    const handleSort = (key: keyof AdminUser) => {
        let direction: 'asc' | 'desc' = 'asc';
        if (sortConfig && sortConfig.key === key && sortConfig.direction === 'asc') {
            direction = 'desc';
        }
        setSortConfig({ key, direction });
    };

    const getSortedUsers = (filtered: AdminUser[]) => {
        if (!sortConfig) return filtered;
        return [...filtered].sort((a, b) => {
            const aValue = a[sortConfig.key] || '';
            const bValue = b[sortConfig.key] || '';

            if (aValue < bValue) return sortConfig.direction === 'asc' ? -1 : 1;
            if (aValue > bValue) return sortConfig.direction === 'asc' ? 1 : -1;
            return 0;
        });
    };

    const filteredUsers = getSortedUsers(users.filter(user => {
        const matchesSearch = (user.full_name?.toLowerCase() || '').includes(searchTerm.toLowerCase());
        const matchesCategory = filters.category === 'all' || user.category === filters.category;
        const matchesSubgroup = filters.subgroup === 'all' || user.subgroup === filters.subgroup;
        const matchesRole = filters.role === 'all' || user.role === filters.role;

        return matchesSearch && matchesCategory && matchesSubgroup && matchesRole;
    }));

    const handleBan = async () => {
        if (!selectedUser) return;
        setIsLoading(true);
        try {
            await toggleBanUser(selectedUser.id, banDuration);
            router.refresh(); // Refresh server data
            // Optimistic update
            setUsers(users.map(u => u.id === selectedUser.id ? {
                ...u,
                banned_until: banDuration === 'none' ? null : new Date(Date.now() + 86400000).toISOString() // Dummy date for optimistic UI or just rely on router.refresh
            } : u));
            setShowBanModal(false);
        } catch (error) {
            console.error('Failed to ban user:', error);
            // Show error toast
        } finally {
            setIsLoading(false);
            setOpenMenuId(null);
        }
    };

    const handleAnonymize = async () => {
        if (!selectedUser) return;
        setIsLoading(true);
        try {
            await anonymizeUser(selectedUser.id);
            router.refresh();
            setUsers(users.filter(u => u.id !== selectedUser.id)); // Remove or update
            setShowAnonymizeModal(false);
        } catch (error) {
            console.error('Failed to anonymize user:', error);
        } finally {
            setIsLoading(false);
            setOpenMenuId(null);
        }
    };

    const handleEdit = async () => {
        if (!selectedUser) return;
        setIsLoading(true);
        try {
            await updateUser(selectedUser.id, editForm);
            router.refresh();
            setUsers(users.map(u => u.id === selectedUser.id ? { ...u, ...editForm } : u));
            setShowEditModal(false);
        } catch (error) {
            console.error('Failed to update user:', error);
        } finally {
            setIsLoading(false);
            setOpenMenuId(null);
        }
    };

    const openAction = (user: AdminUser, action: 'edit' | 'ban' | 'anonymize') => {
        setSelectedUser(user);
        setOpenMenuId(null);
        if (action === 'edit') {
            setEditForm({
                full_name: user.full_name || '',
                role: user.role,
                category: user.category || '',
                subgroup: user.subgroup || ''
            });
            setShowEditModal(true);
        } else if (action === 'ban') {
            // Check if already banned to maybe set default "none"
            setBanDuration(user.banned_until ? 'none' : '24h');
            setShowBanModal(true);
        } else if (action === 'anonymize') {
            setShowAnonymizeModal(true);
        }
    };

    return (
        <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden relative">
            {/* Filters Header */}
            <div className="p-4 border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-900/50 space-y-4">
                <div className="flex flex-col md:flex-row gap-4">
                    <div className="relative flex-1">
                        <Search className="absolute left-3 top-2.5 h-4 w-4 text-gray-500" />
                        <input
                            type="text"
                            placeholder={t('filters.search_placeholder')}
                            className="pl-9 w-full h-10 rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary/50"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                    <div className="flex gap-2">
                        {/* Filters Dropdowns */}
                        <select
                            className="h-10 rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-3 text-sm"
                            value={filters.category}
                            onChange={(e) => setFilters(prev => ({ ...prev, category: e.target.value }))}
                        >
                            <option value="all">{t('filters.all_groups')}</option>
                            {categories.map(c => (
                                <option key={c} value={c as string}>{t(`categories.${c}`) || c}</option>
                            ))}
                        </select>

                        <select
                            className="h-10 rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-3 text-sm"
                            value={filters.subgroup}
                            onChange={(e) => setFilters(prev => ({ ...prev, subgroup: e.target.value }))}
                        >
                            <option value="all">{t('filters.all_subgroups')}</option>
                            {subgroups.map(s => (
                                <option key={s} value={s as string}>{s}</option>
                            ))}
                        </select>

                        <select
                            className="h-10 rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-3 text-sm"
                            value={filters.role}
                            onChange={(e) => setFilters(prev => ({ ...prev, role: e.target.value }))}
                        >
                            <option value="all">{t('filters.all_roles')}</option>
                            {['admin', 'member', 'user'].map(r => (
                                <option key={r} value={r}>{t(`roles.${r}`)}</option>
                            ))}
                        </select>

                        {(searchTerm || filters.category !== 'all' || filters.subgroup !== 'all' || filters.role !== 'all') && (
                            <button
                                onClick={() => {
                                    setSearchTerm('');
                                    setFilters({ category: 'all', subgroup: 'all', role: 'all' });
                                }}
                                className="h-10 px-3 text-sm text-gray-500 hover:text-gray-900 dark:hover:text-gray-100"
                            >
                                {t('filters.clear')}
                            </button>
                        )}
                    </div>
                </div>
            </div>

            {/* Table */}
            <div className="overflow-x-auto">
                <table className="w-full text-sm text-left">
                    <thead className="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-900/50 dark:text-gray-400">
                        <tr>
                            <th className="px-6 py-3 cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-800" onClick={() => handleSort('full_name')}>
                                <div className="flex items-center gap-1">
                                    {t('table.name')}
                                    {sortConfig?.key === 'full_name' && (sortConfig.direction === 'asc' ? <ChevronUp className="w-3 h-3" /> : <ChevronDown className="w-3 h-3" />)}
                                </div>
                            </th>
                            <th className="px-6 py-3 cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-800" onClick={() => handleSort('category')}>
                                <div className="flex items-center gap-1">
                                    {t('table.category')}
                                    {sortConfig?.key === 'category' && (sortConfig.direction === 'asc' ? <ChevronUp className="w-3 h-3" /> : <ChevronDown className="w-3 h-3" />)}
                                </div>
                            </th>
                            <th className="px-6 py-3 cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-800" onClick={() => handleSort('subgroup')}>
                                <div className="flex items-center gap-1">
                                    {t('table.subgroup')}
                                    {sortConfig?.key === 'subgroup' && (sortConfig.direction === 'asc' ? <ChevronUp className="w-3 h-3" /> : <ChevronDown className="w-3 h-3" />)}
                                </div>
                            </th>
                            <th className="px-6 py-3 cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-800" onClick={() => handleSort('role')}>
                                <div className="flex items-center gap-1">
                                    {t('table.role')}
                                    {sortConfig?.key === 'role' && (sortConfig.direction === 'asc' ? <ChevronUp className="w-3 h-3" /> : <ChevronDown className="w-3 h-3" />)}
                                </div>
                            </th>
                            <th className="px-6 py-3 cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-800" onClick={() => handleSort('created_at')}>
                                <div className="flex items-center gap-1">
                                    {t('table.joined')}
                                    {sortConfig?.key === 'created_at' && (sortConfig.direction === 'asc' ? <ChevronUp className="w-3 h-3" /> : <ChevronDown className="w-3 h-3" />)}
                                </div>
                            </th>
                            <th className="px-6 py-3 text-right">Handlinger</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
                        {filteredUsers.map((user) => (
                            <tr key={user.id} className="bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700/50">
                                <td className="px-6 py-4 font-medium text-gray-900 dark:text-white flex items-center gap-2">
                                    {user.full_name || t('unknown_user')}
                                    {user.banned_until && (
                                        <Badge variant="destructive" className="h-5 px-1.5 text-[10px]">
                                            {t('status.banned')}
                                        </Badge>
                                    )}
                                </td>
                                <td className="px-6 py-4">
                                    {user.category ? (t(`categories.${user.category}`) || user.category) : '-'}
                                </td>
                                <td className="px-6 py-4">
                                    {user.subgroup || '-'}
                                </td>
                                <td className="px-6 py-4">
                                    <Badge variant={user.role === 'admin' ? 'default' : 'secondary'}>
                                        {t(`roles.${user.role}`)}
                                    </Badge>
                                </td>
                                <td className="px-6 py-4 text-gray-500">
                                    {new Date(user.created_at).toLocaleDateString('no-NO')}
                                </td>
                                <td className="px-6 py-4 text-right relative">
                                    <button
                                        className="action-menu-trigger p-1.5 hover:bg-gray-200 dark:hover:bg-gray-700 rounded-md transition-colors"
                                        onClick={() => setOpenMenuId(openMenuId === user.id ? null : user.id)}
                                    >
                                        <MoreHorizontal className="w-4 h-4" />
                                    </button>

                                    {openMenuId === user.id && (
                                        <div className="absolute right-8 top-8 w-48 bg-white dark:bg-gray-800 rounded-md shadow-lg border border-gray-200 dark:border-gray-700 z-10 py-1 text-left">
                                            <button
                                                onClick={() => openAction(user, 'edit')}
                                                className="w-full px-4 py-2 text-sm text-left text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center gap-2"
                                            >
                                                <Pencil className="w-4 h-4" /> {t('actions.edit')}
                                            </button>
                                            <button
                                                onClick={() => openAction(user, 'ban')}
                                                className="w-full px-4 py-2 text-sm text-left text-orange-600 hover:bg-orange-50 dark:hover:bg-orange-900/20 flex items-center gap-2"
                                            >
                                                <Ban className="w-4 h-4" /> {t('actions.ban')}
                                            </button>
                                            <button
                                                onClick={() => openAction(user, 'anonymize')}
                                                className="w-full px-4 py-2 text-sm text-left text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20 flex items-center gap-2"
                                            >
                                                <UserX className="w-4 h-4" /> {t('actions.anonymize')}
                                            </button>
                                        </div>
                                    )}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>

            {/* Edit Modal */}
            {showEditModal && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
                    <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-200 dark:border-gray-700 p-6 max-w-md w-full shadow-2xl">
                        <h3 className="text-lg font-semibold mb-4">{t('edit_dialog.title')}</h3>
                        <div className="space-y-4">
                            <div>
                                <label className="block text-sm font-medium mb-1">Navn</label>
                                <input
                                    className="w-full p-2 rounded border border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                    value={editForm.full_name || ''}
                                    onChange={e => setEditForm({ ...editForm, full_name: e.target.value })}
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1">Rolle</label>
                                <select
                                    className="w-full p-2 rounded border border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                    value={editForm.role}
                                    onChange={e => setEditForm({ ...editForm, role: e.target.value })}
                                >
                                    <option value="user">Bruker</option>
                                    <option value="member">Medlem</option>
                                    <option value="admin">Admin</option>
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1">Gruppe</label>
                                <select
                                    className="w-full p-2 rounded border border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                    value={editForm.category || ''}
                                    onChange={e => setEditForm({ ...editForm, category: e.target.value })}
                                >
                                    <option value="">Ingen</option>
                                    {USER_GROUPS.map(group => (
                                        <option key={group.value} value={group.value}>
                                            {group.label}
                                        </option>
                                    ))}
                                </select>
                            </div>
                            <div>
                                <label className="block text-sm font-medium mb-1">Undergruppe</label>
                                <input
                                    className="w-full p-2 rounded border border-gray-300 dark:border-gray-700 dark:bg-gray-800"
                                    value={editForm.subgroup || ''}
                                    onChange={e => setEditForm({ ...editForm, subgroup: e.target.value })}
                                />
                            </div>
                        </div>
                        <div className="flex gap-3 justify-end mt-6">
                            <button onClick={() => setShowEditModal(false)} className="px-4 py-2 border rounded">{t('edit_dialog.cancel')}</button>
                            <button onClick={handleEdit} disabled={isLoading} className="px-4 py-2 bg-primary text-white rounded">{isLoading ? 'Saving...' : t('edit_dialog.save')}</button>
                        </div>
                    </div>
                </div>
            )}

            {/* Ban Modal */}
            {showBanModal && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
                    <div className="bg-white dark:bg-gray-900 rounded-xl border border-gray-200 dark:border-gray-700 p-6 max-w-md w-full shadow-2xl">
                        <h3 className="text-lg font-semibold mb-2 text-left">{t('ban_dialog.title')}</h3>
                        <p className="text-sm text-gray-500 mb-4 text-left">{t('ban_dialog.description')}</p>

                        <div className="space-y-2 mb-6">
                            {(['24h', '7d', '30d', 'permanent', 'none'] as BanDuration[]).map(duration => (
                                <label key={duration} className="flex items-center gap-3 p-3 border rounded cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-800">
                                    <input
                                        type="radio"
                                        name="banDuration"
                                        checked={banDuration === duration}
                                        onChange={() => setBanDuration(duration)}
                                        className="h-4 w-4"
                                    />
                                    <span>{t(`ban_dialog.duration.${duration}`)}</span>
                                </label>
                            ))}
                        </div>

                        <div className="flex gap-3 justify-end">
                            <button onClick={() => setShowBanModal(false)} className="px-4 py-2 border rounded">{t('ban_dialog.cancel')}</button>
                            <button onClick={handleBan} disabled={isLoading} className="px-4 py-2 bg-red-600 text-white rounded">{isLoading ? 'Saving...' : t('ban_dialog.confirm')}</button>
                        </div>
                    </div>
                </div>
            )}

            <ConfirmDialog
                isOpen={showAnonymizeModal}
                title={t('anonymize_dialog.title')}
                message={t('anonymize_dialog.warning')}
                confirmText={t('anonymize_dialog.confirm')}
                cancelText={t('anonymize_dialog.cancel')}
                onConfirm={handleAnonymize}
                onCancel={() => setShowAnonymizeModal(false)}
                variant="danger"
            />
        </div>
    );
}
