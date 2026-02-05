import { notFound } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { CheckCircle2, XCircle, Shield } from 'lucide-react';
import { verifyCertificate } from '@/app/actions/certificate-actions';
import { unstable_setRequestLocale } from 'next-intl/server';

interface VerifyPageProps {
    params: {
        locale: string;
        code: string;
    };
}

export default async function VerifyPage({ params }: VerifyPageProps) {
    unstable_setRequestLocale(params.locale);

    const result = await verifyCertificate(params.code);

    if (!result.success || !result.certificate) {
        return <InvalidCertificate locale={params.locale} />;
    }

    const { certificate } = result;

    return (
        <div className="min-h-screen bg-gray-50 dark:bg-gray-950 py-12 px-4">
            <div className="max-w-2xl mx-auto">
                {/* Success Header */}
                <div className="text-center mb-8">
                    <div className="inline-flex items-center justify-center w-20 h-20 bg-green-100 dark:bg-green-900/30 border-3 border-black dark:border-white shadow-hard mb-4">
                        <CheckCircle2 className="w-12 h-12 text-green-600 dark:text-green-400" />
                    </div>
                    <h1 className="text-3xl font-black mb-2">
                        {params.locale === 'no' ? 'Gyldig sertifikat' : 'Valid Certificate'}
                    </h1>
                    <p className="text-gray-600 dark:text-gray-400">
                        {params.locale === 'no'
                            ? 'Dette sertifikatet er verifisert av SMEB AS'
                            : 'This certificate is verified by SMEB AS'}
                    </p>
                </div>

                {/* Certificate Details */}
                <div className="bg-white dark:bg-gray-900 border-3 border-black dark:border-white shadow-hard p-8 space-y-6">
                    {/* User Info */}
                    <div>
                        <label className="text-sm font-bold text-gray-600 dark:text-gray-400 uppercase tracking-wide">
                            {params.locale === 'no' ? 'Utstedt til' : 'Issued to'}
                        </label>
                        <p className="text-2xl font-bold mt-1">{certificate.user_name}</p>
                    </div>

                    {/* Course Info */}
                    <div>
                        <label className="text-sm font-bold text-gray-600 dark:text-gray-400 uppercase tracking-wide">
                            {params.locale === 'no' ? 'Kurs' : 'Course'}
                        </label>
                        <p className="text-xl font-bold mt-1">{certificate.course_id}</p>
                    </div>

                    {/* Issue Date */}
                    <div>
                        <label className="text-sm font-bold text-gray-600 dark:text-gray-400 uppercase tracking-wide">
                            {params.locale === 'no' ? 'Utstedelsesdato' : 'Issue Date'}
                        </label>
                        <p className="text-lg font-bold mt-1">
                            {new Date(certificate.issued_at).toLocaleDateString(
                                params.locale === 'no' ? 'nb-NO' : 'en-US',
                                {
                                    year: 'numeric',
                                    month: 'long',
                                    day: 'numeric',
                                }
                            )}
                        </p>
                    </div>

                    {/* Verification Code */}
                    <div>
                        <label className="text-sm font-bold text-gray-600 dark:text-gray-400 uppercase tracking-wide">
                            {params.locale === 'no' ? 'Verifikasjonskode' : 'Verification Code'}
                        </label>
                        <p className="text-sm font-mono mt-1 bg-gray-100 dark:bg-gray-800 p-2 border-2 border-black dark:border-white">
                            {certificate.verification_code}
                        </p>
                    </div>

                    {/* Verified Badge */}
                    <div className="pt-6 border-t-3 border-black dark:border-white">
                        <div className="flex items-center gap-3 text-green-600 dark:text-green-400">
                            <Shield className="w-6 h-6" />
                            <span className="font-bold">
                                {params.locale === 'no'
                                    ? 'Verifisert av SMEB AS'
                                    : 'Verified by SMEB AS'}
                            </span>
                        </div>
                    </div>
                </div>

                {/* Legal Disclaimer */}
                <div className="mt-6 text-center text-sm text-gray-600 dark:text-gray-400 italic">
                    {params.locale === 'no'
                        ? 'Dette sertifikatet bekrefter gjennomføring av kurset hos SMEB AS. Dette er ikke et offisielt godkjent fagbrev.'
                        : 'This certificate confirms completion of the course at SMEB AS. This is not an officially accredited trade certificate.'}
                </div>
            </div>
        </div>
    );
}

function InvalidCertificate({ locale }: { locale: string }) {
    return (
        <div className="min-h-screen bg-gray-50 dark:bg-gray-950 py-12 px-4">
            <div className="max-w-2xl mx-auto">
                {/* Error Header */}
                <div className="text-center mb-8">
                    <div className="inline-flex items-center justify-center w-20 h-20 bg-red-100 dark:bg-red-900/30 border-3 border-black dark:border-white shadow-hard mb-4">
                        <XCircle className="w-12 h-12 text-red-600 dark:text-red-400" />
                    </div>
                    <h1 className="text-3xl font-black mb-2">
                        {locale === 'no' ? 'Ugyldig sertifikat' : 'Invalid Certificate'}
                    </h1>
                    <p className="text-gray-600 dark:text-gray-400">
                        {locale === 'no'
                            ? 'Denne verifikasjonskoden er ugyldig eller utløpt'
                            : 'This verification code is invalid or expired'}
                    </p>
                </div>

                {/* Error Message */}
                <div className="bg-white dark:bg-gray-900 border-3 border-black dark:border-white shadow-hard p-8">
                    <p className="text-center text-gray-700 dark:text-gray-300">
                        {locale === 'no'
                            ? 'Sjekk at du har skannet riktig QR-kode eller at verifikasjonskoden er riktig skrevet inn.'
                            : 'Please check that you have scanned the correct QR code or entered the verification code correctly.'}
                    </p>
                </div>
            </div>
        </div>
    );
}
