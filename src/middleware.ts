
import { type NextRequest, NextResponse } from 'next/server'
import { updateSession } from '@/utils/supabase/middleware'
import createMiddleware from 'next-intl/middleware';
import { routing } from '@/i18n/routing';
import { rateLimit } from '@/utils/rate-limit';

const intlMiddleware = createMiddleware(routing);

export async function middleware(request: NextRequest) {
    // Rate limit API routes and auth endpoints
    const pathname = request.nextUrl.pathname;
    const ip = request.headers.get('x-forwarded-for')?.split(',')[0]?.trim() || 'unknown';

    if (pathname.startsWith('/api/')) {
        const { allowed } = rateLimit(`api:${ip}`, { maxRequests: 30, windowMs: 60_000 });
        if (!allowed) {
            return NextResponse.json({ error: 'Too many requests' }, { status: 429 });
        }
    }

    const pathWithoutLocale = pathname.replace(/^\/(no|en)/, '') || '/';
    if (pathWithoutLocale === '/login' && request.method === 'POST') {
        const { allowed } = rateLimit(`auth:${ip}`, { maxRequests: 5, windowMs: 60_000 });
        if (!allowed) {
            return NextResponse.json({ error: 'Too many login attempts. Please try again later.' }, { status: 429 });
        }
    }

    const response = intlMiddleware(request);
    return await updateSession(request, response);
}

export const config = {
    matcher: ['/', '/(no|en)/:path*', '/((?!_next|_vercel|.*\\..*).*)'],
}
