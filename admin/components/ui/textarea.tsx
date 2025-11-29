import * as React from 'react'
import { useState } from 'react'
import { cn } from '@/lib/utils/cn'

export interface TextareaProps extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {
  error?: boolean
  helperText?: string
  maxLength?: number
  showCharCount?: boolean
}

const Textarea = React.forwardRef<HTMLTextAreaElement, TextareaProps>(
  ({ className, error, helperText, maxLength, showCharCount, ...props }, ref) => {
    const [charCount, setCharCount] = useState(props.value?.toString().length || 0)

    return (
      <div className="w-full">
        <textarea
          className={cn(
            'flex min-h-[80px] w-full rounded-md border px-3 py-2 text-sm',
            'placeholder:text-gray-400',
            'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2',
            'disabled:cursor-not-allowed disabled:opacity-50',
            error
              ? 'border-red-300 focus-visible:ring-red-500'
              : 'border-gray-300 focus-visible:ring-blue-500',
            className
          )}
          ref={ref}
          maxLength={maxLength}
          onChange={(e) => {
            setCharCount(e.target.value.length)
            props.onChange?.(e)
          }}
          {...props}
        />
        <div className="mt-1 flex items-center justify-between">
          {helperText && (
            <p className={cn('text-xs', error ? 'text-red-600' : 'text-gray-500')}>
              {helperText}
            </p>
          )}
          {showCharCount && maxLength && (
            <p
              className={cn(
                'ml-auto text-xs',
                charCount >= maxLength ? 'text-red-600' : 'text-gray-500'
              )}
            >
              {charCount}/{maxLength}
            </p>
          )}
        </div>
      </div>
    )
  }
)
Textarea.displayName = 'Textarea'

export { Textarea }

