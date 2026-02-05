'use client';

import { useState } from 'react';
import { useTranslations } from 'next-intl';
import { FileText, AlertCircle, CheckCircle2, Loader2 } from 'lucide-react';
import { generateCertificateForUser } from '@/app/actions/certificate-actions';
import { getAdminUsers } from '@/app/actions/admin-user-actions';

// Popular courses from LMS content structure
const AVAILABLE_COURSES = [
    { id: 'intro-to-electrical-work', name: 'Introduksjon til elektrisk arbeid' },
    { id: 'safety-protocols', name: 'Sikkerhetsprotokoller' },
    { id: 'advanced-wiring', name: 'Avansert kabeltrekking' },
    { id: 'industrial-automation', name: 'Industriell automatisering' },
    { id: 'renewable-energy', name: 'Fornybar energi' },
];

interface GenerateCertificateFormProps {
    users: Array<{ id: string; full_name: string; email: string }>;
}

export default function GenerateCertificateForm({ users }: GenerateCertificateFormProps) {
    const t = useTranslations('AdminCertificates');
    const [selectedUserId, setSelectedUserId] = useState('');
    const [selectedCourseId, setSelectedCourseId] = useState('');
    const [isGenerating, setIsGenerating] = useState(false);
    const [result, setResult] = useState<{ success?: boolean; message?: string; error?: string } | null>(null);

    const handleGenerate = async () => {
        if (!selectedUserId || !selectedCourseId) {
            setResult({ error: 'Vennligst velg både bruker og kurs' });
            return;
        }

        setIsGenerating(true);
        setResult(null);

        try {
            const response = await generateCertificateForUser(selectedUserId, selectedCourseId);

            if (response.error) {
                setResult({ error: response.error });
            } else {
                setResult({
                    success: true,
                    message: response.message || 'Sertifikat generert!'
                });
            }
        } catch (error) {
            setResult({ error: 'En feil oppstod under generering' });
        } finally {
            setIsGenerating(false);
        }
    };

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center gap-3">
                <div className="p-3 bg-primary/10 rounded-lg">
                    <FileText className="w-6 h-6 text-primary" />
                </div>
                <div>
                    <h1 className="text-2xl font-bold">Generer testsertifikat</h1>
                    <p className="text-muted-foreground">Lag et testsertifikat for testing av sertifikatsystemet</p>
                </div>
            </div>

            {/* Form */}
            <div className="bg-white dark:bg-gray-800 rounded-xl border-4 border-black dark:border-white shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] dark:shadow-[8px_8px_0px_0px_rgba(255,255,255,1)] p-6 space-y-6">

                {/* User Selection */}
                <div className="space-y-2">
                    <label className="block text-sm font-bold uppercase">
                        Velg bruker
                    </label>
                    <select
                        value={selectedUserId}
                        onChange={(e) => setSelectedUserId(e.target.value)}
                        className="w-full px-4 py-3 border-4 border-black dark:border-white rounded-lg font-bold bg-white dark:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-primary/50"
                    >
                        <option value="">-- Velg en bruker --</option>
                        {users.map((user) => (
                            <option key={user.id} value={user.id}>
                                {user.full_name} ({user.email})
                            </option>
                        ))}
                    </select>
                </div>

                {/* Course Selection */}
                <div className="space-y-2">
                    <label className="block text-sm font-bold uppercase">
                        Velg kurs
                    </label>
                    <select
                        value={selectedCourseId}
                        onChange={(e) => setSelectedCourseId(e.target.value)}
                        className="w-full px-4 py-3 border-4 border-black dark:border-white rounded-lg font-bold bg-white dark:bg-gray-900 focus:outline-none focus:ring-4 focus:ring-primary/50"
                    >
                        <option value="">-- Velg et kurs --</option>
                        {AVAILABLE_COURSES.map((course) => (
                            <option key={course.id} value={course.id}>
                                {course.name}
                            </option>
                        ))}
                    </select>
                </div>

                {/* Generate Button */}
                <button
                    onClick={handleGenerate}
                    disabled={isGenerating || !selectedUserId || !selectedCourseId}
                    className="w-full px-6 py-3 bg-primary text-white font-bold uppercase border-4 border-black dark:border-white rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] dark:shadow-[4px_4px_0px_0px_rgba(255,255,255,1)] hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] dark:hover:shadow-[2px_2px_0px_0px_rgba(255,255,255,1)] hover:translate-x-[2px] hover:translate-y-[2px] transition-all disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] disabled:hover:translate-x-0 disabled:hover:translate-y-0 flex items-center justify-center gap-2"
                >
                    {isGenerating ? (
                        <>
                            <Loader2 className="w-5 h-5 animate-spin" />
                            Genererer...
                        </>
                    ) : (
                        <>
                            <FileText className="w-5 h-5" />
                            Generer sertifikat
                        </>
                    )}
                </button>

                {/* Result Message */}
                {result && (
                    <div className={`p-4 border-4 rounded-lg flex items-start gap-3 ${result.success
                        ? 'bg-green-50 dark:bg-green-900/20 border-green-500'
                        : 'bg-red-50 dark:bg-red-900/20 border-red-500'
                        }`}>
                        {result.success ? (
                            <CheckCircle2 className="w-5 h-5 text-green-600 dark:text-green-400 flex-shrink-0 mt-0.5" />
                        ) : (
                            <AlertCircle className="w-5 h-5 text-red-600 dark:text-red-400 flex-shrink-0 mt-0.5" />
                        )}
                        <div>
                            <p className="font-bold">
                                {result.success ? 'Suksess!' : 'Feil'}
                            </p>
                            <p className="text-sm mt-1">
                                {result.message || result.error}
                            </p>
                            {result.success && (
                                <p className="text-sm mt-2 text-muted-foreground">
                                    Gå til brukerens profil for å se sertifikatet.
                                </p>
                            )}
                        </div>
                    </div>
                )}

                {/* Info Box */}
                <div className="p-4 bg-blue-50 dark:bg-blue-900/20 border-4 border-blue-500 rounded-lg">
                    <div className="flex items-start gap-3">
                        <AlertCircle className="w-5 h-5 text-blue-600 dark:text-blue-400 flex-shrink-0 mt-0.5" />
                        <div className="text-sm">
                            <p className="font-bold text-blue-900 dark:text-blue-100 mb-1">
                                Testing tips:
                            </p>
                            <ul className="list-disc list-inside space-y-1 text-blue-800 dark:text-blue-200">
                                <li>Generer et sertifikat for din egen bruker</li>
                                <li>Gå til Profil → Sertifikater for å se det</li>
                                <li>Test nedlasting av PDF</li>
                                <li>Skann QR-koden eller besøk verifiseringslinken</li>
                                <li>Test LinkedIn-deling</li>
                                <li>Bytt språk (NO/EN) for å teste oversettelser</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
