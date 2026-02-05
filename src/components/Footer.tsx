'use client';

import { useState } from 'react';
import { Mail, MapPin, Bug } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { useTranslations } from 'next-intl';
import { BugReportModal } from './BugReportModal';

export default function Footer() {
    const t = useTranslations('Footer');
    const currentYear = new Date().getFullYear();
    const [showBugReport, setShowBugReport] = useState(false);


    return (
        <footer className="bg-black text-white border-t-4 border-primary">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                    {/* Company Info */}
                    <div className="space-y-4">
                        <h3 className="text-xl font-bold border-b-2 border-primary pb-2 inline-block">
                            SMEB AS
                        </h3>
                        <div className="space-y-2 text-gray-300">
                            <p className="flex items-center gap-2">
                                <MapPin className="w-4 h-4 text-primary" />
                                Storgata 26, 3181 Horten
                            </p>
                            <a
                                href="mailto:hei@smeb.no"
                                className="flex items-center gap-2 hover:text-primary transition-colors"
                            >
                                <Mail className="w-4 h-4 text-primary" />
                                hei@smeb.no
                            </a>
                        </div>
                    </div>

                    {/* Quick Links */}
                    <div className="space-y-4">
                        <h3 className="text-xl font-bold border-b-2 border-primary pb-2 inline-block">
                            {t('quick_links')}
                        </h3>
                        <nav className="space-y-2">
                            <Link href="/login" className="block text-gray-300 hover:text-primary transition-colors">
                                {t('sign_in')}
                            </Link>
                            <Link href="/contact" className="block text-gray-300 hover:text-primary transition-colors">
                                {t('interested')}
                            </Link>
                            <button
                                onClick={() => setShowBugReport(true)}
                                className="block text-gray-300 hover:text-primary transition-colors text-left"
                            >
                                <span className="flex items-center gap-2">
                                    <Bug className="w-4 h-4" />
                                    {t('report_bug')}
                                </span>
                            </button>
                        </nav>
                    </div>

                    {/* Privacy & Security */}
                    <div className="space-y-4">
                        <h3 className="text-xl font-bold border-b-2 border-primary pb-2 inline-block">
                            {t('privacy_security')}
                        </h3>
                        <p className="text-gray-300 text-sm leading-relaxed">
                            {t('privacy_text')}
                        </p>
                    </div>
                </div>

                {/* Bottom Bar */}
                <div className="mt-12 pt-8 border-t border-gray-800 flex flex-col md:flex-row justify-between items-center gap-4">
                    <p className="text-gray-400 text-sm">
                        © {currentYear} SMEB AS. {t('all_rights_reserved')}
                    </p>
                    <div className="flex items-center gap-2 text-sm text-gray-400">
                        <span className="inline-block w-2 h-2 bg-green-500 rounded-full"></span>
                        {t('zero_knowledge')}
                    </div>
                </div>
            </div>

            <BugReportModal
                isOpen={showBugReport}
                onClose={() => setShowBugReport(false)}
            />
        </footer>
    );
}
