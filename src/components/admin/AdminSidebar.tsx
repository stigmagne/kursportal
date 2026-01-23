'use client';

import { Link, usePathname } from '@/i18n/routing';
import {
    LayoutDashboard,
    BookOpen,
    Users,
    Settings,
    Shield,
    FileText,
    LogOut,
    Ticket,
    Tag
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { createClient } from '@/utils/supabase/client';
import { useRouter } from '@/i18n/routing';

import { useTranslations } from 'next-intl';




export default function AdminSidebar() {
    const t = useTranslations('AdminSidebar');
    const pathname = usePathname();
    const router = useRouter();
    const supabase = createClient();

    const navigation = [
        { name: t('dashboard'), href: '/admin', icon: LayoutDashboard },
        { name: t('courses'), href: '/admin/courses', icon: BookOpen },
        { name: t('invitations'), href: '/admin/invitations', icon: Ticket },
        { name: t('tags'), href: '/admin/tags', icon: Tag },
        { name: t('users'), href: '/admin/users', icon: Users },
        { name: t('analytics'), href: '/admin/analytics', icon: FileText },
        { name: t('settings'), href: '/admin/settings', icon: Settings },
    ];

    const handleSignOut = async () => {
        await supabase.auth.signOut();
        router.push('/login');
        router.refresh();
    };

    return (
        <div className="flex flex-col w-64 border-r bg-card h-screen sticky top-0">
            <div className="p-6 border-b">
                <div className="flex items-center gap-2 font-bold text-xl text-primary">
                    <Shield className="w-6 h-6" />
                    <span>{t('panel_title')}</span>
                </div>
            </div>

            <nav className="flex-1 p-4 space-y-1">
                {navigation.map((item) => {
                    const isActive = pathname === item.href || (item.href !== '/admin' && pathname?.startsWith(item.href));

                    return (
                        <Link
                            key={item.href}
                            href={item.href}
                            className={cn(
                                "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors",
                                isActive
                                    ? "bg-primary/10 text-primary"
                                    : "text-muted-foreground hover:bg-muted hover:text-foreground"
                            )}
                        >
                            <item.icon className="w-4 h-4" />
                            {item.name}
                        </Link>
                    );
                })}
            </nav>

            <div className="p-4 border-t">
                <button
                    onClick={handleSignOut}
                    className="flex w-full items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-muted-foreground hover:bg-red-500/10 hover:text-red-500 transition-colors"
                >
                    <LogOut className="w-4 h-4" />
                    {t('sign_out')}
                </button>
            </div>
        </div>
    );
}
