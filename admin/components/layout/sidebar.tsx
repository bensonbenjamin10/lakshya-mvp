'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { cn } from '@/lib/utils/cn'
import {
  LayoutDashboard,
  Users,
  BookOpen,
  Video,
  BarChart3,
  LogOut,
  FileText,
  GraduationCap,
  TrendingUp,
  CreditCard,
  UserCircle,
} from 'lucide-react'
import { useLogout } from '@refinedev/core'

const navigation = [
  { name: 'Dashboard', href: '/', icon: LayoutDashboard },
  { name: 'Leads', href: '/leads', icon: Users },
  { name: 'Courses', href: '/courses', icon: BookOpen },
  { name: 'Modules', href: '/modules', icon: FileText },
  { name: 'Enrollments', href: '/enrollments', icon: GraduationCap },
  { name: 'Payments', href: '/payments', icon: CreditCard },
  { name: 'Users', href: '/users', icon: UserCircle },
  { name: 'Progress', href: '/progress', icon: TrendingUp },
  { name: 'Videos', href: '/videos', icon: Video },
  { name: 'Analytics', href: '/analytics', icon: BarChart3 },
]

export function Sidebar() {
  const pathname = usePathname()
  const { mutate: logout } = useLogout()

  return (
    <div className="flex h-full w-64 flex-col bg-gray-900 text-white">
      <div className="flex h-16 items-center border-b border-gray-800 px-6">
        <h1 className="text-xl font-bold">Lakshya Admin</h1>
      </div>
      <nav className="flex-1 space-y-1 px-3 py-4">
        {navigation.map((item) => {
          const isActive = pathname === item.href || pathname.startsWith(item.href + '/')
          return (
            <Link
              key={item.name}
              href={item.href}
              className={cn(
                'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                isActive
                  ? 'bg-blue-600 text-white'
                  : 'text-gray-300 hover:bg-gray-800 hover:text-white'
              )}
            >
              <item.icon className="h-5 w-5" />
              {item.name}
            </Link>
          )
        })}
      </nav>
      <div className="border-t border-gray-800 p-4">
        <button
          onClick={() => logout()}
          className="flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium text-gray-300 transition-colors hover:bg-gray-800 hover:text-white"
        >
          <LogOut className="h-5 w-5" />
          Sign Out
        </button>
      </div>
    </div>
  )
}

