
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

    const {
        data: { user },
    } = await supabase.auth.getUser()

    if (
        !user &&
        !request.nextUrl.pathname.startsWith('/login') &&
        !request.nextUrl.pathname.startsWith('/auth') &&
        request.nextUrl.pathname !== '/'
    ) {
        // no user, potentially redirect? 
        // For now, next.js middleware just refreshes session. Protection is better handled in layouts/pages or here.
        // The previous instructions often suggest redirecting here.
        // Let's keep it simple: just refresh session. PageAuth will handle redirects.
        // OR if I want global protection:
        // const url = request.nextUrl.clone()
        // url.pathname = '/login'
        // return NextResponse.redirect(url)
    }

    return supabaseResponse
}
