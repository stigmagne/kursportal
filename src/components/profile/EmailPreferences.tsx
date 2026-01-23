'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import { Mail, Loader2, Save, Check } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { showToast } from '@/lib/toast';

interface EmailPreferencesState {
    welcome_email: boolean;
    course_reminders: boolean;
    new_courses: boolean;
    certificates: boolean;
    comment_replies: boolean;
    weekly_summary: boolean;
    marketing: boolean;
}

export default function EmailPreferences() {
    const [preferences, setPreferences] = useState<EmailPreferencesState | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [isSaving, setIsSaving] = useState(false);
    const supabase = createClient();
    const t = useTranslations('EmailPreferences');

    useEffect(() => {
        fetchPreferences();
    }, []);

    const fetchPreferences = async () => {
        const { data: user } = await supabase.auth.getUser();
        if (!user.user) return;

        const { data, error } = await supabase
            .from('email_preferences')
            .select('*')
            .eq('user_id', user.user.id)
            .single();

        if (data) {
            setPreferences(data);
        } else if (error && error.code === 'PGRST116') {
            // No preferences yet, create default
            const defaultPrefs: EmailPreferencesState = {
                welcome_email: true,
                course_reminders: true,
                new_courses: true,
                certificates: true,
                comment_replies: true,
                weekly_summary: true,
                marketing: false,
            };
            setPreferences(defaultPrefs);
        }
        setIsLoading(false);
    };

    const handleToggle = (key: keyof EmailPreferencesState) => {
        if (!preferences) return;
        setPreferences({
            ...preferences,
            [key]: !preferences[key],
        });
    };

    const handleSave = async () => {
        if (!preferences) return;
        setIsSaving(true);

        const { data: user } = await supabase.auth.getUser();
        if (!user.user) return;

        const { error } = await supabase
            .from('email_preferences')
            .upsert({
                user_id: user.user.id,
                ...preferences,
                updated_at: new Date().toISOString(),
            });

        if (error) {
            showToast.error(t('error_saving'));
        } else {
            showToast.success(t('saved'));
        }
        setIsSaving(false);
    };

    if (isLoading) {
        return (
            <div className="flex justify-center py-8">
                <Loader2 className="w-6 h-6 animate-spin text-blue-500" />
            </div>
        );
    }

    if (!preferences) return null;

    const preferenceItems = [
        {
            key: 'welcome_email' as keyof EmailPreferencesState,
            title: t('welcome_email'),
            description: t('welcome_email_desc'),
        },
        {
            key: 'course_reminders' as keyof EmailPreferencesState,
            title: t('course_reminders'),
            description: t('course_reminders_desc'),
        },
        {
            key: 'new_courses' as keyof EmailPreferencesState,
            title: t('new_courses'),
            description: t('new_courses_desc'),
        },
        {
            key: 'certificates' as keyof EmailPreferencesState,
            title: t('certificates'),
            description: t('certificates_desc'),
        },
        {
            key: 'comment_replies' as keyof EmailPreferencesState,
            title: t('comment_replies'),
            description: t('comment_replies_desc'),
        },
        {
            key: 'weekly_summary' as keyof EmailPreferencesState,
            title: t('weekly_summary'),
            description: t('weekly_summary_desc'),
        },
        {
            key: 'marketing' as keyof EmailPreferencesState,
            title: t('marketing'),
            description: t('marketing_desc'),
        },
    ];

    return (
        <div className="space-y-6">
            <div className="flex items-center gap-3 mb-6">
                <Mail className="w-6 h-6 text-blue-500" />
                <div>
                    <h3 className="text-lg font-semibold text-gray-900">{t('title')}</h3>
                    <p className="text-sm text-gray-600">{t('subtitle')}</p>
                </div>
            </div>

            <div className="space-y-4">
                {preferenceItems.map((item) => (
                    <div
                        key={item.key}
                        className="flex items-start justify-between p-4 bg-white border border-gray-200 rounded-lg hover:border-blue-300 transition-colors"
                    >
                        <div className="flex-1">
                            <h4 className="font-medium text-gray-900">{item.title}</h4>
                            <p className="text-sm text-gray-600 mt-1">{item.description}</p>
                        </div>
                        <button
                            onClick={() => handleToggle(item.key)}
                            className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${preferences[item.key] ? 'bg-blue-600' : 'bg-gray-300'
                                }`}
                        >
                            <span
                                className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${preferences[item.key] ? 'translate-x-6' : 'translate-x-1'
                                    }`}
                            />
                        </button>
                    </div>
                ))}
            </div>

            <button
                onClick={handleSave}
                disabled={isSaving}
                className="flex items-center gap-2 px-6 py-3 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700 transition-colors disabled:opacity-50"
            >
                {isSaving ? (
                    <>
                        <Loader2 className="w-4 h-4 animate-spin" />
                        {t('saving')}
                    </>
                ) : (
                    <>
                        <Save className="w-4 h-4" />
                        {t('save')}
                    </>
                )}
            </button>
        </div>
    );
}
