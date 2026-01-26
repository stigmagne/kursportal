import { createClient } from '@/utils/supabase/server';
import { redirect } from '@/i18n/routing';
import { Link } from '@/i18n/routing';
import { getTranslations } from 'next-intl/server';

interface Props {
    params: { locale: string };
}

export default async function JournalToolsPage({ params }: Props) {
    const { locale } = await params;
    const t = await getTranslations('Journal');
    const supabase = await createClient();

    // Check authentication
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return redirect({ href: '/login', locale });
    }

    // Get tool types with their tools
    const { data: toolTypes } = await supabase
        .from('journal_tool_types')
        .select(`
            *,
            tools:journal_tools(*)
        `)
        .order('order_index');

    return (
        <div className="min-h-screen py-12">
            <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
                {/* Header */}
                <div className="mb-8">
                    <h1 className="text-3xl font-bold mb-2">
                        {t('tools_title', { defaultMessage: 'Journalverktøy' })}
                    </h1>
                    <p className="text-muted-foreground">
                        {t('tools_subtitle', { defaultMessage: 'Verktøy for refleksjon, måling og personlig vekst. Alt er kryptert og privat.' })}
                    </p>
                </div>

                {/* Back to Journal */}
                <div className="mb-6">
                    <Link
                        href="/journal"
                        className="text-primary hover:underline text-sm"
                    >
                        ← {t('back_to_journal', { defaultMessage: 'Tilbake til journal' })}
                    </Link>
                </div>

                {/* Tool Categories */}
                <div className="space-y-8">
                    {toolTypes?.map((category) => (
                        <div key={category.id}>
                            <div className="flex items-center gap-3 mb-4">
                                <span className="text-2xl">{category.icon}</span>
                                <div>
                                    <h2 className="font-bold text-xl">{category.name_no}</h2>
                                    <p className="text-sm text-muted-foreground">{category.description_no}</p>
                                </div>
                            </div>

                            <div className="grid gap-4 sm:grid-cols-2">
                                {category.tools?.map((tool: any) => (
                                    <Link
                                        key={tool.id}
                                        href={`/journal/tools/${tool.slug}`}
                                        className="group block p-4 rounded-none border-2 border-border bg-card hover:border-primary transition-all hover:shadow-md"
                                    >
                                        <div className="flex items-start gap-3">
                                            <span className="text-2xl">{tool.icon}</span>
                                            <div className="flex-1">
                                                <h3 className="font-medium group-hover:text-primary transition-colors">
                                                    {tool.name_no}
                                                </h3>
                                                <p className="text-sm text-muted-foreground line-clamp-2">
                                                    {tool.description_no}
                                                </p>
                                                <div className="mt-2">
                                                    <span className="inline-block px-2 py-0.5 text-xs bg-muted rounded-full">
                                                        {tool.input_type === 'freetext' && 'Fritekst'}
                                                        {tool.input_type === 'scale' && 'Skala'}
                                                        {tool.input_type === 'structured' && 'Strukturert'}
                                                        {tool.input_type === 'checklist' && 'Sjekkliste'}
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </Link>
                                ))}
                            </div>
                        </div>
                    ))}
                </div>

                {/* Privacy Notice */}
                <div className="mt-12 p-4 rounded-none border-2 border-border bg-muted/30">
                    <div className="flex items-start gap-3">
                        <span className="text-xl">🔒</span>
                        <div>
                            <h3 className="font-medium">
                                {t('privacy_title', { defaultMessage: 'Zero-Knowledge Kryptering' })}
                            </h3>
                            <p className="text-sm text-muted-foreground">
                                {t('privacy_description', { defaultMessage: 'Alt du skriver krypteres med AES-256-GCM før det lagres. Kun du har tilgang til innholdet.' })}
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
