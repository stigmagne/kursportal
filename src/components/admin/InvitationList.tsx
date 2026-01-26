'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { RefreshCw, Clock, Users, Copy, Trash2 } from 'lucide-react';
import { toast } from 'sonner';

import { useTranslations } from 'next-intl';

type Invitation = {
    id: string;
    code: string;
    user_category: string;
    target_group: string | null;
    subgroup: string;
    max_uses: number;
    used_count: number;
    expires_at: string;
    created_at: string;
};

const TARGET_GROUP_LABELS: Record<string, string> = {
    'sibling': 'Søsken',
    'parent': 'Foreldre',
    'team-member': 'Team-medlem',
    'team-leader': 'Leder'
};

export default function InvitationList() {
    const t = useTranslations('Invites.list');
    const [invitations, setInvitations] = useState<Invitation[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const supabase = createClient();

    const fetchInvitations = async () => {
        setIsLoading(true);
        try {
            const { data, error } = await supabase
                .from('invitations')
                .select('*')
                .order('created_at', { ascending: false });

            if (error) throw error;
            setInvitations(data || []);
        } catch (error) {
            console.error('Error fetching invitations:', error);
            toast.error('Failed to load invitations');
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        fetchInvitations();
    }, []);

    const copyCode = (code: string) => {
        navigator.clipboard.writeText(code);
        toast.success('Code copied!');
    };

    const isExpired = (dateString: string) => {
        return new Date(dateString) < new Date();
    };

    const isFullyUsed = (used: number, max: number) => {
        return used >= max;
    };

    if (isLoading) {
        return (
            <div className="flex items-center justify-center py-12">
                <RefreshCw className="w-6 h-6 animate-spin text-muted-foreground" />
            </div>
        );
    }

    return (
        <Card className="overflow-hidden">
            <div className="p-6 border-b flex justify-between items-center bg-muted/30">
                <h3 className="font-semibold text-lg">{t('title')}</h3>
                <Button variant="ghost" size="sm" onClick={fetchInvitations}>
                    <RefreshCw className="w-4 h-4 mr-2" />
                    {t('refresh')}
                </Button>
            </div>

            <div className="overflow-x-auto">
                <table className="w-full text-sm text-left">
                    <thead className="text-xs text-muted-foreground uppercase bg-muted/50 border-b">
                        <tr>
                            <th className="px-6 py-3 font-medium">{t('cols.code')}</th>
                            <th className="px-6 py-3 font-medium">{t('cols.group')}</th>
                            <th className="px-6 py-3 font-medium">Kurstilgang</th>
                            <th className="px-6 py-3 font-medium">{t('cols.usage')}</th>
                            <th className="px-6 py-3 font-medium">{t('cols.status')}</th>
                            <th className="px-6 py-3 font-medium text-right">{t('cols.actions')}</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-border">
                        {invitations.length === 0 ? (
                            <tr>
                                <td colSpan={6} className="px-6 py-8 text-center text-muted-foreground">
                                    {t('empty')}
                                </td>
                            </tr>
                        ) : (
                            invitations.map((invite) => {
                                const expired = isExpired(invite.expires_at);
                                const full = isFullyUsed(invite.used_count, invite.max_uses);
                                const active = !expired && !full;

                                return (
                                    <tr key={invite.id} className="hover:bg-muted/50 transition-colors">
                                        <td className="px-6 py-4 font-mono font-medium text-primary">
                                            {invite.code}
                                        </td>
                                        <td className="px-6 py-4 capitalize">
                                            {invite.user_category}
                                        </td>
                                        <td className="px-6 py-4 font-medium">
                                            {invite.target_group ? TARGET_GROUP_LABELS[invite.target_group] || invite.target_group : '-'}
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex items-center gap-2">
                                                <div className="w-16 h-2 bg-muted rounded-full overflow-hidden">
                                                    <div
                                                        className="h-full bg-primary transition-all"
                                                        style={{ width: `${(invite.used_count / invite.max_uses) * 100}%` }}
                                                    />
                                                </div>
                                                <span className="text-xs text-muted-foreground">
                                                    {invite.used_count}/{invite.max_uses}
                                                </span>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4">
                                            {active ? (
                                                <Badge variant="default" className="bg-emerald-500/15 text-emerald-500 hover:bg-emerald-500/25 border-emerald-500/20">
                                                    {t('status.active')}
                                                </Badge>
                                            ) : expired ? (
                                                <Badge variant="secondary">{t('status.expired')}</Badge>
                                            ) : (
                                                <Badge variant="secondary">{t('status.fully_used')}</Badge>
                                            )}
                                        </td>
                                        <td className="px-6 py-4 text-right">
                                            <Button
                                                variant="ghost"
                                                size="icon"
                                                onClick={() => copyCode(invite.code)}
                                                className="h-8 w-8 text-muted-foreground hover:text-primary"
                                            >
                                                <Copy className="w-4 h-4" />
                                            </Button>
                                        </td>
                                    </tr>
                                );
                            })
                        )}
                    </tbody>
                </table>
            </div>
        </Card>
    );
}
