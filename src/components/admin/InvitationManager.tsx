'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Copy, RefreshCw, Plus, Users, Building2 } from 'lucide-react';
import { toast } from 'sonner';
import { useTranslations } from 'next-intl';

type TargetGroup = 'sibling' | 'parent' | 'team-member' | 'team-leader';

interface GroupInfo {
    id: TargetGroup;
    label: string;
    description: string;
}

const MAIN_GROUPS: GroupInfo[] = [
    { id: 'sibling', label: 'Søsken', description: 'Søsken av pasienter' },
    { id: 'parent', label: 'Foreldre', description: 'Foreldre og foresatte' },
    { id: 'team-member', label: 'Team-medlem', description: 'Ansatte og fagpersoner' },
    { id: 'team-leader', label: 'Team-leder', description: 'Ledere og koordinatorer' }
];

interface Subgroup {
    name: string;
    count: number;
}

export default function InvitationManager() {
    const t = useTranslations('Invites.create');
    const tTips = useTranslations('Invites.tips');
    const [isLoading, setIsLoading] = useState(false);
    const [targetGroup, setTargetGroup] = useState<TargetGroup>('sibling');
    const [subgroup, setSubgroup] = useState('');
    const [maxUses, setMaxUses] = useState(10);
    const [expiresIn, setExpiresIn] = useState(90);
    const [existingSubgroups, setExistingSubgroups] = useState<Subgroup[]>([]);
    const [generatedCode, setGeneratedCode] = useState<{
        code: string;
        targetGroup: string;
        subgroup: string;
        expires: string;
    } | null>(null);

    const supabase = createClient();

    // Fetch existing subgroups for the selected target group
    useEffect(() => {
        async function fetchSubgroups() {
            const { data } = await supabase
                .from('profiles')
                .select('subgroup')
                .not('subgroup', 'is', null);

            if (data) {
                const counts = data.reduce((acc: Record<string, number>, row) => {
                    if (row.subgroup) {
                        acc[row.subgroup] = (acc[row.subgroup] || 0) + 1;
                    }
                    return acc;
                }, {});

                setExistingSubgroups(
                    Object.entries(counts).map(([name, count]) => ({ name, count }))
                );
            }
        }
        fetchSubgroups();
    }, []);

    const handleCreateInvitation = async (e: React.FormEvent) => {
        e.preventDefault();

        if (!subgroup.trim()) {
            toast.error('Undergruppe er påkrevd');
            return;
        }

        setIsLoading(true);

        try {
            // Map target_group to legacy user_category for backward compatibility
            const legacyCategory = targetGroup === 'sibling' ? 'søsken' :
                targetGroup === 'parent' ? 'foreldre' :
                    'helsepersonell';

            const { data, error } = await supabase.rpc('create_invitation', {
                p_user_category: legacyCategory,
                p_subgroup: subgroup.trim(),
                p_target_group: targetGroup,
                p_max_uses: maxUses,
                p_expires_in_days: expiresIn
            });

            if (error) throw error;

            if (data && data.length > 0) {
                const invite = data[0];
                setGeneratedCode({
                    code: invite.code,
                    targetGroup: targetGroup,
                    subgroup: subgroup.trim(),
                    expires: new Date(invite.expires_at).toLocaleDateString('no-NO')
                });
                toast.success(t('success'));
            }
        } catch (error: unknown) {
            console.error('Error creating invitation:', error);
            const errMsg = error instanceof Error ? error.message : 'Ukjent feil';
            toast.error(`${t('alerts.create_error')}: ${errMsg}`);
        } finally {
            setIsLoading(false);
        }
    };

    const copyToClipboard = () => {
        if (generatedCode) {
            navigator.clipboard.writeText(generatedCode.code);
            toast.success(t('alerts.code_copied'));
        }
    };

    const selectedGroupInfo = MAIN_GROUPS.find(g => g.id === targetGroup);

    return (
        <div className="grid gap-8 md:grid-cols-2">
            {/* Create Invitation Form */}
            <Card className="p-6">
                <div className="flex items-center gap-2 mb-6">
                    <div className="p-2 bg-primary/10 rounded-lg">
                        <Plus className="w-5 h-5 text-primary" />
                    </div>
                    <h2 className="text-xl font-bold">{t('title')}</h2>
                </div>

                <form onSubmit={handleCreateInvitation} className="space-y-5">
                    {/* Main Group Selection */}
                    <div className="space-y-2">
                        <label className="text-sm font-medium">Hovedgruppe</label>
                        <div className="grid grid-cols-2 gap-2">
                            {MAIN_GROUPS.map((group) => (
                                <button
                                    key={group.id}
                                    type="button"
                                    onClick={() => setTargetGroup(group.id)}
                                    className={`p-3 rounded-lg border text-left transition-all ${targetGroup === group.id
                                            ? 'border-primary bg-primary/10 ring-2 ring-primary/20'
                                            : 'border-input hover:border-primary/50'
                                        }`}
                                >
                                    <div className="font-medium text-sm">{group.label}</div>
                                    <div className="text-xs text-muted-foreground">{group.description}</div>
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* Subgroup Input */}
                    <div className="space-y-2">
                        <label className="text-sm font-medium flex items-center gap-2">
                            <Building2 className="w-4 h-4 text-muted-foreground" />
                            Undergruppe (Organisasjon)
                        </label>
                        <input
                            type="text"
                            value={subgroup}
                            onChange={(e) => setSubgroup(e.target.value)}
                            placeholder="F.eks: NFTSC, Sykehus X, Test"
                            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                            required
                        />
                        <p className="text-xs text-muted-foreground">
                            Brukere i samme undergruppe kan se hverandres kommentarer
                        </p>

                        {/* Quick select existing subgroups */}
                        {existingSubgroups.length > 0 && (
                            <div className="flex flex-wrap gap-1 mt-2">
                                {existingSubgroups.slice(0, 5).map((sg) => (
                                    <button
                                        key={sg.name}
                                        type="button"
                                        onClick={() => setSubgroup(sg.name)}
                                        className="text-xs px-2 py-1 rounded bg-muted hover:bg-muted/80 transition-colors"
                                    >
                                        {sg.name} ({sg.count})
                                    </button>
                                ))}
                            </div>
                        )}
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <label className="text-sm font-medium">{t('max_uses_label')}</label>
                            <input
                                type="number"
                                value={maxUses}
                                onChange={(e) => setMaxUses(parseInt(e.target.value))}
                                min={1}
                                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                            />
                        </div>
                        <div className="space-y-2">
                            <label className="text-sm font-medium">{t('expires_label')}</label>
                            <input
                                type="number"
                                value={expiresIn}
                                onChange={(e) => setExpiresIn(parseInt(e.target.value))}
                                min={1}
                                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm"
                            />
                        </div>
                    </div>

                    <Button type="submit" className="w-full" disabled={isLoading}>
                        {isLoading ? (
                            <>
                                <RefreshCw className="mr-2 h-4 w-4 animate-spin" />
                                {t('generating')}
                            </>
                        ) : (
                            t('generate_btn')
                        )}
                    </Button>
                </form>
            </Card>

            {/* Generated Code Display */}
            <div className="space-y-6">
                {generatedCode && (
                    <Card className="p-6 border-primary/50 bg-primary/5">
                        <div className="flex items-center justify-between mb-4">
                            <h3 className="font-semibold text-lg text-primary">{t('result_title')}</h3>
                            <span className="text-xs font-mono bg-background px-2 py-1 rounded border">
                                Utløper {generatedCode.expires}
                            </span>
                        </div>

                        <div className="flex flex-col items-center justify-center p-8 bg-background rounded-xl border border-dashed border-primary/30 mb-4">
                            <div className="text-4xl font-mono font-bold tracking-wider mb-3 text-foreground">
                                {generatedCode.code}
                            </div>
                            <div className="flex flex-col items-center gap-1 text-sm">
                                <span className="font-medium text-foreground">
                                    {selectedGroupInfo?.label}
                                </span>
                                <span className="text-muted-foreground flex items-center gap-1">
                                    <Building2 className="w-3 h-3" />
                                    {generatedCode.subgroup}
                                </span>
                            </div>
                        </div>

                        <Button
                            variant="outline"
                            className="w-full"
                            onClick={copyToClipboard}
                        >
                            <Copy className="mr-2 h-4 w-4" />
                            {t('copy_btn')}
                        </Button>
                    </Card>
                )}

                <Card className="p-6">
                    <div className="flex items-center gap-2 mb-4">
                        <Users className="w-5 h-5 text-muted-foreground" />
                        <h3 className="font-semibold">{tTips('title')}</h3>
                    </div>
                    <ul className="space-y-3 text-sm text-muted-foreground">
                        <li className="flex gap-2">
                            <span className="text-primary">•</span>
                            Hver hovedgruppe har separat kurstilgang
                        </li>
                        <li className="flex gap-2">
                            <span className="text-primary">•</span>
                            Undergrupper deler kommentarer og diskusjoner
                        </li>
                        <li className="flex gap-2">
                            <span className="text-primary">•</span>
                            Team-medlem og Team-leder med samme undergruppe er fortsatt separate
                        </li>
                    </ul>
                </Card>
            </div>
        </div>
    );
}
