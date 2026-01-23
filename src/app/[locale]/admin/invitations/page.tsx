import { getTranslations } from 'next-intl/server';
import InvitationManager from '@/components/admin/InvitationManager';
import InvitationList from '@/components/admin/InvitationList';

export default async function AdminInvitationsPage() {
    const t = await getTranslations('Invites');

    return (
        <div className="space-y-8">
            <div>
                <h1 className="text-3xl font-bold tracking-tight mb-2">{t('title')}</h1>
                <p className="text-muted-foreground">
                    {t('subtitle')}
                </p>
            </div>

            <div className="grid gap-8">
                <section>
                    <InvitationManager />
                </section>

                <section>
                    <InvitationList />
                </section>
            </div>
        </div>
    );
}
