'use client';

import { useState, useEffect, useMemo } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Link } from '@/i18n/routing';
import { Plus, Lock, Unlock, Calendar, Trash2, ClipboardList, FileDown, BookOpen } from 'lucide-react';
import { deriveKey, decryptJournalEntry } from '@/utils/crypto';
import { motion } from 'framer-motion';
import { useTranslations } from 'next-intl';
import { Button } from '@/components/ui/button';
import AssessmentTaker from '@/components/journal/AssessmentTaker';
import AssessmentHistory from '@/components/journal/AssessmentHistory';
import dynamic from 'next/dynamic';

// Dynamic import for PDF generator (client-only)
const JournalReportGenerator = dynamic(
    () => import('@/components/journal/JournalReportGenerator'),
    { ssr: false }
);

type TabType = 'entries' | 'assessments' | 'export';

export default function JournalPage() {
    const t = useTranslations('Journal');
    const [entries, setEntries] = useState<any[]>([]);
    const [templates, setTemplates] = useState<any[]>([]);
    const [assessments, setAssessments] = useState<any[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [passphrase, setPassphrase] = useState('');
    const [key, setKey] = useState<CryptoKey | null>(null);
    const [isUnlocked, setIsUnlocked] = useState(false);
    const [activeTab, setActiveTab] = useState<TabType>('entries');
    const [selectedTemplate, setSelectedTemplate] = useState<any | null>(null);

    // Export selection state
    const [selectedEntryIds, setSelectedEntryIds] = useState<Set<string>>(new Set());
    const [selectedAssessmentIds, setSelectedAssessmentIds] = useState<Set<string>>(new Set());
    const [decryptedEntries, setDecryptedEntries] = useState<any[]>([]);
    const [decryptedAssessments, setDecryptedAssessments] = useState<any[]>([]);

    const supabase = createClient();

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        // Fetch journal entries
        const { data: entryData } = await supabase
            .from('journals')
            .select('id, created_at, content_encrypted, iv')
            .order('created_at', { ascending: false });

        // Fetch assessment templates
        const { data: templateData } = await supabase
            .from('assessment_templates')
            .select('*')
            .eq('is_active', true);

        // Fetch user's assessments
        const { data: assessmentData } = await supabase
            .from('journal_assessments')
            .select('*')
            .order('created_at', { ascending: false });

        if (entryData) setEntries(entryData);
        if (templateData) setTemplates(templateData);
        if (assessmentData) setAssessments(assessmentData);
        setIsLoading(false);
    };

    const handleUnlock = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!passphrase) return;

        try {
            const { data: { user } } = await supabase.auth.getUser();
            if (!user) throw new Error("Not authenticated");

            const derivedKey = await deriveKey(passphrase, user.id);
            setKey(derivedKey);
            setIsUnlocked(true);

            // Pre-decrypt entries for export
            const decrypted = await Promise.all(entries.map(async (entry) => {
                try {
                    const content = await decryptJournalEntry(entry.content_encrypted, entry.iv, derivedKey);
                    return { id: entry.id, date: entry.created_at, content };
                } catch {
                    return { id: entry.id, date: entry.created_at, content: '[DECRYPTION FAILED]' };
                }
            }));
            setDecryptedEntries(decrypted);

            // Pre-decrypt assessments for export
            const decryptedAssess = await Promise.all(assessments.map(async (a) => {
                try {
                    const responses = JSON.parse(await decryptJournalEntry(a.responses_encrypted, a.iv, derivedKey));
                    const template = templates.find(t => t.id === a.template_id);
                    return {
                        id: a.id,
                        date: a.created_at,
                        templateTitle: template?.title || 'Vurdering',
                        responses,
                        questions: template?.questions || []
                    };
                } catch {
                    return null;
                }
            }));
            setDecryptedAssessments(decryptedAssess.filter(Boolean));

        } catch (err) {
            console.error(err);
            alert(t('alerts.derive_key_failed'));
        }
    };

    const handleLock = () => {
        setKey(null);
        setPassphrase('');
        setIsUnlocked(false);
        setDecryptedEntries([]);
        setDecryptedAssessments([]);
    };

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

    const handleAssessmentComplete = () => {
        setSelectedTemplate(null);
        fetchData(); // Refresh assessments
    };

    const tabs = [
        { id: 'entries' as TabType, label: t('tab_entries') || 'Dagbok', icon: BookOpen },
        { id: 'assessments' as TabType, label: t('tab_assessments') || 'Vurderinger', icon: ClipboardList },
        { id: 'export' as TabType, label: t('tab_export') || 'Eksporter', icon: FileDown },
    ];

    return (
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12 space-y-8">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight">{t('title')}</h1>
                    <p className="text-muted-foreground mt-2">{t('subtitle')}</p>
                </div>
                <Link href="/journal/new">
                    <Button>
                        <Plus className="w-4 h-4 mr-2" />
                        {t('new_entry')}
                    </Button>
                </Link>
            </div>

            {/* Unlock / Lock Status */}
            <div className="border-2 border-black dark:border-white p-6 flex items-center justify-between">
                <div className="flex items-center gap-4">
                    <div className={`p-3 ${isUnlocked ? 'bg-green-500/10 text-green-500' : 'bg-yellow-500/10 text-yellow-500'}`}>
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
                    <Button variant="destructive" size="sm" onClick={handleLock}>
                        {t('lock_vault')}
                    </Button>
                ) : (
                    <form onSubmit={handleUnlock} className="flex gap-2">
                        <input
                            type="password"
                            value={passphrase}
                            onChange={(e) => setPassphrase(e.target.value)}
                            placeholder={t('enter_passphrase')}
                            className="bg-background border-2 border-black dark:border-white px-3 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                        />
                        <Button type="submit" size="sm">
                            {t('unlock')}
                        </Button>
                    </form>
                )}
            </div>

            {/* Tab Navigation */}
            <div className="flex border-2 border-black dark:border-white">
                {tabs.map((tab) => (
                    <button
                        key={tab.id}
                        onClick={() => setActiveTab(tab.id)}
                        className={`flex-1 flex items-center justify-center gap-2 py-3 font-medium transition-colors ${activeTab === tab.id
                            ? 'bg-primary text-primary-foreground'
                            : 'hover:bg-muted'
                            }`}
                    >
                        <tab.icon className="w-4 h-4" />
                        {tab.label}
                    </button>
                ))}
            </div>

            {/* Tab Content */}
            {activeTab === 'entries' && (
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
                        <div className="text-center py-12 text-muted-foreground border-2 border-dashed border-black/30 dark:border-white/30">
                            {t('no_entries')}
                        </div>
                    )}
                </div>
            )}

            {activeTab === 'assessments' && (
                <div className="space-y-6">
                    {/* Take New Assessment */}
                    {!selectedTemplate ? (
                        <div className="border-2 border-black dark:border-white p-6">
                            <h3 className="font-bold mb-4">{t('take_assessment') || 'Ta en vurdering'}</h3>
                            <div className="grid gap-3">
                                {templates.map((template) => (
                                    <button
                                        key={template.id}
                                        onClick={() => setSelectedTemplate(template)}
                                        className="text-left p-4 border-2 border-black dark:border-white hover:bg-muted transition-colors"
                                    >
                                        <div className="font-medium">{template.title}</div>
                                        <div className="text-sm text-muted-foreground">{template.description}</div>
                                        <div className="text-xs text-muted-foreground mt-1">
                                            {template.questions?.length || 0} {t('questions') || 'spørsmål'}
                                        </div>
                                    </button>
                                ))}
                                {templates.length === 0 && (
                                    <p className="text-muted-foreground text-center py-4">
                                        {t('no_templates') || 'Ingen vurderingsmaler tilgjengelig.'}
                                    </p>
                                )}
                            </div>
                        </div>
                    ) : (
                        <div className="space-y-4">
                            <Button variant="outline" onClick={() => setSelectedTemplate(null)}>
                                ← {t('back') || 'Tilbake'}
                            </Button>
                            <AssessmentTaker
                                template={selectedTemplate}
                                cryptoKey={key}
                                passphrase={passphrase}
                                onComplete={handleAssessmentComplete}
                                onNeedUnlock={() => alert(t('unlock_first') || 'Lås opp journalen først')}
                            />
                        </div>
                    )}

                    {/* Assessment History */}
                    {!selectedTemplate && <AssessmentHistory cryptoKey={key} />}
                </div>
            )}

            {activeTab === 'export' && (
                <div>
                    {isUnlocked ? (
                        <JournalReportGenerator
                            entries={decryptedEntries}
                            assessments={decryptedAssessments}
                            selectedEntryIds={selectedEntryIds}
                            selectedAssessmentIds={selectedAssessmentIds}
                            onToggleEntry={(id) => {
                                const newSet = new Set(selectedEntryIds);
                                if (newSet.has(id)) newSet.delete(id);
                                else newSet.add(id);
                                setSelectedEntryIds(newSet);
                            }}
                            onToggleAssessment={(id) => {
                                const newSet = new Set(selectedAssessmentIds);
                                if (newSet.has(id)) newSet.delete(id);
                                else newSet.add(id);
                                setSelectedAssessmentIds(newSet);
                            }}
                            onSelectAll={() => {
                                setSelectedEntryIds(new Set(decryptedEntries.map(e => e.id)));
                                setSelectedAssessmentIds(new Set(decryptedAssessments.map(a => a.id)));
                            }}
                            onDeselectAll={() => {
                                setSelectedEntryIds(new Set());
                                setSelectedAssessmentIds(new Set());
                            }}
                        />
                    ) : (
                        <div className="text-center py-12 border-2 border-dashed border-black/30 dark:border-white/30">
                            <Lock className="w-12 h-12 mx-auto mb-4 text-muted-foreground" />
                            <p className="text-muted-foreground">{t('unlock_to_export') || 'Lås opp journalen for å eksportere data.'}</p>
                        </div>
                    )}
                </div>
            )}
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
            className="border-2 border-black dark:border-white p-6 relative group"
        >
            <button
                onClick={() => onDelete(entry.id)}
                className="absolute top-4 right-4 p-2 opacity-0 group-hover:opacity-100 transition-opacity text-muted-foreground hover:text-destructive hover:bg-destructive/10"
                title={t('delete_entry')}
            >
                <Trash2 className="w-4 h-4" />
            </button>

            <div className="flex items-center justify-between mb-2 pr-10">
                <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <Calendar className="w-4 h-4" />
                    {new Date(entry.created_at).toLocaleDateString()} kl. {new Date(entry.created_at).toLocaleTimeString()}
                </div>
                {error && <span className="text-xs text-destructive">{t('decryption_failed')}</span>}
            </div>

            <div className="prose prose-sm max-w-none">
                {cryptoKey ? (
                    decryptedText ? (
                        <p className="whitespace-pre-wrap">{decryptedText}</p>
                    ) : (
                        <div className="h-6 w-3/4 bg-muted/50 animate-pulse" />
                    )
                ) : (
                    <div className="flex items-center gap-2 text-muted-foreground italic select-none blur-[2px]">
                        <Lock className="w-3 h-3" />
                        {t('encrypted_content')} •••••••••••••••••••••••••
                    </div>
                )}
            </div>
        </motion.div>
    );
}
