'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Button } from '@/components/ui/button';
import { Plus, Search, Tag as TagIcon, Trash2, Globe, Users } from 'lucide-react';
import { toast } from 'sonner';
import CreateTagDialog from './CreateTagDialog';
import { useTranslations } from 'next-intl';

interface Tag {
    id: string;
    name: string;
    slug: string;
    description?: string;
    target_groups?: string[];
    count?: number;
}

// Map group values to display labels
const GROUP_LABELS: Record<string, string> = {
    'sibling': 'Søsken',
    'parent': 'Foreldre',
    'team-member': 'Teammedlem',
    'team-leader': 'Teamleder',
    'construction_worker': 'Håndverker',
    'site_manager': 'Bas/Byggeleder',
};

export default function TagsList() {
    const t = useTranslations('AdminTags');
    const [tags, setTags] = useState<Tag[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [isCreateOpen, setIsCreateOpen] = useState(false);
    const supabase = createClient();

    const fetchTags = async () => {
        setLoading(true);
        try {
            const { data, error } = await supabase
                .from('tags')
                .select('*')
                .order('name');

            if (error) throw error;
            setTags(data || []);
        } catch (error) {
            console.error('Error fetching tags:', error);
            toast.error(t('alerts.load_error'));
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchTags();
    }, []);

    const handleDelete = async (id: string, name: string) => {
        if (!confirm(t('alerts.delete_confirm', { name }))) return;

        try {
            const { error } = await supabase
                .from('tags')
                .delete()
                .eq('id', id);

            if (error) throw error;
            toast.success(t('alerts.delete_success'));
            fetchTags();
        } catch (error) {
            console.error('Error deleting tag:', error);
            toast.error(t('alerts.delete_error'));
        }
    };

    const filteredTags = tags.filter(tag =>
        tag.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        tag.description?.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const isUniversal = (tag: Tag) => !tag.target_groups || tag.target_groups.length === 0;

    return (
        <div className="space-y-6">
            <div className="flex flex-col sm:flex-row gap-4 justify-between items-center">
                <div className="relative w-full sm:w-64">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                    <input
                        type="text"
                        placeholder={t('search_placeholder')}
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full pl-9 pr-4 py-2 border-2 border-black dark:border-white text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                    />
                </div>
                <Button onClick={() => setIsCreateOpen(true)} className="w-full sm:w-auto">
                    <Plus className="w-4 h-4 mr-2" />
                    {t('new_tag')}
                </Button>
            </div>

            <div className="bg-card border-2 border-black dark:border-white shadow-[4px_4px_0_0_#000] dark:shadow-[4px_4px_0_0_#fff] overflow-hidden">
                <table className="w-full text-sm text-left">
                    <thead className="bg-muted/50 border-b-2 border-black dark:border-white font-bold">
                        <tr>
                            <th className="px-6 py-4">{t('table.name')}</th>
                            <th className="px-6 py-4 hidden md:table-cell">Beskrivelse</th>
                            <th className="px-6 py-4">Synlighet</th>
                            <th className="px-6 py-4 text-right">{t('table.actions')}</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-black/10 dark:divide-white/10">
                        {loading ? (
                            <tr>
                                <td colSpan={4} className="px-6 py-12 text-center text-muted-foreground">
                                    {t('loading')}
                                </td>
                            </tr>
                        ) : filteredTags.length === 0 ? (
                            <tr>
                                <td colSpan={4} className="px-6 py-12 text-center text-muted-foreground">
                                    {searchQuery ? t('no_results') : t('empty')}
                                </td>
                            </tr>
                        ) : (
                            filteredTags.map((tag) => (
                                <tr key={tag.id} className="hover:bg-muted/50 transition-colors">
                                    <td className="px-6 py-4 font-medium">
                                        <div className="flex items-center gap-3">
                                            <div className="w-8 h-8 bg-primary/10 flex items-center justify-center text-primary border border-primary/30">
                                                <TagIcon className="w-4 h-4" />
                                            </div>
                                            <div>
                                                <div className="font-bold">{tag.name}</div>
                                                <div className="text-xs text-muted-foreground font-mono">{tag.slug}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-6 py-4 text-muted-foreground hidden md:table-cell max-w-[200px] truncate">
                                        {tag.description || '—'}
                                    </td>
                                    <td className="px-6 py-4">
                                        {isUniversal(tag) ? (
                                            <span className="inline-flex items-center gap-1.5 px-2 py-1 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 text-xs font-medium">
                                                <Globe className="w-3 h-3" />
                                                Alle
                                            </span>
                                        ) : (
                                            <div className="flex flex-wrap gap-1">
                                                <span className="inline-flex items-center gap-1 px-2 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400 text-xs font-medium">
                                                    <Users className="w-3 h-3" />
                                                    {tag.target_groups?.length} grupper
                                                </span>
                                            </div>
                                        )}
                                    </td>
                                    <td className="px-6 py-4 text-right">
                                        <div className="flex items-center justify-end gap-2">
                                            <button
                                                onClick={() => handleDelete(tag.id, tag.name)}
                                                className="p-2 hover:bg-red-50 dark:hover:bg-red-900/20 text-muted-foreground hover:text-red-600 transition-colors"
                                            >
                                                <Trash2 className="w-4 h-4" />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>

            <CreateTagDialog
                open={isCreateOpen}
                onOpenChange={setIsCreateOpen}
                onSuccess={fetchTags}
            />
        </div>
    );
}
