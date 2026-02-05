'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { Link } from '@/i18n/routing';
import { Mail, ArrowLeft, Loader2, CheckCircle2 } from 'lucide-react';
import { createClient } from '@/utils/supabase/client';
import { useTranslations } from 'next-intl';

export default function ForgotPasswordPage() {
    const t = useTranslations('ForgotPassword');
    const [isLoading, setIsLoading] = useState(false);
    const [success, setSuccess] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        setIsLoading(true);
        setError(null);

        const formData = new FormData(e.currentTarget);
        const email = formData.get('email') as string;

        // Validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            setError('Please enter a valid email address');
            setIsLoading(false);
            return;
        }

        try {
            const supabase = createClient();
            const { error: resetError } = await supabase.auth.resetPasswordForEmail(email, {
                redirectTo: `${window.location.origin}/reset-password`,
            });

            if (resetError) throw resetError;

            setSuccess(true);
        } catch (err) {
            console.error('Password reset error:', err);
            setError(t('error_not_found'));
        } finally {
            setIsLoading(false);
        }
    };

    if (success) {
        return (
            <div className="flex-1 flex flex-col items-center justify-center p-4">
                <motion.div
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className="w-full max-w-md"
                >
                    <div className="glass rounded-2xl p-8 border border-white/10 shadow-2xl relative overflow-hidden">
                        {/* Decorative gradients */}
                        <div className="absolute top-0 right-0 w-32 h-32 bg-green-500/20 rounded-full blur-3xl -mr-16 -mt-16" />
                        <div className="absolute bottom-0 left-0 w-32 h-32 bg-primary/20 rounded-full blur-3xl -ml-16 -mb-16" />

                        <div className="relative text-center">
                            <div className="mx-auto w-16 h-16 bg-green-500/10 rounded-full flex items-center justify-center mb-6">
                                <CheckCircle2 className="w-8 h-8 text-green-500" />
                            </div>

                            <h2 className="text-2xl font-bold tracking-tight mb-2">
                                {t('success_title')}
                            </h2>
                            <p className="text-muted-foreground mb-8">
                                {t('success_message')}
                            </p>

                            <Link
                                href="/login"
                                className="inline-flex items-center gap-2 text-sm font-medium text-primary hover:underline underline-offset-4"
                            >
                                <ArrowLeft className="w-4 h-4" />
                                {t('back_to_login')}
                            </Link>
                        </div>
                    </div>
                </motion.div>
            </div>
        );
    }

    return (
        <div className="flex-1 flex flex-col items-center justify-center p-4">
            <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                className="w-full max-w-md"
            >
                <div className="glass rounded-2xl p-8 border border-white/10 shadow-2xl relative overflow-hidden">
                    {/* Decorative gradients */}
                    <div className="absolute top-0 right-0 w-32 h-32 bg-primary/20 rounded-full blur-3xl -mr-16 -mt-16" />
                    <div className="absolute bottom-0 left-0 w-32 h-32 bg-purple-500/20 rounded-full blur-3xl -ml-16 -mb-16" />

                    <div className="relative">
                        <div className="text-center mb-8">
                            <h2 className="text-2xl font-bold tracking-tight">
                                {t('title')}
                            </h2>
                            <p className="text-muted-foreground text-sm mt-2">
                                {t('subtitle')}
                            </p>
                        </div>

                        <form onSubmit={handleSubmit} className="space-y-4">
                            {error && (
                                <div className="p-3 text-sm text-center bg-destructive/10 rounded-md text-destructive border border-destructive/20">
                                    {error}
                                </div>
                            )}

                            <div className="space-y-2">
                                <label className="text-sm font-medium leading-none">
                                    {t('email_label')}
                                </label>
                                <div className="relative">
                                    <Mail className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                                    <input
                                        name="email"
                                        type="email"
                                        placeholder={t('email_placeholder')}
                                        className="flex h-10 w-full rounded-md border border-input bg-background/50 px-3 py-2 pl-9 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                                        required
                                    />
                                </div>
                            </div>

                            <button
                                type="submit"
                                disabled={isLoading}
                                className="w-full h-10 bg-primary text-primary-foreground hover:bg-primary/90 rounded-md text-sm font-medium transition-colors flex items-center justify-center gap-2"
                            >
                                {isLoading ? (
                                    <>
                                        <Loader2 className="w-4 h-4 animate-spin" />
                                        {t('sending')}
                                    </>
                                ) : (
                                    t('send_button')
                                )}
                            </button>
                        </form>

                        <div className="mt-6 text-center">
                            <Link
                                href="/login"
                                className="inline-flex items-center gap-2 text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
                            >
                                <ArrowLeft className="w-4 h-4" />
                                {t('back_to_login')}
                            </Link>
                        </div>
                    </div>
                </div>
            </motion.div>
        </div>
    );
}
