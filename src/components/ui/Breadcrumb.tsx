'use client';

import { ChevronRight, Home } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Fragment } from 'react';

export interface BreadcrumbItem {
    label: string;
    href?: string;
}

interface BreadcrumbProps {
    items: BreadcrumbItem[];
}

export function Breadcrumb({ items }: BreadcrumbProps) {
    return (
        <nav className="flex items-center space-x-2 text-sm text-muted-foreground mb-6">
            <Link href="/" className="hover:text-foreground transition-colors">
                <Home className="w-4 h-4" />
            </Link>
            {items.map((item, index) => (
                <Fragment key={index}>
                    <ChevronRight className="w-4 h-4" />
                    {item.href ? (
                        <Link
                            href={item.href}
                            className="hover:text-foreground transition-colors"
                        >
                            {item.label}
                        </Link>
                    ) : (
                        <span className="text-foreground font-medium">{item.label}</span>
                    )}
                </Fragment>
            ))}
        </nav>
    );
}
