'use client';

import dynamic from 'next/dynamic';

// Note: CertificateView is a default export
const CertificateView = dynamic(() => import('@/components/certificate/CertificateView'), {
    ssr: false,
    loading: () => <div className="h-[600px] w-full animate-pulse bg-muted/20 rounded-xl" />
});

export default function CertificateViewWrapper(props: React.ComponentProps<typeof CertificateView>) {
    return <CertificateView {...props} />;
}
