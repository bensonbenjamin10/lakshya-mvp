'use client'

import { useList } from '@refinedev/core'
import Link from 'next/link'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { createClient } from '@/lib/supabase/client'
import { useEffect, useState, useMemo } from 'react'
import { TableSkeleton } from '@/components/ui/table-skeleton'
import { EmptyState } from '@/components/ui/empty-state'
import { SearchInput } from '@/components/ui/search-input'
import { Badge } from '@/components/ui/badge'
import { Download, ArrowUpDown, ArrowUp, ArrowDown, UserCheck, UserX } from 'lucide-react'
import { useToast } from '@/lib/hooks/use-toast'
import { Database } from '@/lib/types/database.types'

type Profile = Database['public']['Tables']['profiles']['Row']
type SortField = 'full_name' | 'email' | 'role' | 'created_at' | null
type SortOrder = 'asc' | 'desc'

export function UsersTable() {
  const toast = useToast()
  const [searchQuery, setSearchQuery] = useState('')
  const [sortField, setSortField] = useState<SortField>('created_at')
  const [sortOrder, setSortOrder] = useState<SortOrder>('desc')
  const [roleFilter, setRoleFilter] = useState<string>('all')
  const supabase = createClient()

  const listResult = useList({
    resource: 'profiles',
    pagination: {
      mode: 'off',
    },
  })

  const profiles = (listResult.result?.data as Profile[]) || []
  const isLoading = listResult.query?.isLoading || false

  const filteredAndSortedProfiles = useMemo(() => {
    let filtered = profiles

    // Search filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      filtered = filtered.filter((profile) => {
        const name = profile.full_name?.toLowerCase() || ''
        const email = profile.email?.toLowerCase() || ''
        const phone = profile.phone?.toLowerCase() || ''
        return name.includes(query) || email.includes(query) || phone.includes(query)
      })
    }

    // Role filter
    if (roleFilter !== 'all') {
      filtered = filtered.filter((profile) => profile.role === roleFilter)
    }

    // Sort
    if (sortField) {
      filtered = [...filtered].sort((a, b) => {
        let aValue: any = a[sortField as keyof Profile]
        let bValue: any = b[sortField as keyof Profile]

        if (sortField === 'created_at') {
          aValue = new Date(aValue || 0).getTime()
          bValue = new Date(bValue || 0).getTime()
        } else {
          aValue = String(aValue || '').toLowerCase()
          bValue = String(bValue || '').toLowerCase()
        }

        if (sortOrder === 'asc') {
          return aValue > bValue ? 1 : -1
        } else {
          return aValue < bValue ? 1 : -1
        }
      })
    }

    return filtered
  }, [profiles, searchQuery, roleFilter, sortField, sortOrder])

  const handleSort = (field: SortField) => {
    if (sortField === field) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')
    } else {
      setSortField(field)
      setSortOrder('desc')
    }
  }

  const SortIcon = ({ field }: { field: SortField }) => {
    if (sortField !== field) return <ArrowUpDown className="ml-1 h-3 w-3 opacity-50" />
    return sortOrder === 'asc' ? (
      <ArrowUp className="ml-1 h-3 w-3" />
    ) : (
      <ArrowDown className="ml-1 h-3 w-3" />
    )
  }

  const getRoleColor = (role: string) => {
    switch (role) {
      case 'admin':
        return 'bg-red-100 text-red-800'
      case 'faculty':
        return 'bg-blue-100 text-blue-800'
      case 'student':
        return 'bg-green-100 text-green-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const handleExport = async (format: 'csv' | 'excel') => {
    try {
      const exportData = filteredAndSortedProfiles.map((profile) => ({
        'Name': profile.full_name || 'N/A',
        'Email': profile.email,
        'Phone': profile.phone || 'N/A',
        'Role': profile.role,
        'Country': profile.country || 'N/A',
        'Created At': profile.created_at ? new Date(profile.created_at).toLocaleString() : 'N/A',
      }))

      if (format === 'csv') {
        const { exportToCSV } = await import('@/lib/utils/export')
        exportToCSV(exportData, 'users')
        toast.success('Users exported to CSV')
      } else {
        const { exportToExcel } = await import('@/lib/utils/export')
        await exportToExcel(exportData, 'users')
        toast.success('Users exported to Excel')
      }
    } catch (error) {
      toast.error('Failed to export users')
    }
  }

  const roleCounts = useMemo(() => {
    return {
      all: profiles.length,
      admin: profiles.filter((p) => p.role === 'admin').length,
      faculty: profiles.filter((p) => p.role === 'faculty').length,
      student: profiles.filter((p) => p.role === 'student').length,
    }
  }, [profiles])

  if (isLoading) {
    return <TableSkeleton />
  }

  return (
    <div className="space-y-4">
      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="pt-6">
            <div className="text-sm font-medium text-gray-600">Total Users</div>
            <div className="text-2xl font-bold">{roleCounts.all}</div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-sm font-medium text-gray-600">Admins</div>
            <div className="text-2xl font-bold text-red-600">{roleCounts.admin}</div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-sm font-medium text-gray-600">Faculty</div>
            <div className="text-2xl font-bold text-blue-600">{roleCounts.faculty}</div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-sm font-medium text-gray-600">Students</div>
            <div className="text-2xl font-bold text-green-600">{roleCounts.student}</div>
          </CardContent>
        </Card>
      </div>

      {/* Filters and Search */}
      <Card>
        <CardContent className="pt-6">
          <div className="flex flex-col md:flex-row gap-4 mb-4">
            <div className="flex-1">
              <SearchInput
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search by name, email, phone..."
              />
            </div>
            <div className="flex gap-2">
              <select
                value={roleFilter}
                onChange={(e) => setRoleFilter(e.target.value)}
                className="rounded-md border border-gray-300 px-3 py-2 text-sm"
              >
                <option value="all">All Roles</option>
                <option value="admin">Admin</option>
                <option value="faculty">Faculty</option>
                <option value="student">Student</option>
              </select>
              <div className="flex gap-2">
                <Button variant="outline" size="sm" onClick={() => handleExport('csv')}>
                  <Download className="h-4 w-4 mr-1" />
                  CSV
                </Button>
                <Button variant="outline" size="sm" onClick={() => handleExport('excel')}>
                  <Download className="h-4 w-4 mr-1" />
                  Excel
                </Button>
              </div>
            </div>
          </div>

          {filteredAndSortedProfiles.length === 0 ? (
            <EmptyState
              title="No users found"
              description="No users match your search criteria"
            />
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th
                      className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                      onClick={() => handleSort('full_name')}
                    >
                      Name
                      <SortIcon field="full_name" />
                    </th>
                    <th
                      className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                      onClick={() => handleSort('email')}
                    >
                      Email
                      <SortIcon field="email" />
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Phone
                    </th>
                    <th
                      className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                      onClick={() => handleSort('role')}
                    >
                      Role
                      <SortIcon field="role" />
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Country
                    </th>
                    <th
                      className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                      onClick={() => handleSort('created_at')}
                    >
                      Created
                      <SortIcon field="created_at" />
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredAndSortedProfiles.map((profile) => (
                    <tr key={profile.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          {profile.avatar_url ? (
                            <img
                              className="h-10 w-10 rounded-full mr-3"
                              src={profile.avatar_url}
                              alt={profile.full_name || 'User'}
                            />
                          ) : (
                            <div className="h-10 w-10 rounded-full bg-gray-300 mr-3 flex items-center justify-center">
                              <span className="text-gray-600 font-medium">
                                {(profile.full_name || profile.email || 'U')[0].toUpperCase()}
                              </span>
                            </div>
                          )}
                          <div>
                            <div className="text-sm font-medium text-gray-900">
                              {profile.full_name || 'No name'}
                            </div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {profile.email}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {profile.phone || 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <Badge className={getRoleColor(profile.role)}>
                          {profile.role.toUpperCase()}
                        </Badge>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {profile.country || 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {profile.created_at
                          ? new Date(profile.created_at).toLocaleDateString()
                          : 'N/A'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <Link href={`/users/${profile.id}`}>
                          <Button variant="outline" size="sm">
                            View
                          </Button>
                        </Link>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}

