import { UsersTable } from '@/components/users/users-table'

export default function UsersPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Users</h1>
        <p className="text-gray-600 mt-1">Manage users, roles, and permissions</p>
      </div>

      <UsersTable />
    </div>
  )
}

