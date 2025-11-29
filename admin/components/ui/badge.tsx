import * as React from 'react'
import { cn } from '@/lib/utils/cn'

export interface BadgeProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'success' | 'error' | 'warning' | 'info'
  size?: 'sm' | 'md' | 'lg'
}

const Badge = React.forwardRef<HTMLDivElement, BadgeProps>(
  ({ className, variant = 'default', size = 'md', ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn(
          'inline-flex items-center rounded-full font-medium',
          {
            // Variants
            'bg-blue-100 text-blue-800': variant === 'default',
            'bg-green-100 text-green-800': variant === 'success',
            'bg-red-100 text-red-800': variant === 'error',
            'bg-yellow-100 text-yellow-800': variant === 'warning',
            'bg-gray-100 text-gray-800': variant === 'info',
            // Sizes
            'px-2 py-0.5 text-xs': size === 'sm',
            'px-2.5 py-1 text-xs': size === 'md',
            'px-3 py-1.5 text-sm': size === 'lg',
          },
          className
        )}
        {...props}
      />
    )
  }
)
Badge.displayName = 'Badge'

export { Badge }

