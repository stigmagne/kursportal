'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import CertificateCard from './CertificateCard';
import { Award } from 'lucide-react';
import { useTranslations } from 'next-intl';

interface CertificatesListProps {
    userId: string;
}

export default function CertificatesList({ userId }: CertificatesListProps) {
    const t = useTranslations('Dashboard');
    const supabase = createClient();
    const [certificates, setCertificates] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [profile, setProfile] = useState<any>(null);

    useEffect(() => {
        fetchCertificates();
    }, [userId]);

    const fetchCertificates = async () => {
        setLoading(true);

        // Get user profile
        const { data: profileData } = await supabase
            .from('profiles')
            .select('full_name')
            .eq('id', userId)
            .single();

        setProfile(profileData);

        // Get certificates with course details
        const { data } = await supabase
            .from('certificates')
            .select(`
                *,
                course:courses(title)
            `)
            .eq('user_id', userId)
            .order('issued_at', { ascending: false });

        setCertificates(data || []);
        setLoading(false);
    };

    if (loading) {
        return <div className="animate-pulse p-6">{t('loading_certs')}</div>;
    }

    if (certificates.length === 0) {
        return (
            <div className="text-center py-12">
                <Award className="w-16 h-16 mx-auto mb-4 text-muted-foreground opacity-50" />
                <h3 className="text-lg font-semibold mb-2">{t('no_certs_title')}</h3>
                <p className="text-muted-foreground">
                    {t('no_certs_desc')}
                </p>
            </div>
        );
    }

    return (
        <div className="space-y-4">
            <p className="text-sm text-muted-foreground mb-4">
                {t('earned_certs', { count: certificates.length })}
            </p>
            {certificates.map((cert) => (
                <CertificateCard
                    key={cert.id}
                    courseTitle={cert.course.title}
                    studentName={profile?.full_name || 'Student'}
                    completionDate={cert.issued_at}
                    certificateNumber={cert.certificate_number}
                />
            ))}
        </div>
    );
}
