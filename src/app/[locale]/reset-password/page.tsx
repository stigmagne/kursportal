'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { useRouter } from '@/i18n/routing';
import { Lock, Loader2, CheckCircle2, AlertCircle } from 'lucide-react';
import { createClient } from '@/utils/supabase/client';
import { useTranslations } from 'next-intl';

export default function ResetPasswordPage() {
    const t = useTranslations('ResetPassword');
    const router = useRouter();
    const [isLoading, setIsLoading] = useState(false);
    const [success, setSuccess] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [passwordStrength, setPasswordStrength] = useState<'weak' | 'medium' | 'strong'>('weak');
    const [isValidToken, setIsValidToken] = useState(false);
    const [isCheckingToken, setIsCheckingToken] = useState(true);

    useEffect(() => {
        // Handle password reset token from URL
        const handlePasswordReset = async () => {
            const supabase = createClient();

            // Debug: Log the full URL
            console.log('Full URL:', window.location.href);
            console.log('Hash:', window.location.hash);
            console.log('Search:', window.location.search);

            // Try both hash fragment and query params
            const hashParams = new URLSearchParams(window.location.hash.substring(1));
            const queryParams = new URLSearchParams(window.location.search);

            // Check both sources for tokens
            let accessToken = hashParams.get('access_token') || queryParams.get('access_token');
            let refreshToken = hashParams.get('refresh_token') || queryParams.get('refresh_token');
            let type = hashParams.get('type') || queryParams.get('type');

            console.log('Access Token:', accessToken ? 'Found' : 'Not found');
            console.log('Refresh Token:', refreshToken ? 'Found' : 'Not found');
            console.log('Type:', type);

            if (type === 'recovery' && accessToken) {
                // Set the session with the tokens from the URL
                const { error: sessionError } = await supabase.auth.setSession({
                    access_token: accessToken,
                    refresh_token: refreshToken || ''
                });

                if (sessionError) {
                    console.error('Session error:', sessionError);
                    setError(t('error_invalid_token'));
                    setIsValidToken(false);
                } else {
                    console.log('Session established successfully');
                    setIsValidToken(true);
                }
            } else {
                // No valid token in URL
                console.error('No valid recovery token found in URL');
                setError(t('error_invalid_token'));
                setIsValidToken(false);
            }

            setIsCheckingToken(false);
        };

        handlePasswordReset();
    }, [t]);

    useEffect(() => {
        // Calculate password strength
        if (password.length === 0) {
            setPasswordStrength('weak');
        } else if (password.length < 12) {
            setPasswordStrength('weak');
        } else if (password.length < 16 || !/[A-Z]/.test(password) || !/[0-9]/.test(password)) {
            setPasswordStrength('medium');
        } else {
            setPasswordStrength('strong');
        }
    }, [password]);

    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        setIsLoading(true);
        setError(null);

        // Validation
        if (password.length < 12) {
            setError(t('error_weak'));
            setIsLoading(false);
            return;
        }

        if (password !== confirmPassword) {
            setError(t('error_mismatch'));
            setIsLoading(false);
            return;
        }

        try {
            const supabase = createClient();

            // Update password
            const { error: updateError } = await supabase.auth.updateUser({
                password: password
            });

            if (updateError) {
                if (updateError.message.includes('token') || updateError.message.includes('session')) {
                    throw new Error(t('error_invalid_token'));
                }
                throw updateError;
            }

            setSuccess(true);

            // Redirect to login after 3 seconds
            setTimeout(() => {
                router.push('/login');
            }, 3000);
        } catch (err: unknown) {
            console.error('Password reset error:', err);
            if (err instanceof Error) {
                setError(err.message);
            } else {
                setError(t('error_invalid_token'));
            }
        } finally {
            setIsLoading(false);
        }
    };

    const getStrengthColor = () => {
        switch (passwordStrength) {
            case 'weak':
                return 'bg-red-500';
            case 'medium':
                return 'bg-yellow-500';
            case 'strong':
                return 'bg-green-500';
        }
    };

    const getStrengthWidth = () => {
        switch (passwordStrength) {
            case 'weak':
                return 'w-1/3';
            case 'medium':
                return 'w-2/3';
            case 'strong':
                return 'w-full';
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
                                {t('success')}
                            </h2>
                            <p className="text-muted-foreground">
                                {t('redirecting')}
                            </p>
                        </div>
                    </div>
                </motion.div>
            </div>
        );
    }

    // Show loading state while checking token
    if (isCheckingToken) {
        return (
            <div className="flex-1 flex flex-col items-center justify-center p-4">
                <motion.div
                    initial={{ opacity: 0, scale: 0.95 }}
                    animate={{ opacity: 1, scale: 1 }}
                    className="w-full max-w-md"
                >
                    <div className="glass rounded-2xl p-8 border border-white/10 shadow-2xl relative overflow-hidden">
                        <div className="relative text-center">
                            <Loader2 className="w-8 h-8 animate-spin mx-auto mb-4 text-primary" />
                            <p className="text-muted-foreground">
                                {t('checking_token')}
                            </p>
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
                                <div className="p-3 text-sm bg-destructive/10 rounded-md text-destructive border border-destructive/20 flex items-start gap-2">
                                    <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
                                    <span>{error}</span>
                                </div>
                            )}

                            <div className="space-y-2">
                                <label className="text-sm font-medium leading-none">
                                    {t('new_password_label')}
                                </label>
                                <div className="relative">
                                    <Lock className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                                    <input
                                        name="password"
                                        type="password"
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                        placeholder={t('password_placeholder')}
                                        className="flex h-10 w-full rounded-md border border-input bg-background/50 px-3 py-2 pl-9 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                                        required
                                        disabled={!isValidToken}
                                    />
                                </div>

                                {/* Password strength indicator */}
                                {password.length > 0 && (
                                    <div className="space-y-1">
                                        <div className="h-1.5 w-full bg-muted rounded-full overflow-hidden">
                                            <div
                                                className={`h-full transition-all duration-300 ${getStrengthColor()} ${getStrengthWidth()}`}
                                            />
                                        </div>
                                        <p className="text-xs text-muted-foreground">
                                            {t(`strength.${passwordStrength}`)}
                                        </p>
                                    </div>
                                )}
                            </div>

                            <div className="space-y-2">
                                <label className="text-sm font-medium leading-none">
                                    {t('confirm_password_label')}
                                </label>
                                <div className="relative">
                                    <Lock className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                                    <input
                                        name="confirmPassword"
                                        type="password"
                                        value={confirmPassword}
                                        onChange={(e) => setConfirmPassword(e.target.value)}
                                        placeholder={t('password_placeholder')}
                                        className="flex h-10 w-full rounded-md border border-input bg-background/50 px-3 py-2 pl-9 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                                        required
                                        disabled={!isValidToken}
                                    />
                                </div>
                            </div>

                            <button
                                type="submit"
                                disabled={isLoading || !isValidToken}
                                className="w-full h-10 bg-primary text-primary-foreground hover:bg-primary/90 rounded-md text-sm font-medium transition-colors flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                            >
                                {isLoading ? (
                                    <>
                                        <Loader2 className="w-4 h-4 animate-spin" />
                                        {t('resetting')}
                                    </>
                                ) : (
                                    t('reset_button')
                                )}
                            </button>
                        </form>
                    </div>
                </div>
            </motion.div>
        </div>
    );
}
