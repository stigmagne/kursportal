'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Button } from '@/components/ui/button';
import { Plus, Search, Tag as TagIcon, Trash2, Edit2 } from 'lucide-react';
import { toast } from 'sonner';
import CreateTagDialog from './CreateTagDialog';
import { useTranslations } from 'next-intl';

interface Tag {
    id: string;
    name: string;
    slug: string;
    count?: number; // Optional course count
}

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
        tag.name.toLowerCase().includes(searchQuery.toLowerCase())
    );

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
                        className="w-full pl-9 pr-4 py-2 rounded-md border text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                    />
                </div>
                <Button onClick={() => setIsCreateOpen(true)} className="w-full sm:w-auto">
                    <Plus className="w-4 h-4 mr-2" />
                    {t('new_tag')}
                </Button>
            </div>

            <div className="bg-card rounded-xl border shadow-sm overflow-hidden">
                <table className="w-full text-sm text-left">
                    <thead className="bg-muted/50 border-b font-medium text-muted-foreground">
                        <tr>
                            <th className="px-6 py-4">{t('table.name')}</th>
                            <th className="px-6 py-4">{t('table.slug')}</th>
                            <th className="px-6 py-4 text-right">{t('table.actions')}</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y">
                        {loading ? (
                            <tr>
                                <td colSpan={3} className="px-6 py-12 text-center text-muted-foreground">
                                    {t('loading')}
                                </td>
                            </tr>
                        ) : filteredTags.length === 0 ? (
                            <tr>
                                <td colSpan={3} className="px-6 py-12 text-center text-muted-foreground">
                                    {searchQuery ? t('no_results') : t('empty')}
                                </td>
                            </tr>
                        ) : (
                            filteredTags.map((tag) => (
                                <tr key={tag.id} className="hover:bg-muted/50 transition-colors">
                                    <td className="px-6 py-4 font-medium flex items-center gap-2">
                                        <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center text-primary">
                                            <TagIcon className="w-4 h-4" />
                                        </div>
                                        {tag.name}
                                    </td>
                                    <td className="px-6 py-4 text-muted-foreground font-mono text-xs">
                                        {tag.slug}
                                    </td>
                                    <td className="px-6 py-4 text-right">
                                        <div className="flex items-center justify-end gap-2">
                                            {/* Edit not implemented yet */}
                                            {/* <button className="p-2 hover:bg-muted rounded-md text-muted-foreground hover:text-foreground">
                                                <Edit2 className="w-4 h-4" />
                                            </button> */}
                                            <button
                                                onClick={() => handleDelete(tag.id, tag.name)}
                                                className="p-2 hover:bg-red-50 rounded-md text-muted-foreground hover:text-red-600 transition-colors"
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
