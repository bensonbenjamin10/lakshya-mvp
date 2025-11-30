import { AuthProvider } from '@refinedev/core'
import { createClient } from '@/lib/supabase/client'
import { Database } from '@/lib/types/database.types'

type Profile = Database['public']['Tables']['profiles']['Row']

export const authProvider: AuthProvider = {
  login: async ({ email, password }) => {
    const supabase = createClient()
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      return {
        success: false,
        error: {
          message: error.message,
          name: 'LoginError',
        },
      }
    }

    // Wait for session to be fully established
    await new Promise(resolve => setTimeout(resolve, 100))

    // Check if user has admin role
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', data.user.id)
      .single()

    const profileData = profile as Profile | null

    if (profileData?.role !== 'admin' && profileData?.role !== 'faculty') {
      await supabase.auth.signOut()
      return {
        success: false,
        error: {
          message: 'Access denied. Admin role required.',
          name: 'AccessDenied',
        },
      }
    }

    // Verify session is still valid after role check
    const { data: sessionData } = await supabase.auth.getSession()
    if (!sessionData?.session) {
      return {
        success: false,
        error: {
          message: 'Session not established. Please try again.',
          name: 'SessionError',
        },
      }
    }

    return {
      success: true,
      redirectTo: '/',
    }
  },
  logout: async () => {
    const supabase = createClient()
    const { error } = await supabase.auth.signOut()

    if (error) {
      return {
        success: false,
        error,
      }
    }

    return {
      success: true,
      redirectTo: '/login',
    }
  },
  check: async () => {
    const supabase = createClient()
    const { data } = await supabase.auth.getSession()

    if (!data?.session) {
      return {
        authenticated: false,
        redirectTo: '/login',
        logout: true,
      }
    }

    // Verify admin role
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', data.session.user.id)
      .single()

    const profileData = profile as Profile | null

    if (profileData?.role !== 'admin' && profileData?.role !== 'faculty') {
      return {
        authenticated: false,
        redirectTo: '/login',
        logout: true,
      }
    }

    return {
      authenticated: true,
    }
  },
  getIdentity: async () => {
    const supabase = createClient()
    const { data } = await supabase.auth.getUser()

    if (data?.user) {
      const { data: profile } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', data.user.id)
        .single()

      const profileData = profile as Profile | null

      return {
        id: data.user.id,
        name: profileData?.full_name || data.user.email || '',
        email: data.user.email || '',
        avatar: profileData?.avatar_url,
      }
    }

    return null
  },
  onError: async (error) => {
    console.error(error)
    return {
      logout: true,
    }
  },
}

