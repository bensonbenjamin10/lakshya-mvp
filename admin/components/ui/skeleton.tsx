import Skeleton from 'react-loading-skeleton'
import 'react-loading-skeleton/dist/skeleton.css'
import { cn } from '@/lib/utils/cn'

interface SkeletonProps {
  className?: string
  count?: number
  height?: number | string
  width?: number | string
  circle?: boolean
  borderRadius?: number | string
}

export function LoadingSkeleton({
  className,
  count = 1,
  height,
  width,
  circle = false,
  borderRadius,
  ...props
}: SkeletonProps) {
  return (
    <Skeleton
      baseColor="#f3f4f6"
      highlightColor="#e5e7eb"
      count={count}
      height={height}
      width={width}
      circle={circle}
      borderRadius={borderRadius}
      className={cn('', className)}
      {...props}
    />
  )
}

