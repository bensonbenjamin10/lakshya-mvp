import { LoadingSkeleton } from './skeleton'
import { Card, CardContent, CardHeader } from './card'

interface CardSkeletonProps {
  showHeader?: boolean
  lines?: number
}

export function CardSkeleton({ showHeader = true, lines = 3 }: CardSkeletonProps) {
  return (
    <Card>
      {showHeader && (
        <CardHeader>
          <LoadingSkeleton height={24} width={200} />
        </CardHeader>
      )}
      <CardContent className="space-y-2">
        {Array.from({ length: lines }).map((_, i) => (
          <LoadingSkeleton
            key={i}
            height={16}
            width={i === lines - 1 ? '60%' : '100%'}
          />
        ))}
      </CardContent>
    </Card>
  )
}

