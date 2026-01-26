import { SupabaseClient } from '@supabase/supabase-js';

export type TargetGroup = 'sibling' | 'parent' | 'team-member' | 'team-leader';

export const TARGET_GROUP_LABELS: Record<TargetGroup, string> = {
    'sibling': 'Søsken',
    'parent': 'Foreldre',
    'team-member': 'Team-medlem',
    'team-leader': 'Leder'
};

/**
 * Fetches the user's target groups from the database
 */
export async function getUserGroups(supabase: SupabaseClient, userId: string): Promise<TargetGroup[]> {
    const { data, error } = await supabase
        .from('user_groups')
        .select('target_group')
        .eq('user_id', userId);

    if (error) {
        console.error('Error fetching user groups:', error);
        return [];
    }

    return (data || []).map(row => row.target_group as TargetGroup);
}

/**
 * Checks if a user has access to a specific target group
 */
export function hasGroupAccess(userGroups: TargetGroup[], requiredGroup: TargetGroup): boolean {
    return userGroups.includes(requiredGroup);
}

/**
 * Gets the conflicting group for a given target group
 */
export function getConflictingGroup(group: TargetGroup): TargetGroup {
    const conflicts: Record<TargetGroup, TargetGroup> = {
        'sibling': 'parent',
        'parent': 'sibling',
        'team-member': 'team-leader',
        'team-leader': 'team-member'
    };
    return conflicts[group];
}

/**
 * Determines which "world" a group belongs to
 */
export function getGroupWorld(group: TargetGroup): 'family' | 'work' {
    if (group === 'sibling' || group === 'parent') {
        return 'family';
    }
    return 'work';
}

/**
 * Groups user's target groups by world
 */
export function groupByWorld(groups: TargetGroup[]): { family?: TargetGroup; work?: TargetGroup } {
    const result: { family?: TargetGroup; work?: TargetGroup } = {};
    for (const group of groups) {
        const world = getGroupWorld(group);
        result[world] = group;
    }
    return result;
}
