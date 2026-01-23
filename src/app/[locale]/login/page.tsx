'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { Link, useRouter } from '@/i18n/routing';
import { LogIn, ArrowRight, Mail, Lock, Loader2 } from 'lucide-react';
import { createClient } from '@/utils/supabase/client';
import { useTranslations } from 'next-intl';

export default function LoginPage() {
    const t = useTranslations('Login');
    const [isLoading, setIsLoading] = useState(false);
    const [mode, setMode] = useState<'signin' | 'signup'>('signin');
    const [message, setMessage] = useState<string | null>(null);
    const [invitationCode, setInvitationCode] = useState('');
    const router = useRouter();
    const supabase = createClient();

    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        setIsLoading(true);
        setMessage(null);

        const formData = new FormData(e.currentTarget);
        const email = formData.get('email') as string;
        const password = formData.get('password') as string;

        // Validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            setMessage('Please enter a valid email address');
            setIsLoading(false);
            return;
        }

        if (password.length < 6) {
            setMessage('Password must be at least 6 characters');
            setIsLoading(false);
            return;
        }

        try {
            if (mode === 'signup') {
                // Validate invitation code first
                const { data: validationData, error: validationError } = await supabase
                    .rpc('validate_invitation', { p_code: invitationCode });

                if (validationError || !validationData?.[0]?.valid) {
                    setMessage(validationData?.[0]?.message || 'Invalid invitation code');
                    setIsLoading(false);
                    return;
                }

                const userCategory = validationData[0].user_category;
                const subgroup = validationData[0].subgroup;

                // Sign up user
                const { data, error } = await supabase.auth.signUp({
                    email,
                    password,
                    options: {
                        emailRedirectTo: `${location.origin}/auth/callback`,
                        data: {
                            user_category: userCategory,
                            subgroup: subgroup,
                            sub: '',
                            email: email,
                            email_verified: false,
                            phone_verified: false
                        }
                    },
                });
                if (error) throw error;

                // Update profile with category and subgroup
                if (data.user) {
                    await supabase
                        .from('profiles')
                        .update({
                            user_category: userCategory,
                            subgroup: subgroup
                        })
                        .eq('id', data.user.id);

                    // Mark invitation as used
                    await supabase.rpc('use_invitation', {
                        p_code: invitationCode,
                        p_user_id: data.user.id
                    });
                }

                setMessage('Registration successful! You can now log in.');
                setMode('signin');
            } else {
                const { error } = await supabase.auth.signInWithPassword({
                    email,
                    password,
                });
                if (error) throw error;

                // Fetch user profile to check role
                const { data: profile } = await supabase
                    .from('profiles')
                    .select('role')
                    .eq('id', (await supabase.auth.getUser()).data.user?.id)
                    .single();

                // Always redirect to dashboard for members, admin panel for admins
                if (profile?.role === 'admin') {
                    router.push('/admin');
                } else {
                    router.push('/dashboard');
                }
            }
        } catch (error: any) {
            setMessage(error.message || 'An error occurred');
        } finally {
            setIsLoading(false);
        }
    };

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
                                {mode === 'signin' ? t('welcome_back') : t('create_account')}
                            </h2>
                            <p className="text-muted-foreground text-sm mt-2">
                                {mode === 'signin'
                                    ? t('enter_credentials')
                                    : t('join_hub')}
                            </p>
                        </div>

                        <form onSubmit={handleSubmit} className="space-y-4">
                            {message && (
                                <div className="p-3 text-sm text-center bg-muted rounded-md text-foreground border border-border">
                                    {message}
                                </div>
                            )}

                            <div className="space-y-2">
                                <label className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">{t('email_label')}</label>
                                <div className="relative">
                                    <Mail className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                                    <input
                                        name="email"
                                        type="email"
                                        placeholder="name@example.com"
                                        className="flex h-10 w-full rounded-md border border-input bg-background/50 px-3 py-2 pl-9 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                                        required
                                    />
                                </div>
                            </div>

                            <div className="space-y-2">
                                <label className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">{t('password_label')}</label>
                                <div className="relative">
                                    <Lock className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                                    <input
                                        name="password"
                                        type="password"
                                        placeholder="••••••••"
                                        className="flex h-10 w-full rounded-md border border-input bg-background/50 px-3 py-2 pl-9 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                                        required
                                    />
                                </div>
                            </div>


                            {/* Invitation Code - Only show during signup */}
                            {mode === 'signup' && (
                                <div className="space-y-2">
                                    <label htmlFor="invitation" className="text-sm font-medium leading-none">
                                        {t('invitation_code')}
                                    </label>
                                    <div className="relative">
                                        <input
                                            id="invitation"
                                            name="invitation"
                                            type="text"
                                            value={invitationCode}
                                            onChange={(e) => setInvitationCode(e.target.value.toUpperCase())}
                                            placeholder={t('invitation_placeholder')}
                                            className="flex h-10 w-full rounded-md border border-input bg-background/50 px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 uppercase"
                                            required
                                            maxLength={8}
                                        />
                                    </div>
                                    <p className="text-xs text-muted-foreground">
                                        {t('invitation_help')}
                                    </p>
                                </div>
                            )}


                            <button
                                type="submit"
                                disabled={isLoading}
                                className="w-full h-10 bg-primary text-primary-foreground hover:bg-primary/90 rounded-md text-sm font-medium transition-colors flex items-center justify-center gap-2"
                            >
                                {isLoading ? (
                                    <Loader2 className="w-4 h-4 animate-spin" />
                                ) : (
                                    <>
                                        {mode === 'signin' ? t('sign_in_btn') : t('sign_up_btn')}
                                        <ArrowRight className="w-4 h-4" />
                                    </>
                                )}
                            </button>
                        </form>

                        <div className="mt-6 text-center text-sm">
                            <span className="text-muted-foreground">
                                {mode === 'signin' ? t('no_account') : t('has_account')}
                            </span>
                            <button
                                onClick={() => {
                                    setMode(mode === 'signin' ? 'signup' : 'signin');
                                    setMessage(null);
                                }}
                                className="font-medium text-primary hover:underline underline-offset-4"
                            >
                                {mode === 'signin' ? t('sign_up_link') : t('sign_in_link')}
                            </button>
                        </div>
                    </div>
                </div>
            </motion.div>
        </div>
    );
}
