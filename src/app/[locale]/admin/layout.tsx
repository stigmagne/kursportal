
import { createClient } from '@/utils/supabase/server'
import { redirect } from 'next/navigation'
import AdminSidebar from '@/components/admin/AdminSidebar'

export default async function AdminLayout({
    children,
}: {
    children: React.ReactNode
}) {
    const supabase = await createClient()

    const { data: { user } } = await supabase.auth.getUser()

    if (!user) {
        return redirect('/login')
    }

    // Fetch user profile to check role
    const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('role, full_name, id')
        .eq('id', user.id)
        .single()

    if (profile?.role !== 'admin') {
        return redirect('/dashboard') // Redirect standard members to dashboard
    }

    return (
        <div className="flex min-h-screen bg-muted/10">
            <AdminSidebar />
            <div className="flex-1 p-8 overflow-y-auto">
                {children}
            </div>
        </div>
    )

}
