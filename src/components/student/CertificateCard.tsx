'use client';

import { useState } from 'react';
import { Download, Eye, Award } from 'lucide-react';
import { downloadCertificate, previewCertificate } from '@/lib/certificateGenerator';

interface CertificateCardProps {
    courseTitle: string;
    studentName: string;
    completionDate: string;
    certificateNumber: string;
}

export default function CertificateCard({
    courseTitle,
    studentName,
    completionDate,
    certificateNumber
}: CertificateCardProps) {
    const [showPreview, setShowPreview] = useState(false);
    const [previewUrl, setPreviewUrl] = useState<string | null>(null);

    const handleDownload = () => {
        downloadCertificate({
            studentName,
            courseTitle,
            completionDate: new Date(completionDate).toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            }),
            certificateNumber
        });
    };

    const handlePreview = () => {
        const url = previewCertificate({
            studentName,
            courseTitle,
            completionDate: new Date(completionDate).toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            }),
            certificateNumber
        });
        setPreviewUrl(url);
        setShowPreview(true);
    };

    return (
        <>
            <div className="glass p-6 rounded-xl border border-white/10 hover:border-primary/50 transition-all">
                <div className="flex items-start gap-4">
                    {/* Icon */}
                    <div className="p-3 rounded-lg bg-linear-to-br from-yellow-500/20 to-orange-500/20 border border-yellow-500/30">
                        <Award className="w-6 h-6 text-yellow-500" />
                    </div>

                    {/* Details */}
                    <div className="flex-1">
                        <h3 className="font-semibold text-lg mb-1">{courseTitle}</h3>
                        <p className="text-sm text-muted-foreground mb-2">
                            Completed: {new Date(completionDate).toLocaleDateString()}
                        </p>
                        <p className="text-xs text-muted-foreground">
                            Certificate #{certificateNumber}
                        </p>
                    </div>

                    {/* Actions */}
                    <div className="flex gap-2">
                        <button
                            onClick={handlePreview}
                            className="p-2 rounded-lg bg-muted hover:bg-muted/80 transition-colors"
                            title="Preview Certificate"
                        >
                            <Eye className="w-4 h-4" />
                        </button>
                        <button
                            onClick={handleDownload}
                            className="p-2 rounded-lg bg-primary text-primary-foreground hover:bg-primary/90 transition-colors"
                            title="Download Certificate"
                        >
                            <Download className="w-4 h-4" />
                        </button>
                    </div>
                </div>
            </div>

            {/* Preview Modal */}
            {showPreview && previewUrl && (
                <div
                    className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4"
                    onClick={() => setShowPreview(false)}
                >
                    <div className="relative max-w-6xl w-full" onClick={(e) => e.stopPropagation()}>
                        <button
                            onClick={() => setShowPreview(false)}
                            className="absolute -top-12 right-0 px-4 py-2 bg-white text-black rounded-lg hover:bg-gray-200 transition-colors"
                        >
                            Close
                        </button>
                        <iframe
                            src={previewUrl}
                            className="w-full h-[80vh] bg-white rounded-lg"
                            title="Certificate Preview"
                        />
                    </div>
                </div>
            )}
        </>
    );
}
