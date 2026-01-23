import { getAdminUsers } from '@/app/actions/admin-user-actions';
import UserList from '@/components/admin/UserList';
import { getTranslations } from 'next-intl/server';

export default async function UsersPage() {
    const t = await getTranslations('AdminUsers');
    const profiles = await getAdminUsers();

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold">{t('title')}</h1>
                    <p className="text-muted-foreground mt-1">{t('subtitle')}</p>
                </div>
            </div>

            <UserList initialUsers={profiles || []} />
        </div>
    );
}
