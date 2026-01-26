'use client';

import { useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Copy, RefreshCw, Plus, Users } from 'lucide-react';
import { toast } from 'sonner';

import { useTranslations } from 'next-intl';

type UserCategory = 'søsken' | 'foreldre' | 'helsepersonell';
type TargetGroup = 'sibling' | 'parent' | 'team-member' | 'team-leader';

const TARGET_GROUP_LABELS: Record<TargetGroup, string> = {
    'sibling': 'Søsken (kan se søskenkurs)',
    'parent': 'Foreldre (kan se foreldrekurs)',
    'team-member': 'Team-medlem (kan se medarbeider-kurs)',
    'team-leader': 'Leder (kan se leder-kurs)'
};

export default function InvitationManager() {
    const t = useTranslations('Invites.create');
    const tTips = useTranslations('Invites.tips');
    const [isLoading, setIsLoading] = useState(false);
    const [userCategory, setUserCategory] = useState<UserCategory>('søsken');
    const [targetGroup, setTargetGroup] = useState<TargetGroup>('sibling');
    const [subgroup, setSubgroup] = useState('');
    const [maxUses, setMaxUses] = useState(10);
    const [expiresIn, setExpiresIn] = useState(90);
    const [generatedCode, setGeneratedCode] = useState<{
        code: string;
        category: string;
        targetGroup: string;
        subgroup: string;
        expires: string;
    } | null>(null);

    const supabase = createClient();

    const handleCreateInvitation = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);

        try {

            const { data, error } = await supabase.rpc('create_invitation', {
                p_user_category: userCategory,
                p_target_group: targetGroup,
                p_max_uses: maxUses,
                p_expires_in_days: expiresIn
            });

            if (error) throw error;

            if (data && data.length > 0) {
                const invite = data[0];
                setGeneratedCode({
                    code: invite.code,
                    category: invite.user_category,
                    targetGroup: invite.target_group || targetGroup,
                    subgroup: invite.subgroup || '',
                    expires: new Date(invite.expires_at).toLocaleDateString()
                });
                toast.success(t('success'));

                // Clear subgroup but keep category to allow quick creation
                setSubgroup('');
            }
        } catch (error: any) {
            console.error('Error creating invitation:', error);
            toast.error(t('alerts.create_error') + error.message);
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

                <form onSubmit={handleCreateInvitation} className="space-y-4">
                    <div className="space-y-2">
                        <label className="text-sm font-medium">{t('category_label')}</label>
                        <select
                            value={userCategory}
                            onChange={(e) => setUserCategory(e.target.value as UserCategory)}
                            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background disabled:cursor-not-allowed disabled:opacity-50"
                        >
                            <option value="søsken">Søsken (Siblings)</option>
                            <option value="foreldre">Foreldre (Parents)</option>
                            <option value="helsepersonell">Helsepersonell (Healthcare)</option>
                        </select>
                    </div>

                    <div className="space-y-2">
                        <label className="text-sm font-medium">Tilgang til kurs</label>
                        <select
                            value={targetGroup}
                            onChange={(e) => setTargetGroup(e.target.value as TargetGroup)}
                            className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background disabled:cursor-not-allowed disabled:opacity-50"
                        >
                            {Object.entries(TARGET_GROUP_LABELS).map(([value, label]) => (
                                <option key={value} value={value}>{label}</option>
                            ))}
                        </select>
                        <p className="text-xs text-muted-foreground">
                            Bestemmer hvilke kurs brukeren får tilgang til
                        </p>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div className="space-y-2">
                            <label className="text-sm font-medium">{t('max_uses_label')}</label>
                            <input
                                type="number"
                                value={maxUses}
                                onChange={(e) => setMaxUses(parseInt(e.target.value))}
                                min={1}
                                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                            />
                        </div>
                        <div className="space-y-2">
                            <label className="text-sm font-medium">{t('expires_label')}</label>
                            <input
                                type="number"
                                value={expiresIn}
                                onChange={(e) => setExpiresIn(parseInt(e.target.value))}
                                min={1}
                                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
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
                                {t('expires_at')} {generatedCode.expires}
                            </span>
                        </div>

                        <div className="flex flex-col items-center justify-center p-8 bg-background rounded-xl border border-dashed border-primary/30 mb-4">
                            <div className="text-4xl font-mono font-bold tracking-wider mb-2 text-foreground">
                                {generatedCode.code}
                            </div>
                            <div className="flex items-center gap-2 text-sm text-muted-foreground">
                                <span className="capitalize">{generatedCode.category}</span>
                                <span>•</span>
                                <span className="font-medium text-foreground">
                                    {TARGET_GROUP_LABELS[generatedCode.targetGroup as TargetGroup] || generatedCode.targetGroup}
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
                            {tTips('tip1')}
                        </li>
                        <li className="flex gap-2">
                            <span className="text-primary">•</span>
                            {tTips('tip2')}
                        </li>
                        <li className="flex gap-2">
                            <span className="text-primary">•</span>
                            {tTips('tip3')}
                        </li>
                    </ul>
                </Card>
            </div>
        </div>
    );
}
