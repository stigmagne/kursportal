import { getAdminUsers } from '@/app/actions/admin-user-actions';
import GenerateCertificateForm from '@/components/admin/GenerateCertificateForm';
import { getTranslations } from 'next-intl/server';

export default async function GenerateCertificatePage() {
    const profiles = await getAdminUsers();

    // Map profiles to simple user objects
    const users = (profiles || []).map(p => ({
        id: p.id,
        full_name: p.full_name || 'Unknown',
        email: p.email || ''
    }));

    return <GenerateCertificateForm users={users} />;
}
