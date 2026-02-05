'use client';

import { useState } from 'react';
import { useTranslations } from 'next-intl';
import { X, Bug, Loader2 } from 'lucide-react';
import { submitBugReport, type BugReportInput } from '@/app/actions/bug-report-actions';

interface BugReportModalProps {
    isOpen: boolean;
    onClose: () => void;
}

export function BugReportModal({ isOpen, onClose }: BugReportModalProps) {
    const t = useTranslations('BugReport');
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [success, setSuccess] = useState(false);

    const [formData, setFormData] = useState<BugReportInput>({
        title: '',
        description: '',
        pageUrl: typeof window !== 'undefined' ? window.location.href : '',
        browserInfo: typeof window !== 'undefined' ? navigator.userAgent : '',
    });

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsSubmitting(true);
        setError(null);

        const result = await submitBugReport(formData);

        setIsSubmitting(false);

        if (result.error) {
            setError(result.error);
        } else {
            setSuccess(true);
            setTimeout(() => {
                onClose();
                setSuccess(false);
                setFormData({ title: '', description: '', pageUrl: '', browserInfo: '' });
            }, 2000);
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
            <div className="bg-white dark:bg-gray-900 border-3 border-black dark:border-white shadow-hard max-w-lg w-full">
                {/* Header */}
                <div className="flex items-center justify-between p-6 border-b-3 border-black dark:border-white">
                    <div className="flex items-center gap-3">
                        <Bug className="w-6 h-6" />
                        <h2 className="text-xl font-bold">{t('title')}</h2>
                    </div>
                    <button
                        onClick={onClose}
                        className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
                        aria-label="Close"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                {/* Success Message */}
                {success && (
                    <div className="m-6 p-4 bg-green-100 dark:bg-green-900/30 border-3 border-green-500 text-green-800 dark:text-green-200">
                        ✓ {t('success')}
                    </div>
                )}

                {/* Form */}
                {!success && (
                    <form onSubmit={handleSubmit} className="p-6 space-y-4">
                        <p className="text-sm text-gray-600 dark:text-gray-400">
                            {t('description')}
                        </p>

                        {/* Title */}
                        <div>
                            <label htmlFor="bug-title" className="block text-sm font-bold mb-2">
                                {t('titleLabel')}
                            </label>
                            <input
                                id="bug-title"
                                type="text"
                                value={formData.title}
                                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                                placeholder={t('titlePlaceholder')}
                                className="w-full p-3 border-3 border-black dark:border-white bg-white dark:bg-gray-800 focus:outline-none focus:ring-3 focus:ring-primary"
                                required
                                minLength={3}
                                maxLength={200}
                            />
                        </div>

                        {/* Description */}
                        <div>
                            <label htmlFor="bug-description" className="block text-sm font-bold mb-2">
                                {t('descriptionLabel')}
                            </label>
                            <textarea
                                id="bug-description"
                                value={formData.description}
                                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                placeholder={t('descriptionPlaceholder')}
                                className="w-full p-3 border-3 border-black dark:border-white bg-white dark:bg-gray-800 focus:outline-none focus:ring-3 focus:ring-primary min-h-[120px]"
                                required
                                minLength={10}
                                maxLength={2000}
                            />
                            <p className="text-xs text-gray-500 mt-1">
                                {formData.description.length}/2000
                            </p>
                        </div>

                        {/* Error Message */}
                        {error && (
                            <div className="p-3 bg-red-100 dark:bg-red-900/30 border-3 border-red-500 text-red-800 dark:text-red-200 text-sm">
                                {error}
                            </div>
                        )}

                        {/* Submit Button */}
                        <button
                            type="submit"
                            disabled={isSubmitting}
                            className="w-full px-6 py-3 bg-primary text-white font-bold border-3 border-black dark:border-white shadow-hard hover:translate-x-1 hover:translate-y-1 hover:shadow-none transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                        >
                            {isSubmitting ? (
                                <>
                                    <Loader2 className="w-5 h-5 animate-spin" />
                                    {t('submitting')}
                                </>
                            ) : (
                                t('submit')
                            )}
                        </button>
                    </form>
                )}
            </div>
        </div>
    );
}
