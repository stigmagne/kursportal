import { createClient } from '@/utils/supabase/server';
import { Link } from '@/i18n/routing';
import { Tag, Plus } from 'lucide-react';
import CategoryList from '@/components/admin/CategoryList';
import { getTranslations } from 'next-intl/server';

export default async function CategoriesPage() {
    const t = await getTranslations('AdminCategories');
    const supabase = await createClient();

    const { data: categories } = await supabase
        .from('categories')
        .select('*, course_categories(count), user_categories(count)')
        .order('created_at', { ascending: false });

    return (
        <div className="space-y-8">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">{t('title')}</h1>
                    <p className="text-muted-foreground mt-2">{t('subtitle')}</p>
                </div>
                <Link
                    href="/admin/categories/new"
                    className="flex items-center gap-2 bg-primary text-primary-foreground px-4 py-2 rounded-lg font-medium hover:bg-primary/90 transition-colors"
                >
                    <Plus className="w-4 h-4" />
                    {t('create')}
                </Link>
            </div>

            <CategoryList categories={categories || []} />
        </div>
    );
}
