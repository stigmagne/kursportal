import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

// Initialize external clients
const supabaseAdmin = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function GET(request: NextRequest) {
    // 1. Security Check
    const authHeader = request.headers.get('authorization');
    if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
        return new NextResponse('Unauthorized', { status: 401 });
    }

    try {
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
        const dateStr = sevenDaysAgo.toISOString();

        // 2. Find enrollments older than 7 days where course is not completed
        // We assume 'user_progress' has 'created_at', 'status', 'user_id', 'course_id'
        const { data: stagnantEnrollments, error: fetchError } = await supabaseAdmin
            .from('user_progress')
            .select(`
        id,
        user_id,
        course_id,
        created_at,
        status,
        courses (
          title
        ),
        profiles (
          full_name,
          email
        )
      `)
            .lt('created_at', dateStr)
            .neq('status', 'completed')
            // Optional: Filter out those who have updated recently if 'last_accessed' exists
            // .lt('last_accessed', dateStr) 
            .limit(50); // Batch size

        if (fetchError) throw fetchError;
        if (!stagnantEnrollments || stagnantEnrollments.length === 0) {
            return NextResponse.json({ message: 'No stale enrollments found' });
        }

        const queuedResults = [];

        // 3. Queue reminders
        for (const enrollment of stagnantEnrollments) {
            // Double check: ensure we haven't sent a reminder for THIS course recently (e.g. in last 14 days)
            // or ever? For MVP, let's limit to "one reminder per course" or "one per week".
            // Let's check if we have queued a reminder for this user+course in the last 14 days.

            const twoWeeksAgo = new Date();
            twoWeeksAgo.setDate(twoWeeksAgo.getDate() - 14);

            const { count } = await supabaseAdmin
                .from('email_queue')
                .select('id', { count: 'exact', head: true })
                .eq('user_id', enrollment.user_id)
                .eq('email_type', 'reminder')
                .gte('created_at', twoWeeksAgo.toISOString())
                .contains('template_data', { course_id: enrollment.course_id });

            if (count && count > 0) {
                continue; // Already reminded recently
            }

            // Also check if user has opted out of reminders
            const { data: prefs } = await supabaseAdmin
                .from('email_preferences')
                .select('course_reminders')
                .eq('user_id', enrollment.user_id)
                .single();

            if (prefs && prefs.course_reminders === false) {
                continue; // User opted out
            }

            const userEmail = (enrollment.profiles as any)?.email;
            if (!userEmail) continue;

            // Queue the email
            const { error: queueError } = await supabaseAdmin
                .from('email_queue')
                .insert({
                    user_id: enrollment.user_id,
                    email_type: 'reminder',
                    recipient_email: userEmail,
                    subject: `Påminnelse: ${enrollment.courses?.title}`,
                    template_data: {
                        user_name: (enrollment.profiles as any)?.full_name || 'Student',
                        course_title: enrollment.courses?.title,
                        course_id: enrollment.course_id,
                        course_url: `/courses/${enrollment.course_id}`
                    }
                });

            if (!queueError) {
                queuedResults.push(enrollment.id);
            }
        }

        return NextResponse.json({
            message: 'Processed reminders',
            found: stagnantEnrollments.length,
            queued: queuedResults.length
        });

    } catch (error: any) {
        console.error('Cron job error:', error);
        return new NextResponse('Internal Server Error: ' + error.message, { status: 500 });
    }
}
