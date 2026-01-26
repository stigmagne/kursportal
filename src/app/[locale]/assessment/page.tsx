import { createClient } from '@/utils/supabase/server';
import { Link, redirect } from '@/i18n/routing';
import { getTranslations } from 'next-intl/server';
import { ArrowRight, Users, Heart, Briefcase, UserCog, CheckCircle } from 'lucide-react';
import { getUserGroups, TARGET_GROUP_LABELS, TargetGroup } from '@/utils/userGroups';

const GROUP_ICONS: Record<TargetGroup, React.ComponentType<{ className?: string }>> = {
    'sibling': Users,
    'parent': Heart,
    'team-member': Briefcase,
    'team-leader': UserCog
};

export default async function AssessmentPage({ params }: { params: { locale: string } }) {
    const { locale } = await params;
    const t = await getTranslations('Assessment');
    const supabase = await createClient();

    // Require authentication
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return redirect({ href: '/login', locale });
    }

    // Fetch user's target groups
    const userGroups = await getUserGroups(supabase, user.id);

    // Fetch all assessment types
    const { data: allAssessmentTypes } = await supabase
        .from('assessment_types')
        .select('*')
        .order('target_group');

    // Fetch completed assessments for this user
    const { data: completedAssessments } = await supabase
        .from('assessment_sessions')
        .select('assessment_type_id')
        .eq('user_id', user.id)
        .eq('status', 'completed');

    const completedTypeIds = completedAssessments?.map(a => a.assessment_type_id) || [];

    // Filter to only show assessment types for user's groups
    const assessmentTypes = allAssessmentTypes?.filter(type =>
        userGroups.includes(type.target_group as TargetGroup)
    ) || [];

    // Show message if user has no groups
    const hasNoGroups = userGroups.length === 0;

    return (
        <div className="min-h-screen py-12">
            <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
                {/* Header */}
                <div className="text-center mb-12">
                    <h1 className="text-4xl font-bold mb-4">
                        {t('title', { defaultMessage: 'Finn Din Vei' })}
                    </h1>
                    <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
                        {t('subtitle', { defaultMessage: 'Ta vår korte vurdering for å få personlige anbefalinger tilpasset din situasjon.' })}
                    </p>
                </div>

                {/* No groups assigned message */}
                {hasNoGroups && (
                    <div className="mb-8 p-6 rounded-none border-2 border-amber-500 bg-amber-500/10 text-center">
                        <h2 className="font-bold text-xl mb-2">Ingen tilgang registrert</h2>
                        <p className="text-muted-foreground mb-4">
                            Du har ikke fått tildelt tilgang til noen vurdering ennå.
                            Kontakt din administrator eller bruk en invitasjonslenke for å få tilgang.
                        </p>
                    </div>
                )}

                {/* Assessment Type Selection - Only for user's groups */}
                {assessmentTypes.length > 0 && (
                    <div className="grid gap-6 md:grid-cols-2">
                        {assessmentTypes.map((type) => {
                            const Icon = GROUP_ICONS[type.target_group as TargetGroup] || Users;
                            const isCompleted = completedTypeIds.includes(type.id);

                            return (
                                <Link
                                    key={type.id}
                                    href={`/assessment/${type.slug}`}
                                    className={`group block p-8 rounded-none border-2 bg-card transition-all hover:shadow-lg ${isCompleted
                                            ? 'border-green-500/50 hover:border-green-500'
                                            : 'border-border hover:border-primary'
                                        }`}
                                >
                                    <div className="flex items-start gap-4">
                                        <div className={`w-14 h-14 rounded-none flex items-center justify-center shrink-0 transition-colors ${isCompleted
                                                ? 'bg-green-500/10 text-green-500'
                                                : 'bg-primary/10 text-primary group-hover:bg-primary group-hover:text-primary-foreground'
                                            }`}>
                                            {isCompleted ? (
                                                <CheckCircle className="w-7 h-7" />
                                            ) : (
                                                <Icon className="w-7 h-7" />
                                            )}
                                        </div>
                                        <div className="flex-1">
                                            <div className="flex items-center gap-2 mb-2">
                                                <h2 className="text-2xl font-bold group-hover:text-primary transition-colors">
                                                    {type.title_no}
                                                </h2>
                                                {isCompleted && (
                                                    <span className="text-xs bg-green-500/10 text-green-600 px-2 py-0.5 rounded-full">
                                                        Fullført
                                                    </span>
                                                )}
                                            </div>
                                            <p className="text-muted-foreground mb-4">
                                                {type.description_no}
                                            </p>
                                            <div className="flex items-center text-primary font-medium">
                                                {isCompleted ? 'Se resultater / Ta på nytt' : t('start', { defaultMessage: 'Start vurdering' })}
                                                <ArrowRight className="w-4 h-4 ml-2 group-hover:translate-x-1 transition-transform" />
                                            </div>
                                        </div>
                                    </div>
                                </Link>
                            );
                        })}
                    </div>
                )}

                {/* Info Section */}
                {!hasNoGroups && (
                    <div className="mt-12 p-6 rounded-none border-2 border-border bg-muted/30">
                        <h3 className="font-bold text-lg mb-4">
                            {t('how_it_works', { defaultMessage: 'Slik fungerer det' })}
                        </h3>
                        <div className="grid gap-4 md:grid-cols-3">
                            <div className="flex items-start gap-3">
                                <div className="w-8 h-8 rounded-full bg-primary text-primary-foreground flex items-center justify-center font-bold shrink-0">
                                    1
                                </div>
                                <div>
                                    <p className="font-medium">{t('step1_title', { defaultMessage: 'Svar på påstander' })}</p>
                                    <p className="text-sm text-muted-foreground">
                                        {t('step1_desc', { defaultMessage: 'Vurder hver påstand på en skala fra 1-7' })}
                                    </p>
                                </div>
                            </div>
                            <div className="flex items-start gap-3">
                                <div className="w-8 h-8 rounded-full bg-primary text-primary-foreground flex items-center justify-center font-bold shrink-0">
                                    2
                                </div>
                                <div>
                                    <p className="font-medium">{t('step2_title', { defaultMessage: 'Få innsikt' })}</p>
                                    <p className="text-sm text-muted-foreground">
                                        {t('step2_desc', { defaultMessage: 'Se resultatene visualisert' })}
                                    </p>
                                </div>
                            </div>
                            <div className="flex items-start gap-3">
                                <div className="w-8 h-8 rounded-full bg-primary text-primary-foreground flex items-center justify-center font-bold shrink-0">
                                    3
                                </div>
                                <div>
                                    <p className="font-medium">{t('step3_title', { defaultMessage: 'Få anbefalinger' })}</p>
                                    <p className="text-sm text-muted-foreground">
                                        {t('step3_desc', { defaultMessage: 'Se hvilke kurs som passer for deg' })}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                )}

                {/* Privacy Note */}
                <p className="text-center text-sm text-muted-foreground mt-8">
                    {t('privacy', { defaultMessage: 'Dine svar er private og brukes kun til å gi deg personlige anbefalinger.' })}
                </p>
            </div>
        </div>
    );
}
