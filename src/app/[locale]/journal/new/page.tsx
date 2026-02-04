'use client';

import { useState, useEffect, useCallback } from 'react';
import { useRouter } from '@/i18n/routing';
import { createClient } from '@/utils/supabase/client';
import { deriveKey, encryptJournalEntry } from '@/utils/crypto';
import { ArrowLeft, Save, Lock, Loader2, Check } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { useTranslations } from 'next-intl';

export default function NewJournalEntry() {
    const t = useTranslations('Journal');
    const router = useRouter();
    const supabase = createClient();

    const [content, setContent] = useState('');
    const [passphrase, setPassphrase] = useState('');
    const [isEncrypting, setIsEncrypting] = useState(false);
    const [autoSaveStatus, setAutoSaveStatus] = useState<'idle' | 'saving' | 'saved'>('idle');

    // Auto-save to localStorage
    const autoSave = useCallback(() => {
        if (content) {
            localStorage.setItem('journal_draft', content);
            setAutoSaveStatus('saving');
            setTimeout(() => setAutoSaveStatus('saved'), 300);
            setTimeout(() => setAutoSaveStatus('idle'), 2000);
        }
    }, [content]);

    // Debounced auto-save
    useEffect(() => {
        const timer = setTimeout(autoSave, 1000);
        return () => clearTimeout(timer);
    }, [content, autoSave]);

    // Load draft on mount
    useEffect(() => {
        const draft = localStorage.getItem('journal_draft');
        if (draft && !content) {
            setContent(draft);
        }
    }, []);

    const handleSave = async () => {
        if (!content || !passphrase) return;
        setIsEncrypting(true);

        try {
            const user = (await supabase.auth.getUser()).data.user;
            if (!user) throw new Error("Not authenticated");

            // 1. Derive Key
            const key = await deriveKey(passphrase, user.id);

            // 2. Encrypt
            const { ciphertext, iv } = await encryptJournalEntry(content, key);

            // 3. Save to Supabase
            const { error } = await supabase.from('journals').insert({
                user_id: user.id,
                content_encrypted: ciphertext,
                iv: iv
            });

            if (error) throw error;

            // Clear draft on successful save
            localStorage.removeItem('journal_draft');

            router.push('/journal');
            router.refresh();
        } catch (err) {
            console.error(err);
            alert('Failed to save encrypted entry.');
        } finally {
            setIsEncrypting(false);
        }
    };

    return (
        <div className="min-h-screen flex flex-col md:block md:min-h-0">
            {/* Mobile: Fullscreen layout */}
            <div className="flex-1 flex flex-col max-w-2xl mx-auto px-4 py-4 md:py-12 w-full">
                {/* Header */}
                <div className="flex items-center justify-between mb-4 md:mb-8">
                    <Link href="/journal" className="p-2 hover:bg-muted rounded-full transition-colors">
                        <ArrowLeft className="w-5 h-5 text-muted-foreground" />
                    </Link>
                    <h1 className="text-lg md:text-xl font-bold">{t('new_entry')}</h1>

                    {/* Auto-save indicator */}
                    <div className="w-20 flex justify-end">
                        {autoSaveStatus === 'saving' && (
                            <span className="text-xs text-muted-foreground flex items-center gap-1">
                                <Loader2 className="w-3 h-3 animate-spin" />
                                <span className="hidden sm:inline">Lagrer...</span>
                            </span>
                        )}
                        {autoSaveStatus === 'saved' && (
                            <span className="text-xs text-green-600 flex items-center gap-1">
                                <Check className="w-3 h-3" />
                                <span className="hidden sm:inline">Lagret lokalt</span>
                            </span>
                        )}
                    </div>
                </div>

                {/* Main Content */}
                <div className="flex-1 flex flex-col space-y-4">
                    {/* Textarea - Fullscreen on mobile */}
                    <div className="flex-1 flex flex-col">
                        <textarea
                            value={content}
                            onChange={(e) => setContent(e.target.value)}
                            placeholder={t('write_here')}
                            className="flex-1 w-full min-h-[200px] md:min-h-[300px] rounded-lg border-2 border-black dark:border-white bg-background/50 px-4 py-4 text-base ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring resize-none"
                        />
                    </div>

                    {/* Encryption Section - Collapsible on mobile */}
                    <div className="space-y-4 bg-card rounded-lg border-2 border-black dark:border-white p-4">
                        <div className="flex items-center gap-2 text-yellow-600 dark:text-yellow-500 text-xs">
                            <Lock className="w-4 h-4 shrink-0" />
                            <span>
                                <strong>Null-kunnskap:</strong> Passordfrase kreves for å lagre.
                            </span>
                        </div>

                        <input
                            type="password"
                            value={passphrase}
                            onChange={(e) => setPassphrase(e.target.value)}
                            placeholder="Skriv din passordfrase..."
                            className="flex h-10 w-full rounded-md border-2 border-black dark:border-white bg-background/50 px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                        />
                    </div>
                </div>
            </div>

            {/* Sticky Save Button - Always visible at bottom on mobile */}
            <div className="sticky bottom-0 bg-background border-t-2 border-black dark:border-white p-4 md:relative md:border-t-0 md:mt-0">
                <div className="max-w-2xl mx-auto">
                    <button
                        onClick={handleSave}
                        disabled={isEncrypting || !content || !passphrase}
                        className="w-full flex items-center justify-center gap-2 bg-primary text-primary-foreground h-12 md:h-11 rounded-lg font-medium hover:bg-primary/90 transition-colors disabled:opacity-50 border-2 border-black dark:border-white"
                    >
                        {isEncrypting ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                        {isEncrypting ? t('saving') : t('save_assessment')}
                    </button>
                </div>
            </div>
        </div>
    );
}
