import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { Resend } from 'resend';

// Initialize external clients
// We use supabase-js Admin client for Cron jobs to bypass RLS
const supabaseAdmin = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const resend = new Resend(process.env.RESEND_API_KEY);

export async function GET(request: NextRequest) {
    // 1. Security Check
    const authHeader = request.headers.get('authorization');
    if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
        return new NextResponse('Unauthorized', { status: 401 });
    }

    try {
        // 2. Fetch pending emails
        const { data: emails, error: fetchError } = await supabaseAdmin
            .from('email_queue')
            .select('*')
            .eq('status', 'pending')
            .lt('attempts', 3) // Retry limit
            .limit(50); // Batch size

        if (fetchError) throw fetchError;
        if (!emails || emails.length === 0) {
            return NextResponse.json({ message: 'No pending emails' });
        }

        const results = [];

        // 3. Process each email
        for (const email of emails) {
            try {
                // Parse email data
                const { to, subject, html, text } = email;

                // Send via Resend
                const { data: resendData, error: resendError } = await resend.emails.send({
                    from: 'Skoleskatter <skoleskatter@smeb.no>', // Configure this domain in Resend
                    to: [to],
                    subject: subject,
                    html: html,
                    text: text,
                });

                if (resendError) throw resendError;

                // Update status to 'sent'
                await supabaseAdmin
                    .from('email_queue')
                    .update({
                        status: 'sent',
                        sent_at: new Date().toISOString(),
                        updated_at: new Date().toISOString(),
                        metadata: { resend_id: resendData?.id }
                    })
                    .eq('id', email.id);

                results.push({ id: email.id, status: 'sent' });

            } catch (sendError: any) {
                // Update status to 'failed' or increment attempts
                console.error(`Failed to send email ${email.id}:`, sendError);

                await supabaseAdmin
                    .from('email_queue')
                    .update({
                        status: email.attempts >= 2 ? 'failed' : 'pending', // Fail after 3rd attempt (0, 1, 2)
                        attempts: email.attempts + 1,
                        last_attempt_at: new Date().toISOString(),
                        error_message: sendError.message,
                        updated_at: new Date().toISOString()
                    })
                    .eq('id', email.id);

                results.push({ id: email.id, status: 'error', error: sendError.message });
            }
        }

        return NextResponse.json({ processed: results.length, results });

    } catch (error) {
        console.error('Cron job error:', error);
        return new NextResponse('Internal Server Error', { status: 500 });
    }
}
