'use server';

import { createClient as createServerClient } from '@/utils/supabase/server';
import { createClient } from '@supabase/supabase-js';
import { revalidatePath } from 'next/cache';
import { AdminUser, AdminUserUpdate, BanDuration } from '@/types/admin';

// Helper to get admin client with service role
function getSupabaseAdmin() {
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!serviceRoleKey) {
        throw new Error('SUPABASE_SERVICE_ROLE_KEY is not defined. Please add it to your .env.local file to enable admin actions.');
    }

    return createClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        serviceRoleKey,
        {
            auth: {
                autoRefreshToken: false,
                persistSession: false
            }
        }
    );
}

// Helper to verify admin role - throws if not admin
async function requireAdminRole(): Promise<string> {
    const supabase = await createServerClient();

    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
        throw new Error('Unauthorized: Not authenticated');
    }

    const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    if (profileError || profile?.role !== 'admin') {
        throw new Error('Forbidden: Admin access required');
    }

    return user.id;
}

export async function getAdminUsers(): Promise<AdminUser[]> {
    // Verify admin before proceeding
    await requireAdminRole();

    const supabase = await createServerClient();

    // Fetch profiles
    const { data: profiles, error: profilesError } = await supabase
        .from('profiles')
        .select('*')
        .order('created_at', { ascending: false });

    if (profilesError) throw new Error(`Error fetching profiles: ${profilesError.message}`);

    // List users with safer pagination to avoid timeouts
    let authUsers: any[] = [];
    try {
        const { data, error: authError } = await getSupabaseAdmin().auth.admin.listUsers({
            page: 1,
            perPage: 10
        });

        if (authError) {
            console.warn('Warning: Could not fetch auth users.', authError.message);
        } else {
            authUsers = data?.users || [];
        }
    } catch (error) {
        console.error('Unexpected exception fetching auth users:', error);
    }

    // Merge data
    const mergedUsers: AdminUser[] = profiles.map((profile: any) => {
        const authUser = authUsers.find((u) => u.id === profile.id);
        return {
            id: profile.id,
            email: authUser?.email || null,
            full_name: profile.full_name,
            role: profile.role || 'member',
            created_at: profile.created_at,
            category: profile.user_category,
            subgroup: profile.subgroup,
            banned_until: authUser?.banned_until || null,
        };
    });

    return mergedUsers;
}

export async function toggleBanUser(userId: string, duration: BanDuration) {
    // Verify admin before proceeding
    await requireAdminRole();

    let bannedUntil: string | null = null;

    if (duration !== 'none') {
        const now = new Date();
        if (duration === '24h') now.setHours(now.getHours() + 24);
        else if (duration === '7d') now.setDate(now.getDate() + 7);
        else if (duration === '30d') now.setDate(now.getDate() + 30);
        else if (duration === 'permanent') now.setFullYear(now.getFullYear() + 100);

        bannedUntil = now.toISOString();
    }

    const updateAttributes: any = {};
    if (duration === 'none') {
        updateAttributes.ban_duration = 'none';
    } else {
        if (duration === '24h') updateAttributes.ban_duration = '24h';
        if (duration === '7d') updateAttributes.ban_duration = '168h';
        if (duration === '30d') updateAttributes.ban_duration = '720h';
        if (duration === 'permanent') updateAttributes.ban_duration = '876000h';
    }

    const { error: updateError } = await getSupabaseAdmin().auth.admin.updateUserById(userId, updateAttributes);

    if (updateError) throw new Error(`Error banning user: ${updateError.message}`);

    revalidatePath('/admin/users');
    return { success: true };
}

export async function updateUser(userId: string, data: AdminUserUpdate) {
    // Verify admin before proceeding
    await requireAdminRole();

    const supabaseAdmin = getSupabaseAdmin();

    const updates: any = {};
    if (data.full_name !== undefined) updates.full_name = data.full_name;
    if (data.category !== undefined) updates.user_category = data.category;
    if (data.subgroup !== undefined) updates.subgroup = data.subgroup;
    if (data.role !== undefined) updates.role = data.role;

    const { error } = await supabaseAdmin
        .from('profiles')
        .update(updates)
        .eq('id', userId);

    if (error) throw new Error(`Error updating user: ${error.message}`);

    revalidatePath('/admin/users');
    return { success: true };
}

export async function anonymizeUser(userId: string) {
    // Verify admin before proceeding
    await requireAdminRole();

    // 1. Anonymize Auth User and Ban
    const timestamp = new Date().getTime();
    const anonymizedEmail = `anonymized_${userId}_${timestamp}@deleted.user`;

    const { error: authError } = await getSupabaseAdmin().auth.admin.updateUserById(userId, {
        email: anonymizedEmail,
        user_metadata: { full_name: 'Anonymisert Bruker' },
        app_metadata: {},
        ban_duration: '876000h'
    });

    if (authError) throw new Error(`Error anonymizing auth user: ${authError.message}`);

    // 2. Anonymize Profile using admin client
    const { error: profileError } = await getSupabaseAdmin()
        .from('profiles')
        .update({
            full_name: 'Anonymisert Bruker',
            user_category: null,
            subgroup: null,
            role: 'user',
        })
        .eq('id', userId);

    if (profileError) throw new Error(`Error anonymizing profile: ${profileError.message}`);

    revalidatePath('/admin/users');
    return { success: true };
}
