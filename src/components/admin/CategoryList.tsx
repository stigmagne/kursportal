'use client';

import { useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { useRouter } from 'next/navigation';
import { Trash2, Edit, BookOpen, Users, Tag } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { useTranslations } from 'next-intl';

export default function CategoryList({ categories: initialCategories }: { categories: any[] }) {
    const t = useTranslations('AdminCategories');
    const [categories, setCategories] = useState(initialCategories);
    const supabase = createClient();
    const router = useRouter();

    const handleDelete = async (id: string, name: string) => {
        if (!confirm(t('delete_confirm', { name }))) return;

        try {
            const { error } = await supabase
                .from('categories')
                .delete()
                .eq('id', id);

            if (error) throw error;

            setCategories(categories.filter(c => c.id !== id));
        } catch (error: any) {
            alert('Error deleting category: ' + error.message);
        }
    };

    return (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {categories.map((category) => (
                <div
                    key={category.id}
                    className="glass p-6 rounded-xl border border-white/10 hover:border-primary/20 transition-colors relative group"
                >
                    <div className="flex items-start justify-between mb-4">
                        <div
                            className="w-12 h-12 rounded-lg flex items-center justify-center"
                            style={{ backgroundColor: `${category.color}20`, borderColor: category.color }}
                        >
                            <Tag className="w-6 h-6" style={{ color: category.color }} />
                        </div>
                        <div className="flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                            <Link
                                href={`/admin/categories/edit/${category.id}`}
                                className="p-2 hover:bg-muted rounded-md transition-colors"
                                title="Edit"
                            >
                                <Edit className="w-4 h-4 text-muted-foreground hover:text-foreground" />
                            </Link>
                            <button
                                onClick={() => handleDelete(category.id, category.name)}
                                className="p-2 hover:bg-destructive/10 rounded-md transition-colors"
                                title="Delete"
                            >
                                <Trash2 className="w-4 h-4 text-muted-foreground hover:text-destructive" />
                            </button>
                        </div>
                    </div>

                    <h3 className="text-lg font-semibold mb-2">{category.name}</h3>
                    <p className="text-sm text-muted-foreground mb-4 line-clamp-2">
                        {category.description || t('no_description')}
                    </p>

                    <div className="flex items-center gap-4 text-xs text-muted-foreground">
                        <div className="flex items-center gap-1">
                            <BookOpen className="w-3 h-3" />
                            <span>{t('courses_count', { count: category.course_categories?.[0]?.count || 0 })}</span>
                        </div>
                        <div className="flex items-center gap-1">
                            <Users className="w-3 h-3" />
                            <span>{t('members_count', { count: category.user_categories?.[0]?.count || 0 })}</span>
                        </div>
                    </div>
                </div>
            ))}

            {categories.length === 0 && (
                <div className="col-span-full text-center py-12 text-muted-foreground">
                    {t('empty')}
                </div>
            )}
        </div>
    );
}
