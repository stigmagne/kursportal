import { createClient } from '@/utils/supabase/server';
import { notFound, redirect } from 'next/navigation';
import CertificateViewWrapper from '@/components/certificate/CertificateViewWrapper';
import { Link } from '@/i18n/routing';
import { ArrowLeft } from 'lucide-react';

export default async function CertificatePage({ params }: { params: Promise<{ id: string }> }) {
    const { id } = await params;
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
        redirect('/login');
    }

    // specific certificate fetch
    const { data: certificate, error } = await supabase
        .from('certificates')
        .select(`
            *,
            courses (
                title
            ),
            profiles (
                full_name
            )
        `)
        .eq('id', id)
        .single();

    if (error || !certificate) {
        notFound();
    }

    // RLS policies should handle security, but explicitly:
    // User must be the owner OR admin. 
    // Usually RLS handles this, so if we got data, it's valid.

    const certificateData = {
        studentName: certificate.profiles?.full_name || 'Student',
        courseTitle: certificate.courses?.title || 'Course',
        completionDate: new Date(certificate.issued_at).toLocaleDateString('no-NO', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        }),
        certificateNumber: certificate.certificate_number
    };

    return (
        <div className="min-h-screen bg-background py-12 px-4 sm:px-6 lg:px-8">
            <div className="max-w-5xl mx-auto space-y-8">
                <div className="flex items-center justify-between">
                    <Link
                        href="/profile"
                        className="inline-flex items-center gap-2 text-muted-foreground hover:text-foreground transition-colors"
                    >
                        <ArrowLeft className="w-4 h-4" />
                        Tilbake til profil
                    </Link>
                    <h1 className="text-2xl font-bold">Ditt Kursbevis</h1>
                </div>

                <CertificateViewWrapper data={certificateData} />
            </div>
        </div>
    );
}
