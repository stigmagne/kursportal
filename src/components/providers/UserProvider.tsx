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

    const fetchUserAndProfile = async () => {
        setIsLoading(true);
        const { data: { user } } = await supabase.auth.getUser();
        setUser(user);

        if (user) {
            const { data } = await supabase
                .from('profiles')
                .select('id, role, full_name, user_category, subgroup')
                .eq('id', user.id)
                .single();
            setProfile(data as UserProfile | null);
        } else {
            setProfile(null);
        }
        setIsLoading(false);
    };

    useEffect(() => {
        fetchUserAndProfile();

        // Listen for auth changes
        const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
            setUser(session?.user ?? null);
            if (!session?.user) {
                setProfile(null);
                setIsLoading(false);
            } else {
                fetchUserAndProfile();
            }
        });

        return () => subscription.unsubscribe();
    }, []);

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
