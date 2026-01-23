'use server';

import { createClient } from '@supabase/supabase-js';
import { revalidatePath } from 'next/cache';
import { AdminUser, AdminUserUpdate, BanDuration } from '@/types/admin';
import { createClient as createServerClient } from '@/utils/supabase/server';

// Helper to get admin client with check
// This prevents top-level errors if the key is missing, and provides a clear error message when used.
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

export async function getAdminUsers(): Promise<AdminUser[]> {
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
        console.log('DEBUG: Starting getAdminUsers (Safe Mode)');
        const { data, error: authError } = await getSupabaseAdmin().auth.admin.listUsers({
            page: 1,
            perPage: 10 // Further decreased to 10 to completely avoid Supabase timeouts
        });

        if (authError) {
            console.warn('Warning: Could not fetch auth users (Supabase API error). Admin list will show profiles only.', authError.message);
            // We continue without throwing to allow profiles to load
        } else {
            authUsers = data?.users || [];
        }
    } catch (error) {
        console.error('Unexpected exception fetching auth users:', error);
        // Continue gracefully
    }

    // Merge data
    const mergedUsers: AdminUser[] = profiles.map((profile: any) => {
        const authUser = authUsers.find((u) => u.id === profile.id);
        return {
            id: profile.id,
            email: authUser?.email || null,
            full_name: profile.full_name,
            role: profile.role || 'member', // Default to member if not set
            created_at: profile.created_at,
            category: profile.user_category,
            subgroup: profile.subgroup,
            banned_until: authUser?.banned_until || null,
        };
    });

    return mergedUsers;
}

export async function toggleBanUser(userId: string, duration: BanDuration) {
    let bannedUntil: string | null = null;

    if (duration !== 'none') {
        const now = new Date();
        if (duration === '24h') now.setHours(now.getHours() + 24);
        else if (duration === '7d') now.setDate(now.getDate() + 7);
        else if (duration === '30d') now.setDate(now.getDate() + 30);
        else if (duration === 'permanent') now.setFullYear(now.getFullYear() + 100); // Effectively permanent

        bannedUntil = now.toISOString();
    }

    // First call to check logic, mostly creating the duration string
    const updateAttributes: any = {};
    if (duration === 'none') {
        updateAttributes.ban_duration = 'none'; // This is how to unban in recent Supabase versions
    } else {
        // Recalculate duration string for API
        if (duration === '24h') updateAttributes.ban_duration = '24h';
        if (duration === '7d') updateAttributes.ban_duration = '168h';
        if (duration === '30d') updateAttributes.ban_duration = '720h';
        if (duration === 'permanent') updateAttributes.ban_duration = '876000h'; // 100 years
    }

    const { error: updateError } = await getSupabaseAdmin().auth.admin.updateUserById(userId, updateAttributes);

    if (updateError) throw new Error(`Error banning user: ${updateError.message}`);

    revalidatePath('/admin/users');
    return { success: true };
}

export async function updateUser(userId: string, data: AdminUserUpdate) {
    // Use service role admin client to bypass RLS and triggers that block standard users
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
    // 1. Anonymize Auth User (email, metadata) and Ban
    const timestamp = new Date().getTime();
    const anonymizedEmail = `anonymized_${userId}_${timestamp}@deleted.user`;

    const { error: authError } = await getSupabaseAdmin().auth.admin.updateUserById(userId, {
        email: anonymizedEmail,
        user_metadata: { full_name: 'Anonymisert Bruker' },
        app_metadata: {},
        ban_duration: '876000h' // Permanent ban
    });

    if (authError) throw new Error(`Error anonymizing auth user: ${authError.message}`);

    // 2. Anonymize Profile
    const supabase = await createServerClient(); // Use regular client for RLS respecting updates (or admin if RLS blocks)
    // Assuming admins can update profiles via RLS

    const { error: profileError } = await supabase
        .from('profiles')
        .update({
            full_name: 'Anonymisert Bruker',
            user_category: null,
            subgroup: null,
            role: 'user', // demote to basic user
            // Add other fields to clear if necessary
        })
        .eq('id', userId);

    // If RLS fails (admin can't write to other profiles?), we might need supabaseAdmin for this too.
    // Safest to use supabaseAdmin for the profile update too to ensure it works.

    if (profileError) {
        // Fallback to admin client if RLS blocked it
        const { error: adminProfileError } = await getSupabaseAdmin()
            .from('profiles')
            .update({
                full_name: 'Anonymisert Bruker',
                user_category: null,
                subgroup: null,
                role: 'user',
            })
            .eq('id', userId);

        if (adminProfileError) throw new Error(`Error anonymizing profile: ${adminProfileError.message}`);
    }

    revalidatePath('/admin/users');
    return { success: true };
}
