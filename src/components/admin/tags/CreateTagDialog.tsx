'use client';

import { useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Button } from '@/components/ui/button';
import { X, Loader2 } from 'lucide-react';
import { toast } from 'sonner';
import { cn } from '@/lib/utils';
import * as DialogPrimitive from '@radix-ui/react-dialog';
import { useTranslations } from 'next-intl';

interface CreateTagDialogProps {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    onSuccess: () => void;
}

export default function CreateTagDialog({ open, onOpenChange, onSuccess }: CreateTagDialogProps) {
    const t = useTranslations('AdminTags');
    const [name, setName] = useState('');
    const [submitting, setSubmitting] = useState(false);
    const supabase = createClient();

    const slugify = (text: string) => {
        return text
            .toString()
            .toLowerCase()
            .replace(/\s+/g, '-')           // Replace spaces with -
            .replace(/[^\w\-]+/g, '')       // Remove all non-word chars
            .replace(/\-\-+/g, '-')         // Replace multiple - with single -
            .replace(/^-+/, '')             // Trim - from start of text
            .replace(/-+$/, '');            // Trim - from end of text
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
                .insert({ name: name.trim(), slug });

            if (error) throw error;

            toast.success(t('alerts.create_success'));
            setName('');
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
                <DialogPrimitive.Content className="fixed left-[50%] top-[50%] z-50 w-full max-w-md translate-x-[-50%] translate-y-[-50%] gap-4 border bg-background p-6 shadow-lg duration-200 sm:rounded-lg animate-in fade-in-0 zoom-in-95">
                    <div className="flex flex-col gap-1.5 text-center sm:text-left">
                        <DialogPrimitive.Title className="text-lg font-semibold leading-none tracking-tight">
                            {t('create.title')}
                        </DialogPrimitive.Title>
                        <DialogPrimitive.Description className="text-sm text-muted-foreground">
                            {t('create.desc')}
                        </DialogPrimitive.Description>
                    </div>

                    <form onSubmit={handleSubmit} className="mt-4 space-y-4">
                        <div className="space-y-2">
                            <label className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
                                {t('create.name_label')}
                            </label>
                            <input
                                type="text"
                                value={name}
                                onChange={(e) => setName(e.target.value)}
                                placeholder={t('create.placeholder')}
                                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                                autoFocus
                            />
                            {name && (
                                <p className="text-xs text-muted-foreground">
                                    {t('create.slug_preview')} <span className="font-mono">{slugify(name)}</span>
                                </p>
                            )}
                        </div>

                        <div className="flex justify-end gap-2">
                            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
                                {t('create.cancel')}
                            </Button>
                            <Button type="submit" disabled={submitting || !name.trim()}>
                                {submitting && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
                                {t('create.submit')}
                            </Button>
                        </div>
                    </form>

                    <DialogPrimitive.Close className="absolute right-4 top-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none data-[state=open]:bg-accent data-[state=open]:text-muted-foreground">
                        <X className="h-4 w-4" />
                        <span className="sr-only">Lukk</span>
                    </DialogPrimitive.Close>
                </DialogPrimitive.Content>
            </DialogPrimitive.Portal>
        </DialogPrimitive.Root>
    );
}
