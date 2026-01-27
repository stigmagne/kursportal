'use client';

import { useState, useEffect } from 'react';
import { Link, useRouter } from '@/i18n/routing';
import { Menu, X, BookOpen, Lock, Users, LayoutDashboard } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { createClient } from '@/utils/supabase/client';
import LanguageSwitcher from './LanguageSwitcher';
import { NotificationBell } from './NotificationBell';
import { SearchBar } from './SearchBar';
import { useTranslations } from 'next-intl';

export default function Navbar() {
    const t = useTranslations('Navbar');
    const [isOpen, setIsOpen] = useState(false);
    const [user, setUser] = useState<any>(null);
    const [profile, setProfile] = useState<any>(null);
    const [isLoading, setIsLoading] = useState(true);
    const supabase = createClient();
    const router = useRouter();

    useEffect(() => {
        const fetchUser = async () => {
            const { data: { user } } = await supabase.auth.getUser();
            setUser(user);

            if (user) {
                const { data } = await supabase
                    .from('profiles')
                    .select('role, full_name')
                    .eq('id', user.id)
                    .single();
                setProfile(data);
            }
            setIsLoading(false);
        };

        fetchUser();

        // Listen for auth changes
        const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
            setUser(session?.user ?? null);
            if (!session?.user) {
                setProfile(null);
            } else {
                fetchUser();
            }
        });

        return () => subscription.unsubscribe();
    }, []);

    const handleSignOut = async () => {
        await supabase.auth.signOut();
        router.push('/');
        router.refresh();
    };

    const isAdmin = profile?.role === 'admin';

    return (
        <nav className="sticky top-0 z-50 bg-background/95 backdrop-blur supports-backdrop-filter:bg-background/80 border-b-2 border-black dark:border-white">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="flex items-center justify-between h-16">
                    {/* Logo */}
                    <Link href="/" className="flex items-center gap-2 font-bold text-xl">
                        <span className="bg-linear-to-r from-primary to-purple-500 bg-clip-text text-transparent">
                            Kursportal
                        </span>
                    </Link>

                    {/* Desktop Navigation */}
                    <div className="hidden md:flex items-center gap-6">
                        {!isLoading && user && (
                            <>
                                <Link href="/courses" className="text-sm font-medium hover:text-primary transition-colors">
                                    {t('courses')}
                                </Link>
                                <Link href="/journal" className="flex items-center gap-1 text-sm font-medium hover:text-primary transition-colors">
                                    <Lock className="w-4 h-4" />
                                    {t('journal')}
                                </Link>
                                {!isAdmin && (
                                    <Link href="/dashboard" className="flex items-center gap-1 text-sm font-medium hover:text-primary transition-colors">
                                        <BookOpen className="w-4 h-4" />
                                        {t('myCourses')}
                                    </Link>
                                )}
                                <Link href="/profile" className="flex items-center gap-1 text-sm font-medium hover:text-primary transition-colors">
                                    <Users className="w-4 h-4" />
                                    {t('profile')}
                                </Link>
                                {isAdmin && (
                                    <Link href="/admin" className="flex items-center gap-1 text-sm font-medium text-purple-400 hover:text-purple-300 transition-colors">
                                        <LayoutDashboard className="w-4 h-4" />
                                        {t('admin')}
                                    </Link>
                                )}
                            </>
                        )}

                        <div className="flex items-center gap-4">
                            {!isLoading && user && (
                                <div className="hidden md:block flex-1 max-w-md">
                                    <SearchBar />
                                </div>
                            )}
                            {!isLoading && user && <NotificationBell />}
                            <LanguageSwitcher />

                            {!isLoading && (
                                user ? (
                                    <div className="flex items-center gap-4">
                                        <span className="text-sm text-muted-foreground">
                                            {profile?.full_name || user.email}
                                        </span>
                                        <button
                                            onClick={handleSignOut}
                                            className="px-4 py-2 text-sm font-medium bg-secondary hover:bg-secondary/80 rounded-lg transition-colors"
                                        >
                                            {t('signOut')}
                                        </button>
                                    </div>
                                ) : (
                                    <div className="flex items-center gap-2">
                                        <Link
                                            href="/pricing"
                                            className="text-sm font-medium hover:text-primary transition-colors"
                                        >
                                            {t('pricing')}
                                        </Link>
                                        <Link
                                            href="/login"
                                            className="px-4 py-2 text-sm font-medium bg-primary text-primary-foreground hover:bg-primary/90 rounded-lg transition-colors"
                                        >
                                            {t('signIn')}
                                        </Link>
                                    </div>
                                )
                            )}
                        </div>
                    </div>

                    {/* Mobile Menu Button */}
                    <button
                        onClick={() => setIsOpen(!isOpen)}
                        className="md:hidden p-2 rounded-lg hover:bg-muted transition-colors"
                    >
                        {isOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
                    </button>
                </div>
            </div>

            {/* Mobile Menu */}
            <AnimatePresence>
                {isOpen && (
                    <motion.div
                        initial={{ opacity: 0, height: 0 }}
                        animate={{ opacity: 1, height: 'auto' }}
                        exit={{ opacity: 0, height: 0 }}
                        className="md:hidden border-t border-white/10 bg-background/95 backdrop-blur-lg"
                    >
                        <div className="px-4 py-4 space-y-3">
                            <div className="px-4 py-2">
                                <LanguageSwitcher />
                            </div>

                            {!isLoading && user && (
                                <>
                                    <Link
                                        href="/courses"
                                        className="block px-4 py-2 rounded-lg hover:bg-muted transition-colors"
                                        onClick={() => setIsOpen(false)}
                                    >
                                        {t('courses')}
                                    </Link>
                                    <Link
                                        href="/journal"
                                        className="flex items-center gap-2 px-4 py-2 rounded-lg hover:bg-muted transition-colors"
                                        onClick={() => setIsOpen(false)}
                                    >
                                        <Lock className="w-4 h-4" />
                                        {t('journal')}
                                    </Link>
                                    {isAdmin && (
                                        <Link
                                            href="/admin"
                                            className="flex items-center gap-2 px-4 py-2 rounded-lg hover:bg-muted transition-colors text-purple-400"
                                            onClick={() => setIsOpen(false)}
                                        >
                                            <LayoutDashboard className="w-4 h-4" />
                                            {t('admin')}
                                        </Link>
                                    )}
                                </>
                            )}

                            {!isLoading && (
                                user ? (
                                    <>
                                        <div className="px-4 py-2 text-sm text-muted-foreground border-t border-white/10 mt-2 pt-3">
                                            {profile?.full_name || user.email}
                                        </div>
                                        <button
                                            onClick={() => {
                                                handleSignOut();
                                                setIsOpen(false);
                                            }}
                                            className="w-full px-4 py-2 text-sm font-medium bg-secondary hover:bg-secondary/80 rounded-lg transition-colors"
                                        >
                                            {t('signOut')}
                                        </button>
                                    </>
                                ) : (
                                    <Link
                                        href="/login"
                                        className="block px-4 py-2 text-center text-sm font-medium bg-primary text-primary-foreground hover:bg-primary/90 rounded-lg transition-colors"
                                        onClick={() => setIsOpen(false)}
                                    >
                                        {t('signIn')}
                                    </Link>
                                )
                            )}
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </nav>
    );
}
