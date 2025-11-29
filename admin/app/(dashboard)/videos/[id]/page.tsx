'use client'

import { VideoForm } from '@/components/videos/video-form'
import { useParams } from 'next/navigation'

export const dynamic = 'force-dynamic'

export default function EditVideoPage() {
  const params = useParams()
  const videoId = params.id as string

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Edit Video</h1>
        <p className="text-gray-600 mt-1">Update video information</p>
      </div>
      <VideoForm videoId={videoId} />
    </div>
  )
}

