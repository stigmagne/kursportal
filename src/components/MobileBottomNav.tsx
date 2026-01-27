'use client';

import { usePathname } from 'next/navigation';
import { Link } from '@/i18n/routing';
import { Home, BookOpen, FileText, User } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { createClient } from '@/utils/supabase/client';
import { useState, useEffect } from 'react';

interface NavItem {
    href: string;
    icon: React.ReactNode;
    label: string;
}

export default function MobileBottomNav() {
    const t = useTranslations('Navbar');
    const pathname = usePathname();
    const [isLoggedIn, setIsLoggedIn] = useState(false);
    const [isLoading, setIsLoading] = useState(true);
    const supabase = createClient();

    useEffect(() => {
        const checkAuth = async () => {
            const { data: { user } } = await supabase.auth.getUser();
            setIsLoggedIn(!!user);
            setIsLoading(false);
        };
        checkAuth();

        const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
            setIsLoggedIn(!!session?.user);
        });

        return () => subscription.unsubscribe();
    }, []);

    // Don't show on learn pages (fullscreen learning mode)
    if (pathname.includes('/learn/')) {
        return null;
    }

    // Don't show if not logged in
    if (isLoading || !isLoggedIn) {
        return null;
    }

    const navItems: NavItem[] = [
        { href: '/', icon: <Home className="w-5 h-5" />, label: 'home' },
        { href: '/courses', icon: <BookOpen className="w-5 h-5" />, label: 'courses' },
        { href: '/journal', icon: <FileText className="w-5 h-5" />, label: 'journal' },
        { href: '/profile', icon: <User className="w-5 h-5" />, label: 'profile' },
    ];

    const isActive = (href: string) => {
        if (href === '/') {
            return pathname.endsWith('/no') || pathname.endsWith('/en') || pathname === '/';
        }
        return pathname.includes(href);
    };

    return (
        <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-background border-t-2 border-black dark:border-white z-50 safe-area-inset-bottom">
            <div className="flex items-center justify-around h-16">
                {navItems.map((item) => (
                    <Link
                        key={item.href}
                        href={item.href}
                        className={`flex flex-col items-center justify-center flex-1 h-full gap-1 transition-colors ${isActive(item.href)
                                ? 'text-primary'
                                : 'text-muted-foreground hover:text-foreground'
                            }`}
                    >
                        {item.icon}
                        <span className="text-xs font-medium">
                            {item.label === 'home' ? 'Hjem' : t(item.label)}
                        </span>
                    </Link>
                ))}
            </div>
        </nav>
    );
}
