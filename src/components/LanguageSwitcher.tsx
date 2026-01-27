'use client';

import { useLocale } from 'next-intl';
import { usePathname, useRouter } from '@/i18n/routing';
import { ChangeEvent, useTransition } from 'react';
import { Globe } from 'lucide-react';

export default function LanguageSwitcher() {
    const locale = useLocale();
    const router = useRouter();
    const [isPending, startTransition] = useTransition();
    const pathname = usePathname();

    function onSelectChange(event: ChangeEvent<HTMLSelectElement>) {
        const nextLocale = event.target.value;
        startTransition(() => {
            router.replace(pathname, { locale: nextLocale });
        });
    }

    return (
        <div className="flex items-center gap-2 px-2 py-1 rounded-none hover:bg-white/5 transition-colors">
            <Globe className="w-4 h-4 text-muted-foreground" />
            <select
                defaultValue={locale}
                className="bg-transparent text-sm font-medium focus:outline-none cursor-pointer"
                onChange={onSelectChange}
                disabled={isPending}
            >
                <option value="en" className="text-black">English</option>
                <option value="no" className="text-black">Norsk</option>
            </select>
        </div>
    );
}
