'use client';

import { useState } from 'react';
import { Send, Mail, Building, User, MessageSquare } from 'lucide-react';
import { useTranslations } from 'next-intl';

export default function ContactPage() {
    const t = useTranslations('Contact');
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [submitted, setSubmitted] = useState(false);

    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        setIsSubmitting(true);

        const formData = new FormData(e.currentTarget);
        const data = {
            name: formData.get('name'),
            email: formData.get('email'),
            company: formData.get('company'),
            message: formData.get('message'),
        };

        // For now, we'll just simulate a submission
        // In production, this would send to an API endpoint
        await new Promise(resolve => setTimeout(resolve, 1000));

        console.log('Contact form submitted:', data);
        setIsSubmitting(false);
        setSubmitted(true);
    };

    if (submitted) {
        return (
            <div className="min-h-screen bg-secondary flex items-center justify-center px-4">
                <div className="max-w-md w-full bg-white border-4 border-black p-8 shadow-[8px_8px_0px_0px_rgba(0,0,0,1)]">
                    <div className="text-center">
                        <div className="w-16 h-16 bg-green-500 border-4 border-black mx-auto mb-4 flex items-center justify-center">
                            <Send className="w-8 h-8 text-white" />
                        </div>
                        <h1 className="text-2xl font-bold mb-2">{t('thank_you')}</h1>
                        <p className="text-gray-600">{t('we_will_contact')}</p>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-secondary py-16 px-4">
            <div className="max-w-2xl mx-auto">
                {/* Header */}
                <div className="text-center mb-12">
                    <h1 className="text-4xl md:text-5xl font-black mb-4">
                        {t('title')}
                    </h1>
                    <p className="text-lg text-gray-700 max-w-xl mx-auto">
                        {t('subtitle')}
                    </p>
                </div>

                {/* Contact Form */}
                <div className="bg-white border-4 border-black p-8 shadow-[8px_8px_0px_0px_rgba(0,0,0,1)]">
                    <form onSubmit={handleSubmit} className="space-y-6">
                        {/* Name Field */}
                        <div>
                            <label htmlFor="name" className="flex items-center gap-2 text-sm font-bold mb-2">
                                <User className="w-4 h-4" />
                                {t('name_label')}
                            </label>
                            <input
                                type="text"
                                id="name"
                                name="name"
                                required
                                className="w-full px-4 py-3 border-2 border-black focus:outline-none focus:ring-2 focus:ring-primary"
                                placeholder={t('name_placeholder')}
                            />
                        </div>

                        {/* Email Field */}
                        <div>
                            <label htmlFor="email" className="flex items-center gap-2 text-sm font-bold mb-2">
                                <Mail className="w-4 h-4" />
                                {t('email_label')}
                            </label>
                            <input
                                type="email"
                                id="email"
                                name="email"
                                required
                                className="w-full px-4 py-3 border-2 border-black focus:outline-none focus:ring-2 focus:ring-primary"
                                placeholder={t('email_placeholder')}
                            />
                        </div>

                        {/* Company Field */}
                        <div>
                            <label htmlFor="company" className="flex items-center gap-2 text-sm font-bold mb-2">
                                <Building className="w-4 h-4" />
                                {t('company_label')}
                            </label>
                            <input
                                type="text"
                                id="company"
                                name="company"
                                className="w-full px-4 py-3 border-2 border-black focus:outline-none focus:ring-2 focus:ring-primary"
                                placeholder={t('company_placeholder')}
                            />
                        </div>

                        {/* Message Field */}
                        <div>
                            <label htmlFor="message" className="flex items-center gap-2 text-sm font-bold mb-2">
                                <MessageSquare className="w-4 h-4" />
                                {t('message_label')}
                            </label>
                            <textarea
                                id="message"
                                name="message"
                                rows={5}
                                required
                                className="w-full px-4 py-3 border-2 border-black focus:outline-none focus:ring-2 focus:ring-primary resize-none"
                                placeholder={t('message_placeholder')}
                            />
                        </div>

                        {/* Submit Button */}
                        <button
                            type="submit"
                            disabled={isSubmitting}
                            className="w-full py-4 bg-primary text-primary-foreground font-bold text-lg border-4 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:translate-x-[2px] hover:translate-y-[2px] transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                        >
                            {isSubmitting ? (
                                <span>{t('sending')}</span>
                            ) : (
                                <>
                                    <Send className="w-5 h-5" />
                                    {t('send_button')}
                                </>
                            )}
                        </button>
                    </form>
                </div>

                {/* Direct Contact Info */}
                <div className="mt-8 text-center text-gray-600">
                    <p>{t('direct_contact')}</p>
                    <a href="mailto:hei@smeb.no" className="text-primary font-bold hover:underline">
                        hei@smeb.no
                    </a>
                </div>
            </div>
        </div>
    );
}
