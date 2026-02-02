'use client';

import { useState } from 'react';
import { X } from 'lucide-react';
import { useTranslations } from 'next-intl';

interface NewDiscussionFormProps {
    courseId: string;
    onSubmit?: (title: string, content: string) => void;
    onCancel?: () => void;
}

export function NewDiscussionForm({ courseId, onSubmit, onCancel }: NewDiscussionFormProps) {
    const t = useTranslations('discussions');
    const [title, setTitle] = useState('');
    const [content, setContent] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleSubmit = async () => {
        if (!title.trim() || !content.trim()) return;

        setIsSubmitting(true);
        try {
            await onSubmit?.(title, content);
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className="
            p-6
            bg-white dark:bg-zinc-900
            border-3 border-black dark:border-white
            shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)]
        ">
            {/* Header */}
            <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-black uppercase">{t('new_discussion')}</h2>
                <button
                    onClick={onCancel}
                    className="p-2 hover:bg-zinc-100 dark:hover:bg-zinc-800 transition-colors"
                >
                    <X className="w-5 h-5" />
                </button>
            </div>

            {/* Form */}
            <div className="space-y-4">
                <div>
                    <label className="block text-sm font-bold uppercase mb-2">
                        {t('title')}
                    </label>
                    <input
                        type="text"
                        value={title}
                        onChange={(e) => setTitle(e.target.value)}
                        placeholder={t('title_placeholder')}
                        className="
                            w-full p-3
                            bg-zinc-50 dark:bg-zinc-800
                            border-2 border-black dark:border-white
                            font-medium
                            focus:outline-none focus:ring-2 focus:ring-blue-500
                        "
                    />
                </div>

                <div>
                    <label className="block text-sm font-bold uppercase mb-2">
                        {t('content')}
                    </label>
                    <textarea
                        value={content}
                        onChange={(e) => setContent(e.target.value)}
                        placeholder={t('content_placeholder')}
                        rows={6}
                        className="
                            w-full p-3
                            bg-zinc-50 dark:bg-zinc-800
                            border-2 border-black dark:border-white
                            font-medium
                            resize-none
                            focus:outline-none focus:ring-2 focus:ring-blue-500
                        "
                    />
                </div>

                <div className="flex justify-end gap-3 pt-4">
                    <button
                        onClick={onCancel}
                        className="
                            px-4 py-2
                            bg-white dark:bg-zinc-900
                            text-black dark:text-white
                            font-bold uppercase text-sm
                            border-2 border-black dark:border-white
                            hover:bg-zinc-100 dark:hover:bg-zinc-800
                            transition-colors
                        "
                    >
                        {t('cancel')}
                    </button>
                    <button
                        onClick={handleSubmit}
                        disabled={!title.trim() || !content.trim() || isSubmitting}
                        className="
                            px-4 py-2
                            bg-black dark:bg-white
                            text-white dark:text-black
                            font-bold uppercase text-sm
                            border-2 border-black dark:border-white
                            disabled:opacity-50 disabled:cursor-not-allowed
                            hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:-translate-x-0.5 hover:-translate-y-0.5
                            transition-all duration-200
                        "
                    >
                        {isSubmitting ? t('posting') : t('post')}
                    </button>
                </div>
            </div>
        </div>
    );
}
