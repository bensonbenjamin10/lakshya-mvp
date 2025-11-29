import { AuthProvider } from '@refinedev/core'
import { createClient } from '@/lib/supabase/client'

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

    // Check if user has admin role
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', data.user.id)
      .single()

    if (profile?.role !== 'admin' && profile?.role !== 'faculty') {
      await supabase.auth.signOut()
      return {
        success: false,
        error: {
          message: 'Access denied. Admin role required.',
          name: 'AccessDenied',
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

    if (profile?.role !== 'admin' && profile?.role !== 'faculty') {
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

      return {
        id: data.user.id,
        name: profile?.full_name || data.user.email || '',
        email: data.user.email || '',
        avatar: profile?.avatar_url,
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

