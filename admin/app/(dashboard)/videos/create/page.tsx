'use client'

import { VideoForm } from '@/components/videos/video-form'

export default function CreateVideoPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Create Video</h1>
        <p className="text-gray-600 mt-1">Add a new video promo</p>
      </div>
      <VideoForm />
    </div>
  )
}

