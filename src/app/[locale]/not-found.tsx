import { FileQuestion } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { getTranslations } from 'next-intl/server';

export default async function NotFound() {
    const t = await getTranslations('NotFound');

    return (
        <div className="min-h-screen flex items-center justify-center p-4">
            <div className="text-center space-y-6">
                <div className="w-24 h-24 mx-auto rounded-full bg-muted flex items-center justify-center">
                    <FileQuestion className="w-12 h-12 text-muted-foreground" />
                </div>
                <div>
                    <h1 className="text-6xl font-bold mb-2">404</h1>
                    <p className="text-xl text-muted-foreground">{t('title')}</p>
                </div>
                <Link
                    href="/"
                    className="inline-block px-6 py-2 bg-primary text-primary-foreground rounded-lg font-medium hover:bg-primary/90 transition-colors"
                >
                    {t('back_home')}
                </Link>
            </div>
        </div>
    );
}
