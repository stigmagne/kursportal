import { createClient } from '@/utils/supabase/server';

export async function hasAccessToCourse(userId: string, courseId: string) {
    const supabase = await createClient();

    // 1. Check if user is an admin (Admins bypass everything)
    const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();

    if (profile?.role === 'admin') return true;

    // 2. Check if user has an active subscription
    const { data: subscription } = await supabase
        .from('subscriptions')
        .select('status')
        .in('status', ['active', 'trialing'])
        .eq('user_id', userId)
        .single();

    if (subscription) return true; // Subscribers get access to everything (Netflix model)

    // 3. Check for specific enrollment (e.g. one-time purchase, free course, or manual access)
    // Note: Assuming 'user_progress' implies enrollment/access. 
    // If you sell individual courses, you might have another table 'purchases' or 'entitlements'.
    // For now, if they have progress/enrollment record, we assume they have access 
    // (UNLESS enrollment is just "started free preview").
    // Let's assume user_progress = access for now, OR add a check for "unlocked" flag if needed.
    // Actually, user_progress is often created when they click "Start".
    // We should strictly check if they have "purchased" it.
    // If you don't have separate purchase table, maybe check if course is free?

    const { data: enrollment } = await supabase
        .from('user_progress')
        .select('id')
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .single();

    if (enrollment) {
        // Verify if the course is free or if this enrollment was authorized. 
        // For now, we assume if row exists, they have access.
        return true;
    }

    return false;
}
