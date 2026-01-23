'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { useRouter } from '@/i18n/routing';
import { Save, ArrowLeft, Loader2 } from 'lucide-react';
import { Link } from '@/i18n/routing';

const PRESET_COLORS = [
    '#3b82f6', // blue
    '#10b981', // green
    '#8b5cf6', // purple
    '#f59e0b', // orange
    '#ef4444', // red
    '#06b6d4', // cyan
    '#ec4899', // pink
    '#6366f1', // indigo
];

export default function CategoryForm({ categoryId }: { categoryId?: string }) {
    const supabase = createClient();
    const router = useRouter();
    const [loading, setLoading] = useState(!!categoryId);
    const [saving, setSaving] = useState(false);
    const [formData, setFormData] = useState({
        name: '',
        description: '',
        color: '#3b82f6',
    });

    useEffect(() => {
        if (categoryId) {
            fetchCategory();
        }
    }, [categoryId]);

    const fetchCategory = async () => {
        try {
            const { data, error } = await supabase
                .from('categories')
                .select('*')
                .eq('id', categoryId)
                .single();

            if (error) throw error;
            if (data) setFormData(data);
        } catch (error) {
            console.error('Error fetching category:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setSaving(true);

        try {
            if (categoryId) {
                const { error } = await supabase
                    .from('categories')
                    .update(formData)
                    .eq('id', categoryId);
                if (error) throw error;
            } else {
                const { data: { user } } = await supabase.auth.getUser();
                const { error } = await supabase
                    .from('categories')
                    .insert({ ...formData, created_by: user?.id });
                if (error) throw error;
            }

            router.push('/admin/categories');
            router.refresh();
        } catch (error: any) {
            alert('Error saving category: ' + error.message);
        } finally {
            setSaving(false);
        }
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center py-12">
                <Loader2 className="w-8 h-8 animate-spin text-primary" />
            </div>
        );
    }

    return (
        <div className="space-y-8">
            <div className="flex items-center gap-4">
                <Link
                    href="/admin/categories"
                    className="p-2 hover:bg-muted rounded-lg transition-colors"
                >
                    <ArrowLeft className="w-5 h-5" />
                </Link>
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">
                        {categoryId ? 'Edit Category' : 'Create Category'}
                    </h1>
                </div>
            </div>

            <form onSubmit={handleSubmit} className="max-w-2xl space-y-6">
                <div className="glass p-8 rounded-2xl border border-white/10 space-y-6">
                    <div>
                        <label className="block text-sm font-medium mb-2">Category Name *</label>
                        <input
                            type="text"
                            required
                            value={formData.name}
                            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                            className="w-full px-4 py-2 rounded-lg bg-muted border border-border focus:border-primary focus:outline-none"
                            placeholder="e.g., Introductory"
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium mb-2">Description</label>
                        <textarea
                            value={formData.description}
                            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                            rows={3}
                            className="w-full px-4 py-2 rounded-lg bg-muted border border-border focus:border-primary focus:outline-none resize-none"
                            placeholder="Describe this category..."
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium mb-3">Color</label>
                        <div className="flex gap-2 flex-wrap">
                            {PRESET_COLORS.map((color) => (
                                <button
                                    key={color}
                                    type="button"
                                    onClick={() => setFormData({ ...formData, color })}
                                    className={`w-10 h-10 rounded-lg border-2 transition-all ${formData.color === color ? 'border-white scale-110' : 'border-transparent'
                                        }`}
                                    style={{ backgroundColor: color }}
                                />
                            ))}
                            <input
                                type="color"
                                value={formData.color}
                                onChange={(e) => setFormData({ ...formData, color: e.target.value })}
                                className="w-10 h-10 rounded-lg cursor-pointer"
                            />
                        </div>
                    </div>

                    <div className="pt-4 flex gap-3">
                        <button
                            type="submit"
                            disabled={saving}
                            className="flex items-center gap-2 px-6 py-2 bg-primary text-primary-foreground rounded-lg font-medium hover:bg-primary/90 transition-colors disabled:opacity-50"
                        >
                            {saving ? (
                                <Loader2 className="w-4 h-4 animate-spin" />
                            ) : (
                                <Save className="w-4 h-4" />
                            )}
                            {categoryId ? 'Update Category' : 'Create Category'}
                        </button>
                        <Link
                            href="/admin/categories"
                            className="px-6 py-2 bg-secondary text-secondary-foreground rounded-lg font-medium hover:bg-secondary/80 transition-colors"
                        >
                            Cancel
                        </Link>
                    </div>
                </div>
            </form>
        </div>
    );
}
