import { Link } from '@/i18n/routing';
import { BookOpen, ArrowRight } from 'lucide-react';
import { useTranslations } from 'next-intl';

export default function EmptyDashboard() {
    const t = useTranslations('Dashboard');
    return (
        <div className="glass rounded-2xl border border-white/10 p-12 text-center">
            <div className="max-w-md mx-auto space-y-6">
                {/* Icon */}
                <div className="w-24 h-24 mx-auto rounded-full bg-primary/10 flex items-center justify-center">
                    <BookOpen className="w-12 h-12 text-primary" />
                </div>

                {/* Message */}
                <div className="space-y-2">
                    <h2 className="text-2xl font-semibold">{t('empty_title')}</h2>
                    <p className="text-muted-foreground">
                        {t('empty_desc')}
                    </p>
                </div>

                {/* CTA Button */}
                <Link
                    href="/courses"
                    className="inline-flex items-center gap-2 bg-primary text-primary-foreground px-6 py-3 rounded-lg font-medium hover:bg-primary/90 transition-colors"
                >
                    {t('browse_courses')}
                    <ArrowRight className="w-4 h-4" />
                </Link>
            </div>
        </div>
    );
}
