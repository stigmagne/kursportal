'use server';

import { createClient } from '@/utils/supabase/server';
import { z } from 'zod';

const bugReportSchema = z.object({
    title: z.string().min(3, 'Title must be at least 3 characters').max(200, 'Title too long'),
    description: z.string().min(10, 'Description must be at least 10 characters').max(2000, 'Description too long'),
    pageUrl: z.string().optional(),
    browserInfo: z.string().optional(),
});

export type BugReportInput = z.infer<typeof bugReportSchema>;

export async function submitBugReport(formData: BugReportInput) {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return { error: 'Not authenticated' };
    }

    const validated = bugReportSchema.safeParse(formData);
    if (!validated.success) {
        return { error: validated.error.issues[0].message };
    }

    // Fetch user profile for email and name
    const { data: profile } = await supabase
        .from('profiles')
        .select('full_name, email')
        .eq('id', user.id)
        .single();

    const { error } = await supabase
        .from('bug_reports')
        .insert({
            user_id: user.id,
            email: profile?.email || user.email,
            full_name: profile?.full_name,
            title: validated.data.title,
            description: validated.data.description,
            page_url: validated.data.pageUrl,
            browser_info: validated.data.browserInfo,
        });

    if (error) {
        console.error('Bug report submission error:', error);
        return { error: 'Failed to submit report. Please try again.' };
    }

    return { success: true };
}

export async function updateBugReportStatus(
    reportId: string,
    status: 'open' | 'in-progress' | 'resolved' | 'closed',
    priority?: 'low' | 'medium' | 'high' | 'critical',
    adminNotes?: string
) {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return { error: 'Not authenticated' };
    }

    // Verify admin role
    const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    if (profile?.role !== 'admin') {
        return { error: 'Unauthorized' };
    }

    const updateData: any = {
        status,
        updated_at: new Date().toISOString(),
    };

    if (priority) {
        updateData.priority = priority;
    }

    if (adminNotes !== undefined) {
        updateData.admin_notes = adminNotes;
    }

    const { error } = await supabase
        .from('bug_reports')
        .update(updateData)
        .eq('id', reportId);

    if (error) {
        console.error('Bug report update error:', error);
        return { error: 'Failed to update report' };
    }

    return { success: true };
}

export async function getAllBugReports() {
    const supabase = await createClient();

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
        return { error: 'Not authenticated' };
    }

    // Verify admin role
    const { data: profile } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    if (profile?.role !== 'admin') {
        return { error: 'Unauthorized' };
    }

    const { data, error } = await supabase
        .from('bug_reports')
        .select('*')
        .order('created_at', { ascending: false });

    if (error) {
        console.error('Fetch bug reports error:', error);
        return { error: 'Failed to fetch reports' };
    }

    return { data };
}
