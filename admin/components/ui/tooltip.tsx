'use client'

import * as React from 'react'
import { cn } from '@/lib/utils/cn'

export interface TooltipProps {
  children: React.ReactElement
  content: string
  side?: 'top' | 'bottom' | 'left' | 'right'
  delayDuration?: number
}

export function Tooltip({ children, content, side = 'top', delayDuration = 200 }: TooltipProps) {
  const [isVisible, setIsVisible] = React.useState(false)
  const timeoutRef = React.useRef<NodeJS.Timeout | undefined>(undefined)

  const showTooltip = () => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current)
    }
    timeoutRef.current = setTimeout(() => setIsVisible(true), delayDuration)
  }

  const hideTooltip = () => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current)
    }
    setIsVisible(false)
  }

  React.useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current)
      }
    }
  }, [])

  return (
    <div className="relative inline-block" onMouseEnter={showTooltip} onMouseLeave={hideTooltip}>
      {children}
      {isVisible && (
        <div
          className={cn(
            'absolute z-50 rounded-md bg-gray-900 px-2 py-1 text-xs text-white shadow-lg',
            {
              'bottom-full left-1/2 -translate-x-1/2 mb-2': side === 'top',
              'top-full left-1/2 -translate-x-1/2 mt-2': side === 'bottom',
              'right-full top-1/2 -translate-y-1/2 mr-2': side === 'left',
              'left-full top-1/2 -translate-y-1/2 ml-2': side === 'right',
            }
          )}
        >
          {content}
          <div
            className={cn('absolute h-0 w-0 border-4 border-transparent', {
              'top-full left-1/2 -translate-x-1/2 border-t-gray-900': side === 'top',
              'bottom-full left-1/2 -translate-x-1/2 border-b-gray-900': side === 'bottom',
              'left-full top-1/2 -translate-y-1/2 border-l-gray-900': side === 'left',
              'right-full top-1/2 -translate-y-1/2 border-r-gray-900': side === 'right',
            })}
          />
        </div>
      )}
    </div>
  )
}

