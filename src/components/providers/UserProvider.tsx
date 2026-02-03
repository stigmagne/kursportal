'use client';

import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { createClient } from '@/utils/supabase/client';
import type { User } from '@supabase/supabase-js';

export interface UserProfile {
    id: string;
    role: 'admin' | 'member';
    full_name: string | null;
    user_category?: string | null;
    subgroup?: string | null;
}

interface UserContextType {
    user: User | null;
    profile: UserProfile | null;
    isLoading: boolean;
    isAdmin: boolean;
    refetch: () => Promise<void>;
}

const UserContext = createContext<UserContextType | undefined>(undefined);

export function UserProvider({ children }: { children: ReactNode }) {
    const [user, setUser] = useState<User | null>(null);
    const [profile, setProfile] = useState<UserProfile | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const supabase = createClient();



    useEffect(() => {
        let mounted = true;

        // Immediately check for session
        supabase.auth.getSession().then(({ data: { session } }) => {
            if (!mounted) return;
            if (session?.user) {
                setUser(session.user);
                // Only fetch profile if we have a user
                fetchProfile(session.user.id);
            } else {
                setIsLoading(false);
            }
        });

        const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
            if (!mounted) return;

            setUser(session?.user ?? null);

            if (session?.user) {
                // Determine if we need to fetch profile (e.g. if user changed or profile missing)
                // For simplicity, we just fetch profile if user exists.
                // But we don't need to set isLoading(true) for the *entire* app if we just want to update profile.
                // However, to keep existing logic:
                fetchProfile(session.user.id);
            } else {
                setProfile(null);
                setIsLoading(false);
            }
        });

        return () => {
            mounted = false;
            subscription.unsubscribe();
        };
    }, []);

    const fetchProfile = async (userId: string) => {
        try {
            const { data } = await supabase
                .from('profiles')
                .select('id, role, full_name, user_category, subgroup')
                .eq('id', userId)
                .single();
            setProfile(data as UserProfile | null);
        } catch (error) {
            console.error('Error fetching profile:', error);
            setProfile(null);
        } finally {
            setIsLoading(false);
        }
    };

    const fetchUserAndProfile = async () => {
        setIsLoading(true);
        const { data: { user } } = await supabase.auth.getUser();
        setUser(user);

        if (user) {
            await fetchProfile(user.id);
        } else {
            setProfile(null);
            setIsLoading(false);
        }
    };

    const value: UserContextType = {
        user,
        profile,
        isLoading,
        isAdmin: profile?.role === 'admin',
        refetch: fetchUserAndProfile,
    };

    return (
        <UserContext.Provider value={value}>
            {children}
        </UserContext.Provider>
    );
}

export function useUser() {
    const context = useContext(UserContext);
    if (context === undefined) {
        throw new Error('useUser must be used within a UserProvider');
    }
    return context;
}
