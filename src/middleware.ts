
import { type NextRequest } from 'next/server'
import { updateSession } from '@/utils/supabase/middleware'
import createMiddleware from 'next-intl/middleware';
import { routing } from '@/i18n/routing';

const intlMiddleware = createMiddleware(routing);

export async function middleware(request: NextRequest) {
    const response = intlMiddleware(request);
    return await updateSession(request, response);
}

export const config = {
    matcher: ['/', '/(no|en)/:path*', '/((?!_next|_vercel|.*\\..*).*)'],
}
