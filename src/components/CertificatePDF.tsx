'use client';

import { useState } from 'react';
import { useTranslations } from 'next-intl';
import { Download, Share2, CheckCircle2, Loader2 } from 'lucide-react';
import QRCode from 'qrcode';
import jsPDF from 'jspdf';
import type { Certificate } from '@/app/actions/certificate-actions';

interface CertificatePDFProps {
    certificate: Certificate;
    userName: string;
    courseTitle: string;
    locale: string;
}

export default function CertificatePDF({
    certificate,
    userName,
    courseTitle,
    locale,
}: CertificatePDFProps) {
    const t = useTranslations('Certificates');
    const [isGenerating, setIsGenerating] = useState(false);

    const verificationUrl = `${window.location.origin}/${locale}/verify/${certificate.verification_code}`;

    const generatePDF = async () => {
        setIsGenerating(true);
        try {
            // Generate QR code as data URL
            const qrDataUrl = await QRCode.toDataURL(verificationUrl, {
                width: 200,
                margin: 1,
                color: {
                    dark: '#000000',
                    light: '#FFFFFF',
                },
            });

            // Create PDF
            const pdf = new jsPDF({
                orientation: 'landscape',
                unit: 'mm',
                format: 'a4',
            });

            const pageWidth = pdf.internal.pageSize.getWidth();
            const pageHeight = pdf.internal.pageSize.getHeight();

            // Background color
            pdf.setFillColor(255, 255, 255);
            pdf.rect(0, 0, pageWidth, pageHeight, 'F');

            // Neo-Brutalist border
            pdf.setLineWidth(2);
            pdf.setDrawColor(0, 0, 0);
            pdf.rect(10, 10, pageWidth - 20, pageHeight - 20);

            // Inner border for emphasis
            pdf.setLineWidth(0.5);
            pdf.rect(15, 15, pageWidth - 30, pageHeight - 30);

            // SMEB AS branding
            pdf.setFontSize(12);
            pdf.setFont('helvetica', 'bold');
            pdf.text('SMEB AS', pageWidth / 2, 25, { align: 'center' });

            // Certificate title
            pdf.setFontSize(32);
            pdf.setFont('helvetica', 'bold');
            pdf.text(
                locale === 'no' ? 'SERTIFIKAT' : 'CERTIFICATE',
                pageWidth / 2,
                45,
                { align: 'center' }
            );

            // Subtitle
            pdf.setFontSize(14);
            pdf.setFont('helvetica', 'normal');
            pdf.text(
                locale === 'no'
                    ? 'for gjennomført kurs'
                    : 'of course completion',
                pageWidth / 2,
                55,
                { align: 'center' }
            );

            // User name
            pdf.setFontSize(24);
            pdf.setFont('helvetica', 'bold');
            pdf.text(`${userName}`, pageWidth / 2, 75, { align: 'center' });

            // "has completed"
            pdf.setFontSize(12);
            pdf.setFont('helvetica', 'normal');
            pdf.text(
                locale === 'no' ? 'har fullført kurset' : 'has completed the course',
                pageWidth / 2,
                85,
                { align: 'center' }
            );

            // Course title
            pdf.setFontSize(18);
            pdf.setFont('helvetica', 'bold');
            pdf.text(courseTitle, pageWidth / 2, 100, { align: 'center' });

            // Issue date
            pdf.setFontSize(10);
            pdf.setFont('helvetica', 'normal');
            const issueDate = new Date(certificate.issued_at).toLocaleDateString(
                locale === 'no' ? 'nb-NO' : 'en-US',
                {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric',
                }
            );
            pdf.text(
                `${locale === 'no' ? 'Utstedt' : 'Issued'}: ${issueDate}`,
                pageWidth / 2,
                115,
                { align: 'center' }
            );

            // QR Code
            pdf.addImage(qrDataUrl, 'PNG', pageWidth / 2 - 20, 125, 40, 40);

            // Verification text
            pdf.setFontSize(8);
            pdf.text(
                locale === 'no'
                    ? 'Skann QR-koden for å verifisere sertifikatet'
                    : 'Scan the QR code to verify this certificate',
                pageWidth / 2,
                170,
                { align: 'center' }
            );

            // Legal disclaimer
            pdf.setFontSize(7);
            pdf.setFont('helvetica', 'italic');
            const disclaimer =
                locale === 'no'
                    ? 'Dette sertifikatet bekrefter gjennomføring av kurset hos SMEB AS. Dette er ikke et offisielt godkjent fagbrev.'
                    : 'This certificate confirms completion of the course at SMEB AS. This is not an officially accredited trade certificate.';

            // Split disclaimer into lines if too long
            const disclaimerLines = pdf.splitTextToSize(disclaimer, pageWidth - 40);
            pdf.text(disclaimerLines, pageWidth / 2, pageHeight - 15, {
                align: 'center',
            });

            // Download PDF
            pdf.save(
                `SMEB_Certificate_${courseTitle.replace(/\s+/g, '_')}_${certificate.verification_code.substring(0, 8)
                }.pdf`
            );
        } catch (error) {
            console.error('Error generating PDF:', error);
            alert(locale === 'no' ? 'Kunne ikke generere PDF' : 'Could not generate PDF');
        } finally {
            setIsGenerating(false);
        }
    };

    const shareToLinkedIn = () => {
        const linkedInUrl = `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(
            verificationUrl
        )}`;
        window.open(linkedInUrl, '_blank', 'width=600,height=600');
    };

    return (
        <div className="border-3 border-black dark:border-white bg-white dark:bg-gray-900 shadow-hard p-6 space-y-4">
            {/* Certificate Info */}
            <div className="flex items-start justify-between">
                <div className="space-y-1">
                    <h3 className="text-lg font-bold">{courseTitle}</h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                        {t('issued')}: {new Date(certificate.issued_at).toLocaleDateString(
                            locale === 'no' ? 'nb-NO' : 'en-US',
                            {
                                year: 'numeric',
                                month: 'long',
                                day: 'numeric',
                            }
                        )}
                    </p>
                    <p className="text-xs font-mono text-gray-500 dark:text-gray-500">
                        {t('verification_code')}: {certificate.verification_code.substring(0, 8)}...
                    </p>
                </div>
                <CheckCircle2 className="w-8 h-8 text-green-600 dark:text-green-400 flex-shrink-0" />
            </div>

            {/* Action Buttons */}
            <div className="flex gap-3">
                <button
                    onClick={generatePDF}
                    disabled={isGenerating}
                    className="flex-1 px-4 py-2 bg-primary text-white font-bold border-3 border-black dark:border-white shadow-hard hover:translate-x-1 hover:translate-y-1 hover:shadow-none transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                >
                    {isGenerating ? (
                        <>
                            <Loader2 className="w-4 h-4 animate-spin" />
                            {locale === 'no' ? 'Genererer...' : 'Generating...'}
                        </>
                    ) : (
                        <>
                            <Download className="w-4 h-4" />
                            {t('download_pdf')}
                        </>
                    )}
                </button>

                <button
                    onClick={shareToLinkedIn}
                    className="px-4 py-2 bg-white dark:bg-gray-800 text-black dark:text-white font-bold border-3 border-black dark:border-white shadow-hard hover:translate-x-1 hover:translate-y-1 hover:shadow-none transition-all flex items-center gap-2"
                >
                    <Share2 className="w-4 h-4" />
                    {t('share_linkedin')}
                </button>
            </div>

            {/* QR Code Preview (optional, click to verify) */}
            <div className="pt-4 border-t-3 border-black dark:border-white">
                <p className="text-xs text-gray-600 dark:text-gray-400 text-center mb-2">
                    {t('scan_qr')}
                </p>
                <div className="flex justify-center">
                    <a
                        href={verificationUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-block hover:opacity-80 transition-opacity"
                    >
                        <div id={`qr-${certificate.id}`} className="w-32 h-32 border-2 border-black dark:border-white" />
                    </a>
                </div>
            </div>
        </div>
    );
}
