'use client';

import { useState } from 'react';
import { useRouter } from '@/i18n/routing';
import { createClient } from '@/utils/supabase/client';
import { deriveKey, encryptJournalEntry } from '@/utils/crypto';
import { ArrowLeft, Save, Lock, Loader2 } from 'lucide-react';
import { Link } from '@/i18n/routing';

export default function NewJournalEntry() {
    const router = useRouter();
    const supabase = createClient();

    const [content, setContent] = useState('');
    const [passphrase, setPassphrase] = useState('');
    const [isEncrypting, setIsEncrypting] = useState(false);

    const handleSave = async () => {
        if (!content || !passphrase) return;
        setIsEncrypting(true);

        try {
            const user = (await supabase.auth.getUser()).data.user;
            if (!user) throw new Error("Not authenticated");

            // 1. Derive Key
            const key = await deriveKey(passphrase);

            // 2. Encrypt
            const { ciphertext, iv } = await encryptJournalEntry(content, key);

            // 3. Save to Supabase
            const { error } = await supabase.from('journals').insert({
                user_id: user.id,
                content_encrypted: ciphertext,
                iv: iv
            });

            if (error) throw error;

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
        <div className="max-w-2xl mx-auto px-4 py-12 space-y-8">
            {/* Header */}
            <div className="flex items-center justify-between">
                <Link href="/journal" className="p-2 hover:bg-muted rounded-full transition-colors">
                    <ArrowLeft className="w-5 h-5 text-muted-foreground" />
                </Link>
                <h1 className="text-xl font-bold">New Journal Entry</h1>
                <div className="w-9" /> {/* Spacer for alignment */}
            </div>

            <div className="glass p-6 rounded-2xl border border-white/10 space-y-6">

                <div className="space-y-2">
                    <label className="text-sm font-medium text-muted-foreground">
                        Journal Content
                    </label>
                    <textarea
                        value={content}
                        onChange={(e) => setContent(e.target.value)}
                        placeholder="Write your thoughts..."
                        className="flex w-full min-h-[300px] rounded-lg border border-input bg-background/50 px-4 py-4 text-base ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring resize-none"
                    />
                </div>

                <div className="pt-4 border-t border-white/10 space-y-4">
                    <div className="flex items-center gap-2 text-yellow-500 bg-yellow-500/10 p-3 rounded-lg text-xs">
                        <Lock className="w-4 h-4" />
                        <span>
                            <strong>Zero-Knowledge Encryption:</strong> You must enter a passphrase to save this entry.
                            If you forget this passphrase, this entry will be lost forever.
                        </span>
                    </div>

                    <div className="space-y-2">
                        <label className="text-sm font-medium">Encryption Passphrase</label>
                        <input
                            type="password"
                            value={passphrase}
                            onChange={(e) => setPassphrase(e.target.value)}
                            placeholder="Enter a secure passphrase"
                            className="flex h-10 w-full rounded-md border border-input bg-background/50 px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                        />
                    </div>

                    <button
                        onClick={handleSave}
                        disabled={isEncrypting || !content || !passphrase}
                        className="w-full flex items-center justify-center gap-2 bg-primary text-primary-foreground h-11 rounded-md font-medium hover:bg-primary/90 transition-colors disabled:opacity-50"
                    >
                        {isEncrypting ? <Loader2 className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                        Encrypt & Save
                    </button>
                </div>
            </div>
        </div>
    );
}
