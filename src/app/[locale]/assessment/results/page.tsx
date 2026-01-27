import { createClient } from '@/utils/supabase/server';
import { redirect } from '@/i18n/routing';
import { Link } from '@/i18n/routing';
import { getTranslations } from 'next-intl/server';
import { ArrowRight, BookOpen, Sparkles } from 'lucide-react';
import { AssessmentHistory as AssessmentHistoryWrapper } from '@/components/assessment/AssessmentHistory';

interface Props {
    params: { locale: string };
    searchParams: { session?: string };
}

export default async function AssessmentResultsPage({ params, searchParams }: Props) {
    const { locale } = await params;
    const { session: sessionId } = await searchParams;
    const t = await getTranslations('Assessment');
    const supabase = await createClient();

    // Check authentication
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return redirect({ href: '/login', locale });
    }

    if (!sessionId) {
        return redirect({ href: '/assessment', locale });
    }

    // Get session with results
    const { data: session } = await supabase
        .from('assessment_sessions')
        .select(`
            *,
            assessment_type:assessment_types(title_no, target_group)
        `)
        .eq('id', sessionId)
        .eq('user_id', user.id)
        .single();

    if (!session) {
        return redirect({ href: '/assessment', locale });
    }

    // Get results with dimension details
    const { data: results } = await supabase
        .from('assessment_results')
        .select(`
            *,
            dimension:assessment_dimensions(
                name_no,
                description_no,
                low_score_interpretation_no,
                high_score_interpretation_no,
                recommended_course_ids
            )
        `)
        .eq('session_id', sessionId)
        .order('normalized_score', { ascending: true });

    // Get recommended courses based on low-scoring dimensions
    const lowScoringDimensions = results?.filter(r => r.normalized_score < 50) || [];
    const courseIds = lowScoringDimensions
        .flatMap(d => d.dimension?.recommended_course_ids || [])
        .filter((id, index, self) => self.indexOf(id) === index);

    let recommendedCourses: any[] = [];
    if (courseIds.length > 0) {
        const { data } = await supabase
            .from('courses')
            .select('id, title, description, slug')
            .in('id', courseIds);
        recommendedCourses = data || [];
    }

    // Calculate overall score
    const overallScore = results?.reduce((acc, r) => acc + r.normalized_score, 0) / (results?.length || 1);

    return (
        <div className="min-h-screen py-12">
            <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
                {/* Header */}
                <div className="text-center mb-12">
                    <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 text-primary mb-4">
                        <Sparkles className="w-8 h-8" />
                    </div>
                    <h1 className="text-3xl font-bold mb-2">
                        {t('results_title', { defaultMessage: 'Dine Resultater' })}
                    </h1>
                    <p className="text-muted-foreground">
                        {session.assessment_type.title_no}
                    </p>
                </div>

                {/* Dimension Results */}
                <div className="space-y-4 mb-12">
                    <h2 className="font-bold text-xl mb-4">
                        {t('your_profile', { defaultMessage: 'Din profil' })}
                    </h2>

                    {results?.map((result) => {
                        const score = Math.round(result.normalized_score);
                        const isLow = score < 40;
                        const isMedium = score >= 40 && score < 60;
                        const isHigh = score >= 60;

                        return (
                            <div
                                key={result.id}
                                className="p-4 rounded-none border-2 border-border bg-card"
                            >
                                <div className="flex items-center justify-between mb-2">
                                    <h3 className="font-medium">{result.dimension.name_no}</h3>
                                    <span className={`font-bold ${isLow ? 'text-amber-500' : isHigh ? 'text-green-500' : 'text-blue-500'}`}>
                                        {score}%
                                    </span>
                                </div>

                                {/* Progress Bar */}
                                <div className="w-full h-3 bg-muted rounded-full overflow-hidden mb-3">
                                    <div
                                        className={`h-full transition-all duration-500 ${isLow ? 'bg-amber-500' : isHigh ? 'bg-green-500' : 'bg-blue-500'
                                            }`}
                                        style={{ width: `${score}%` }}
                                    />
                                </div>

                                {/* Interpretation */}
                                <p className="text-sm text-muted-foreground">
                                    {isLow
                                        ? result.dimension.low_score_interpretation_no
                                        : result.dimension.high_score_interpretation_no
                                    }\n                                </p>
                            </div>
                        );
                    })}
                </div>

                {/* Progress Comparison */}
                <AssessmentHistoryWrapper
                    currentSessionId={sessionId}
                    userId={user.id}
                    assessmentTypeId={session.assessment_type_id}
                />

                {/* Recommended Courses */}
                {recommendedCourses.length > 0 && (
                    <div className="mb-12">
                        <h2 className="font-bold text-xl mb-4 flex items-center gap-2">
                            <BookOpen className="w-5 h-5 text-primary" />
                            {t('recommended_courses', { defaultMessage: 'Anbefalte kurs for deg' })}
                        </h2>

                        <div className="grid gap-4">
                            {recommendedCourses.map((course, index) => (
                                <Link
                                    key={course.id}
                                    href={`/courses/${course.slug}`}
                                    className="group flex items-center gap-4 p-4 rounded-none border-2 border-border bg-card hover:border-primary transition-colors"
                                >
                                    <div className="w-10 h-10 rounded-none bg-primary/10 flex items-center justify-center text-primary font-bold shrink-0">
                                        {index + 1}
                                    </div>
                                    <div className="flex-1">
                                        <h3 className="font-medium group-hover:text-primary transition-colors">
                                            {course.title}
                                        </h3>
                                        <p className="text-sm text-muted-foreground line-clamp-1">
                                            {course.description}
                                        </p>
                                    </div>
                                    <ArrowRight className="w-5 h-5 text-muted-foreground group-hover:text-primary group-hover:translate-x-1 transition-all" />
                                </Link>
                            ))}
                        </div>
                    </div>
                )}

                {/* Call to Action */}
                <div className="text-center p-8 rounded-none border-2 border-primary bg-primary/5">
                    <h3 className="font-bold text-xl mb-2">
                        {t('ready_to_start', { defaultMessage: 'Klar til å begynne?' })}
                    </h3>
                    <p className="text-muted-foreground mb-6">
                        {t('journey_description', { defaultMessage: 'Start din utviklingsreise med kursene vi har anbefalt for deg.' })}
                    </p>
                    <div className="flex flex-col sm:flex-row gap-4 justify-center">
                        <Link
                            href="/courses"
                            className="inline-flex items-center justify-center gap-2 px-6 py-3 bg-primary text-primary-foreground font-medium rounded-none border-2 border-primary hover:bg-primary/90 transition-colors"
                        >
                            {t('browse_courses', { defaultMessage: 'Se alle kurs' })}
                            <ArrowRight className="w-4 h-4" />
                        </Link>
                        <Link
                            href="/journal/tools"
                            className="inline-flex items-center justify-center gap-2 px-6 py-3 bg-background text-foreground font-medium rounded-none border-2 border-border hover:border-primary transition-colors"
                        >
                            {t('explore_tools', { defaultMessage: 'Utforsk journalverktøy' })}
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    );
}
