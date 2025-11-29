'use client'

import { useNavigation } from '@refinedev/core'
import { VideosTable } from '@/components/videos/videos-table'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'

export default function VideosPage() {
  const { push } = useNavigation()

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Videos</h1>
          <p className="text-gray-600 mt-1">Manage video promos</p>
        </div>
        <Button onClick={() => push('/videos/create')}>
          <Plus className="h-4 w-4 mr-2" />
          Add Video
        </Button>
      </div>

      <VideosTable />
    </div>
  )
}

