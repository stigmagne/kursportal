'use client';

import { ReactNode } from 'react';
import { ErrorBoundary } from '@/components/ErrorBoundary';

interface Props {
    children: ReactNode;
}

export function ClientErrorBoundary({ children }: Props) {
    return <ErrorBoundary>{children}</ErrorBoundary>;
}
