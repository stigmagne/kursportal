'use client';

import { useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Button } from '@/components/ui/button';
import { X, Loader2, Globe, Users } from 'lucide-react';
import { toast } from 'sonner';
import * as DialogPrimitive from '@radix-ui/react-dialog';
import { useTranslations } from 'next-intl';

interface CreateTagDialogProps {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    onSuccess: () => void;
}

// Available target groups
const TARGET_GROUPS = [
    { value: 'sibling', label: 'Søsken' },
    { value: 'parent', label: 'Foreldre' },
    { value: 'team-member', label: 'Teammedlem' },
    { value: 'team-leader', label: 'Teamleder' },
    { value: 'construction_worker', label: 'Håndverker' },
    { value: 'site_manager', label: 'Bas/Byggeleder' },
];

export default function CreateTagDialog({ open, onOpenChange, onSuccess }: CreateTagDialogProps) {
    const t = useTranslations('AdminTags');
    const [name, setName] = useState('');
    const [description, setDescription] = useState('');
    const [isUniversal, setIsUniversal] = useState(true);
    const [selectedGroups, setSelectedGroups] = useState<string[]>([]);
    const [submitting, setSubmitting] = useState(false);
    const supabase = createClient();

    const slugify = (text: string) => {
        return text
            .toString()
            .toLowerCase()
            .replace(/\s+/g, '-')
            .replace(/[^\w\-]+/g, '')
            .replace(/\-\-+/g, '-')
            .replace(/^-+/, '')
            .replace(/-+$/, '');
    };

    const toggleGroup = (group: string) => {
        setSelectedGroups(prev =>
            prev.includes(group)
                ? prev.filter(g => g !== group)
                : [...prev, group]
        );
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!name.trim()) return;

        setSubmitting(true);
        try {
            const slug = slugify(name);

            // Check if exists
            const { data: existing } = await supabase
                .from('tags')
                .select('id')
                .eq('slug', slug)
                .single();

            if (existing) {
                toast.error(t('alerts.exists_error'));
                return;
            }

            const { error } = await supabase
                .from('tags')
                .insert({
                    name: name.trim(),
                    slug,
                    description: description.trim() || null,
                    target_groups: isUniversal ? [] : selectedGroups
                });

            if (error) throw error;

            toast.success(t('alerts.create_success'));
            setName('');
            setDescription('');
            setIsUniversal(true);
            setSelectedGroups([]);
            onSuccess();
            onOpenChange(false);
        } catch (error) {
            console.error('Error creating tag:', error);
            toast.error(t('alerts.create_error'));
        } finally {
            setSubmitting(false);
        }
    };

    if (!open) return null;

    return (
        <DialogPrimitive.Root open={open} onOpenChange={onOpenChange}>
            <DialogPrimitive.Portal>
                <DialogPrimitive.Overlay className="fixed inset-0 bg-black/50 z-50 backdrop-blur-sm animate-in fade-in-0" />
                <DialogPrimitive.Content className="fixed left-[50%] top-[50%] z-50 w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4 border-2 border-black dark:border-white bg-background p-6 shadow-[4px_4px_0_0_#000] dark:shadow-[4px_4px_0_0_#fff] duration-200 animate-in fade-in-0 zoom-in-95">
                    <div className="flex flex-col gap-1.5 text-center sm:text-left">
                        <DialogPrimitive.Title className="text-lg font-bold leading-none tracking-tight">
                            {t('create.title')}
                        </DialogPrimitive.Title>
                        <DialogPrimitive.Description className="text-sm text-muted-foreground">
                            {t('create.desc')}
                        </DialogPrimitive.Description>
                    </div>

                    <form onSubmit={handleSubmit} className="mt-4 space-y-4">
                        {/* Name field */}
                        <div className="space-y-2">
                            <label className="text-sm font-medium">
                                {t('create.name_label')}
                            </label>
                            <input
                                type="text"
                                value={name}
                                onChange={(e) => setName(e.target.value)}
                                placeholder={t('create.placeholder')}
                                className="flex h-10 w-full border-2 border-black dark:border-white bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                                autoFocus
                            />
                            {name && (
                                <p className="text-xs text-muted-foreground">
                                    {t('create.slug_preview')} <span className="font-mono bg-muted px-1">{slugify(name)}</span>
                                </p>
                            )}
                        </div>

                        {/* Description field */}
                        <div className="space-y-2">
                            <label className="text-sm font-medium">
                                Beskrivelse (valgfritt)
                            </label>
                            <input
                                type="text"
                                value={description}
                                onChange={(e) => setDescription(e.target.value)}
                                placeholder="Kort beskrivelse av taggen"
                                className="flex h-10 w-full border-2 border-black dark:border-white bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                            />
                        </div>

                        {/* Visibility toggle */}
                        <div className="space-y-3">
                            <label className="text-sm font-medium">Synlighet</label>
                            <div className="flex gap-2">
                                <button
                                    type="button"
                                    onClick={() => setIsUniversal(true)}
                                    className={`flex-1 flex items-center justify-center gap-2 px-4 py-3 border-2 font-medium transition-all ${isUniversal
                                        ? 'border-black dark:border-white bg-primary text-primary-foreground shadow-[2px_2px_0_0_#000] dark:shadow-[2px_2px_0_0_#fff]'
                                        : 'border-black/30 dark:border-white/30 hover:border-black dark:hover:border-white'
                                        }`}
                                >
                                    <Globe className="w-4 h-4" />
                                    Alle
                                </button>
                                <button
                                    type="button"
                                    onClick={() => setIsUniversal(false)}
                                    className={`flex-1 flex items-center justify-center gap-2 px-4 py-3 border-2 font-medium transition-all ${!isUniversal
                                        ? 'border-black dark:border-white bg-primary text-primary-foreground shadow-[2px_2px_0_0_#000] dark:shadow-[2px_2px_0_0_#fff]'
                                        : 'border-black/30 dark:border-white/30 hover:border-black dark:hover:border-white'
                                        }`}
                                >
                                    <Users className="w-4 h-4" />
                                    Spesifikke grupper
                                </button>
                            </div>
                        </div>

                        {/* Group selection (only shown when not universal) */}
                        {!isUniversal && (
                            <div className="space-y-2">
                                <label className="text-sm font-medium">Velg grupper</label>
                                <div className="grid grid-cols-2 gap-2">
                                    {TARGET_GROUPS.map(group => (
                                        <button
                                            key={group.value}
                                            type="button"
                                            onClick={() => toggleGroup(group.value)}
                                            className={`px-3 py-2 text-sm border-2 font-medium transition-all ${selectedGroups.includes(group.value)
                                                ? 'border-black dark:border-white bg-secondary text-secondary-foreground'
                                                : 'border-black/30 dark:border-white/30 hover:border-black dark:hover:border-white'
                                                }`}
                                        >
                                            {group.label}
                                        </button>
                                    ))}
                                </div>
                                {selectedGroups.length === 0 && (
                                    <p className="text-xs text-amber-600 dark:text-amber-400">
                                        ⚠ Velg minst én gruppe
                                    </p>
                                )}
                            </div>
                        )}

                        <div className="flex justify-end gap-2 pt-2">
                            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
                                {t('create.cancel')}
                            </Button>
                            <Button
                                type="submit"
                                disabled={submitting || !name.trim() || (!isUniversal && selectedGroups.length === 0)}
                            >
                                {submitting && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
                                {t('create.submit')}
                            </Button>
                        </div>
                    </form>

                    <DialogPrimitive.Close className="absolute right-4 top-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2">
                        <X className="h-4 w-4" />
                        <span className="sr-only">Lukk</span>
                    </DialogPrimitive.Close>
                </DialogPrimitive.Content>
            </DialogPrimitive.Portal>
        </DialogPrimitive.Root>
    );
}
