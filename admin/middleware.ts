import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  // Create response with proper headers for Firebase Hosting proxy
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  })

  // Get the host from headers (Firebase Hosting or Cloud Run)
  const host = request.headers.get('host') || request.headers.get('x-forwarded-host') || ''
  const protocol = request.headers.get('x-forwarded-proto') || 'https'
  const isFirebaseHosting = host.includes('web.app') || host.includes('firebaseapp.com')

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) => {
            request.cookies.set(name, value)
            
            // Set cookies with proper attributes for Firebase Hosting proxy
            const cookieOptions: any = {
              name,
              value,
              ...options,
              sameSite: 'lax' as const,
              secure: true, // Always secure in production
              path: '/',
              httpOnly: options?.httpOnly ?? false,
            }

            // When behind Firebase Hosting proxy, ensure cookies work correctly
            if (isFirebaseHosting) {
              // Don't set domain - let browser handle it
              // This ensures cookies work across the proxy
            }

            response.cookies.set(cookieOptions)
          })
        },
      },
    }
  )

  // Refresh session if expired - required for Supabase SSR
  // This ensures cookies are properly synced between client and server
  await supabase.auth.getSession()

  // Add CORS headers if needed
  if (isFirebaseHosting) {
    response.headers.set('Access-Control-Allow-Credentials', 'true')
    response.headers.set('Access-Control-Allow-Origin', `https://${host}`)
  }

  return response
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}

