'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Link } from '@/i18n/routing';
import { Plus, Lock, Unlock, Calendar, Trash2 } from 'lucide-react';
import { deriveKey, decryptJournalEntry } from '@/utils/crypto';
import { motion } from 'framer-motion';
import { useTranslations } from 'next-intl';

export default function JournalPage() {
    const t = useTranslations('Journal');
    const [entries, setEntries] = useState<any[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [passphrase, setPassphrase] = useState('');
    const [key, setKey] = useState<CryptoKey | null>(null);
    const [isUnlocked, setIsUnlocked] = useState(false);
    const supabase = createClient();

    useEffect(() => {
        fetchEntries();
    }, []);

    const fetchEntries = async () => {
        const { data } = await supabase
            .from('journals')
            .select('id, created_at, content_encrypted, iv')
            .order('created_at', { ascending: false });

        if (data) setEntries(data);
        setIsLoading(false);
    };

    const handleUnlock = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!passphrase) return;

        try {
            const derivedKey = await deriveKey(passphrase);
            setKey(derivedKey);
            setIsUnlocked(true);
            // Ideally tests if key is correct by trying to decrypt one item or a check-hash
        } catch (err) {
            console.error(err);
            alert(t('alerts.derive_key_failed'));
        }
    };

    const handleExport = async () => {
        if (!passphrase) {
            alert(t('alerts.enter_passphrase'));
            return;
        }

        try {
            const derivedKey = key || await deriveKey(passphrase);
            if (!derivedKey) throw new Error("No key derived");

            const decryptedEntries = await Promise.all(entries.map(async (entry) => {
                try {
                    const content = await decryptJournalEntry(entry.content_encrypted, entry.iv, derivedKey);
                    return {
                        date: entry.created_at,
                        content: content
                    };
                } catch (e) {
                    return {
                        date: entry.created_at,
                        content: "[DECRYPTION FAILED]"
                    };
                }
            }));

            const blob = new Blob([JSON.stringify(decryptedEntries, null, 2)], { type: "application/json" });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `journal-export-${new Date().toISOString().split('T')[0]}.json`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        } catch (e) {
            console.error(e);
            alert(t('alerts.export_failed'));
        }
    };

    const handleLock = () => {
        setKey(null);
        setPassphrase('');
        setIsUnlocked(false);
    }

    const handleDelete = async (entryId: string) => {
        if (!confirm(t('alerts.delete_confirm'))) return;

        try {
            const { error } = await supabase
                .from('journals')
                .delete()
                .eq('id', entryId);

            if (error) throw error;

            setEntries(entries.filter(e => e.id !== entryId));
        } catch (err) {
            console.error(err);
            alert(t('alerts.delete_failed'));
        }
    };

    return (
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12 space-y-8">

            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">{t('title')}</h1>
                    <p className="text-muted-foreground mt-2">{t('subtitle')}</p>
                </div>
                <div className="flex gap-2">
                    {isUnlocked && (
                        <button
                            onClick={handleExport}
                            className="flex items-center gap-2 bg-secondary text-secondary-foreground px-4 py-2 rounded-lg font-medium hover:bg-secondary/80 transition-colors border border-input"
                        >
                            {t('export_data')}
                        </button>
                    )}
                    <Link
                        href="/journal/new"
                        className="flex items-center gap-2 bg-primary text-primary-foreground px-4 py-2 rounded-lg font-medium hover:bg-primary/90 transition-colors shadow-lg shadow-primary/20"
                    >
                        <Plus className="w-4 h-4" />
                        {t('new_entry')}
                    </Link>
                </div>
            </div>

            {/* Unlock / Lock Status */}
            <div className="glass p-6 rounded-xl border border-white/10 flex items-center justify-between">
                <div className="flex items-center gap-4">
                    <div className={`p-3 rounded-full ${isUnlocked ? 'bg-green-500/10 text-green-500' : 'bg-yellow-500/10 text-yellow-500'}`}>
                        {isUnlocked ? <Unlock className="w-6 h-6" /> : <Lock className="w-6 h-6" />}
                    </div>
                    <div>
                        <h3 className="font-semibold">{isUnlocked ? t('vault_unlocked') : t('vault_locked')}</h3>
                        <p className="text-sm text-muted-foreground">
                            {isUnlocked ? t('vault_unlocked_desc') : t('vault_locked_desc')}
                        </p>
                    </div>
                </div>

                {isUnlocked ? (
                    <button onClick={handleLock} className="text-sm font-medium text-destructive hover:underline">
                        {t('lock_vault')}
                    </button>
                ) : (
                    <form onSubmit={handleUnlock} className="flex gap-2">
                        <input
                            type="password"
                            value={passphrase}
                            onChange={(e) => setPassphrase(e.target.value)}
                            placeholder={t('enter_passphrase')}
                            className="bg-background/50 border border-input rounded-md px-3 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                        />
                        <button type="submit" className="px-3 py-1 bg-secondary text-secondary-foreground rounded-md text-sm font-medium hover:bg-secondary/80">
                            {t('unlock')}
                        </button>
                    </form>
                )}
            </div>

            {/* Entries List */}
            <div className="grid gap-4">
                {entries.map((entry) => (
                    <JournalEntryCard
                        key={entry.id}
                        entry={entry}
                        cryptoKey={key}
                        onDelete={handleDelete}
                    />
                ))}
                {entries.length === 0 && !isLoading && (
                    <div className="text-center py-12 text-muted-foreground">
                        {t('no_entries')}
                    </div>
                )}
            </div>
        </div>
    );
}

function JournalEntryCard({ entry, cryptoKey, onDelete }: { entry: any, cryptoKey: CryptoKey | null, onDelete: (id: string) => void }) {
    const t = useTranslations('Journal');
    const [decryptedText, setDecryptedText] = useState<string | null>(null);
    const [error, setError] = useState(false);

    useEffect(() => {
        if (cryptoKey && entry.content_encrypted) {
            decryptJournalEntry(entry.content_encrypted, entry.iv, cryptoKey)
                .then(text => setDecryptedText(text))
                .catch(err => setError(true));
        } else {
            setDecryptedText(null);
            setError(false);
        }
    }, [cryptoKey, entry]);

    return (
        <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="glass p-6 rounded-xl border border-white/10 hover:border-primary/20 transition-colors relative group"
        >
            <button
                onClick={() => onDelete(entry.id)}
                className="absolute top-4 right-4 p-2 opacity-0 group-hover:opacity-100 transition-opacity text-muted-foreground hover:text-destructive rounded-md hover:bg-destructive/10"
                title={t('delete_entry')}
            >
                <Trash2 className="w-4 h-4" />
            </button>

            <div className="flex items-center justify-between mb-2 pr-10">
                <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <Calendar className="w-4 h-4" />
                    {new Date(entry.created_at).toLocaleDateString()} at {new Date(entry.created_at).toLocaleTimeString()}
                </div>
                {error && <span className="text-xs text-destructive">{t('decryption_failed')}</span>}
            </div>

            <div className="prose prose-sm prose-invert max-w-none">
                {cryptoKey ? (
                    decryptedText ? (
                        <p className="whitespace-pre-wrap">{decryptedText}</p>
                    ) : (
                        <div className="h-6 w-3/4 bg-muted/50 animate-pulse rounded" />
                    )
                ) : (
                    <div className="flex items-center gap-2 text-muted-foreground italic select-none blur-[2px]">
                        <Lock className="w-3 h-3" />
                        {t('encrypted_content')} •••••••••••••••••••••••••
                    </div>
                )}
            </div>
        </motion.div>
    )
}
