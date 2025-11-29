'use client'

import { Refine } from '@refinedev/core'
import { dataProvider, liveProvider } from '@refinedev/supabase'
import routerProvider from '@refinedev/nextjs-router/app'
import { createClient } from '@/lib/supabase/client'
import { authProvider } from './auth-provider'

export function RefineProvider({ children }: { children: React.ReactNode }) {
  const supabaseClient = createClient()

  return (
    <Refine
      routerProvider={routerProvider}
      dataProvider={dataProvider(supabaseClient)}
      liveProvider={liveProvider(supabaseClient)}
      authProvider={authProvider}
      resources={[
        {
          name: 'leads',
          list: '/leads',
          show: '/leads/:id',
          meta: {
            label: 'Leads',
          },
        },
        {
          name: 'courses',
          list: '/courses',
          create: '/courses/create',
          edit: '/courses/:id',
          meta: {
            label: 'Courses',
          },
        },
        {
          name: 'video_promos',
          list: '/videos',
          create: '/videos/create',
          edit: '/videos/:id',
          meta: {
            label: 'Videos',
          },
        },
        {
          name: 'analytics',
          list: '/analytics',
          meta: {
            label: 'Analytics',
          },
        },
      ]}
      options={{
        syncWithLocation: true,
        warnWhenUnsavedChanges: true,
        useNewQueryKeys: true,
        projectId: 'lakshya-admin',
      }}
    >
      {children}
    </Refine>
  )
}

