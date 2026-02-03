'use client';

import { useEffect, useState } from 'react';
import { CertificateData, downloadCertificate, previewCertificate } from '@/lib/certificateGenerator';
import { Download, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button'; // Assuming shadcn or similar

export default function CertificateView({ data }: { data: CertificateData }) {
    const [previewUrl, setPreviewUrl] = useState<string | null>(null);

    useEffect(() => {
        // Generate preview on mount
        const url = previewCertificate(data);
        setPreviewUrl(url);
    }, [data]);

    if (!previewUrl) {
        return (
            <div className="flex items-center justify-center p-12">
                <Loader2 className="w-8 h-8 animate-spin text-primary" />
                <span className="sr-only">Laster sertifikat...</span>
            </div>
        );
    }

    return (
        <div className="flex flex-col items-center gap-6">
            <div className="w-full max-w-4xl aspect-[1.414] shadow-2xl rounded-sm overflow-hidden border border-border">
                <iframe
                    src={previewUrl}
                    className="w-full h-full border-none"
                    title="Certificate Preview"
                />
            </div>

            <div className="flex gap-4">
                <Button
                    size="lg"
                    onClick={() => downloadCertificate(data)}
                    className="gap-2"
                >
                    <Download className="w-5 h-5" />
                    Last ned bevis (PDF)
                </Button>
            </div>
        </div>
    );
}
