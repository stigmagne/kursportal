
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function updateSession(request: NextRequest, response?: NextResponse) {
    let supabaseResponse = response || NextResponse.next({
        request,
    })

    const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
            cookies: {
                getAll() {
                    return request.cookies.getAll()
                },
                setAll(cookiesToSet) {
                    cookiesToSet.forEach(({ name, value, options }) => request.cookies.set(name, value))

                    // Only recreate response if we didn't receive one (to pass updated request)
                    // If we have a response (e.g. redirect from i18n), we must preserve it
                    if (!response) {
                        supabaseResponse = NextResponse.next({
                            request,
                        })
                    }

                    cookiesToSet.forEach(({ name, value, options }) =>
                        supabaseResponse.cookies.set(name, value, options)
                    )
                },
            },
        }
    )

    // IMPORTANT: Avoid writing any logic between createServerClient and
    // supabase.auth.getUser(). A simple mistake could make it very hard to debug
    // issues with users being randomly logged out.

    // OPTIMIZATION: On public routes, skip getUser() if no auth cookies exist
    // This prevents unnecessary formatting latency for guest users
    const isPublicPath = pathWithoutLocale === '/' ||
        pathWithoutLocale.startsWith('/login') ||
        pathWithoutLocale.startsWith('/auth') ||
        pathWithoutLocale === '/pricing';

    const hasAuthCookie = request.cookies.getAll().some(c => c.name.startsWith('sb-'));

    let user = null;

    if (hasAuthCookie || !isPublicPath) {
        // Only call getUser if we might have a session or MUST check auth
        const { data: { user: authUser } } = await supabase.auth.getUser()
        user = authUser;
    }

    const pathname = request.nextUrl.pathname

    // Extract locale-agnostic path
    const pathWithoutLocale = pathname.replace(/^\/(no|en)/, '') || '/'

    // SECURITY: Protect admin routes - require authentication AND admin role
    if (pathWithoutLocale.startsWith('/admin')) {
        if (!user) {
            // Not authenticated - redirect to login
            const url = request.nextUrl.clone()
            url.pathname = '/login'
            return NextResponse.redirect(url)
        }

        // Check if user has admin role
        const { data: profile } = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single()

        if (profile?.role !== 'admin') {
            // User is authenticated but not admin - redirect to dashboard
            const url = request.nextUrl.clone()
            url.pathname = '/dashboard'
            return NextResponse.redirect(url)
        }
    }

    // Protect other authenticated routes
    if (
        !user &&
        !pathWithoutLocale.startsWith('/login') &&
        !pathWithoutLocale.startsWith('/auth') &&
        pathWithoutLocale !== '/' &&
        pathWithoutLocale !== '/pricing'
    ) {
        // Optionally redirect unauthenticated users
        // For now, let page-level auth handle this
    }

    return supabaseResponse
}
