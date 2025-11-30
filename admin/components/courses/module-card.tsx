'use client'

import { useSortable } from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'
import { Button } from '@/components/ui/button'
import {
  GripVertical,
  Video,
  BookOpen,
  FileText,
  HelpCircle,
  Radio,
  MoreVertical,
  Edit2,
  Copy,
  Trash2,
  Clock,
  Star,
  Eye,
} from 'lucide-react'
import { cn } from '@/lib/utils/cn'
import type { CourseModule } from './types'
import { useState, useRef, useEffect } from 'react'

interface ModuleCardProps {
  module: CourseModule
  onEdit: () => void
  onDelete: () => void
  onDuplicate: () => void
}

const MODULE_ICONS = {
  video: Video,
  reading: BookOpen,
  assignment: FileText,
  quiz: HelpCircle,
  live_session: Radio,
}

const MODULE_COLORS = {
  video: 'bg-blue-100 text-blue-700 border-blue-200',
  reading: 'bg-green-100 text-green-700 border-green-200',
  assignment: 'bg-yellow-100 text-yellow-700 border-yellow-200',
  quiz: 'bg-purple-100 text-purple-700 border-purple-200',
  live_session: 'bg-indigo-100 text-indigo-700 border-indigo-200',
}

export function ModuleCard({ module, onEdit, onDelete, onDuplicate }: ModuleCardProps) {
  const [showMenu, setShowMenu] = useState(false)
  const menuRef = useRef<HTMLDivElement>(null)

  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: module.id })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  }

  // Close menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setShowMenu(false)
      }
    }

    if (showMenu) {
      document.addEventListener('mousedown', handleClickOutside)
    }
    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [showMenu])

  const Icon = MODULE_ICONS[module.type] || FileText
  const colorClass = MODULE_COLORS[module.type] || 'bg-gray-100 text-gray-700 border-gray-200'

  const handleDeleteClick = () => {
    if (confirm(`Delete module "${module.title}"?`)) {
      onDelete()
    }
    setShowMenu(false)
  }

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={cn(
        'group flex items-center gap-2 p-2 bg-white rounded-md border border-gray-200 hover:border-gray-300 hover:shadow-sm transition-all',
        isDragging && 'opacity-50 shadow-lg ring-2 ring-blue-500'
      )}
    >
      {/* Drag Handle */}
      <button
        {...attributes}
        {...listeners}
        className="cursor-grab active:cursor-grabbing p-1 hover:bg-gray-100 rounded opacity-0 group-hover:opacity-100 transition-opacity"
      >
        <GripVertical className="h-3 w-3 text-gray-400" />
      </button>

      {/* Module Type Icon */}
      <div
        className={cn(
          'flex items-center justify-center w-7 h-7 rounded-md border',
          colorClass
        )}
      >
        <Icon className="h-4 w-4" />
      </div>

      {/* Module Info */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className="text-sm font-medium text-gray-900 truncate">
            {module.title}
          </span>
          {module.is_required && (
            <Star className="h-3 w-3 text-yellow-500 fill-yellow-500 flex-shrink-0" />
          )}
          {module.is_free_preview && (
            <span className="flex items-center gap-0.5 text-xs text-green-600 bg-green-50 px-1.5 py-0.5 rounded flex-shrink-0">
              <Eye className="h-3 w-3" />
              Free
            </span>
          )}
        </div>
        <div className="flex items-center gap-2 text-xs text-gray-500">
          <span className="capitalize">{module.type.replace('_', ' ')}</span>
          {module.duration_minutes && (
            <>
              <span>•</span>
              <span className="flex items-center gap-0.5">
                <Clock className="h-3 w-3" />
                {module.duration_minutes} min
              </span>
            </>
          )}
        </div>
      </div>

      {/* Actions Menu */}
      <div className="relative" ref={menuRef}>
        <Button
          variant="ghost"
          size="sm"
          onClick={() => setShowMenu(!showMenu)}
          className="h-7 w-7 p-0 opacity-0 group-hover:opacity-100 transition-opacity"
        >
          <MoreVertical className="h-4 w-4 text-gray-500" />
        </Button>

        {showMenu && (
          <div className="absolute right-0 top-full mt-1 w-36 bg-white rounded-md shadow-lg border border-gray-200 py-1 z-10">
            <button
              onClick={() => {
                onEdit()
                setShowMenu(false)
              }}
              className="w-full flex items-center gap-2 px-3 py-1.5 text-sm text-gray-700 hover:bg-gray-100"
            >
              <Edit2 className="h-3 w-3" />
              Edit
            </button>
            <button
              onClick={() => {
                onDuplicate()
                setShowMenu(false)
              }}
              className="w-full flex items-center gap-2 px-3 py-1.5 text-sm text-gray-700 hover:bg-gray-100"
            >
              <Copy className="h-3 w-3" />
              Duplicate
            </button>
            <hr className="my-1" />
            <button
              onClick={handleDeleteClick}
              className="w-full flex items-center gap-2 px-3 py-1.5 text-sm text-red-600 hover:bg-red-50"
            >
              <Trash2 className="h-3 w-3" />
              Delete
            </button>
          </div>
        )}
      </div>
    </div>
  )
}

