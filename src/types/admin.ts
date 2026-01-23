export interface AdminUser {
    id: string;
    email: string | null;
    full_name: string | null;
    role: string;
    created_at: string;
    category: string | null; // 'sibling', 'parent', 'healthcare'
    subgroup?: string | null;
    banned_until?: string | null; // ISO timestamp
}

export type BanDuration = '24h' | '7d' | '30d' | 'permanent' | 'none';

export interface AdminUserUpdate {
    full_name?: string;
    role?: string;
    category?: string;
    subgroup?: string;
}
