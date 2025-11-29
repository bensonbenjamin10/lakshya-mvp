'use client'

import { useShow } from '@refinedev/core'
import { useParams } from 'next/navigation'
import { format } from 'date-fns'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'

export default function LeadDetailPage() {
  const params = useParams()
  const { data, isLoading } = useShow({
    resource: 'leads',
    id: params.id as string,
  })

  const lead = data?.data

  if (isLoading) {
    return <div className="p-4">Loading...</div>
  }

  if (!lead) {
    return <div className="p-4">Lead not found</div>
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link href="/leads">
          <Button variant="ghost" size="sm">
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Leads
          </Button>
        </Link>
        <div>
          <h1 className="text-3xl font-bold">{lead.name}</h1>
          <p className="text-gray-600 mt-1">Lead Details</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Contact Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <label className="text-sm font-medium text-gray-500">Email</label>
              <p className="text-sm">{lead.email}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Phone</label>
              <p className="text-sm">{lead.phone}</p>
            </div>
            {lead.country && (
              <div>
                <label className="text-sm font-medium text-gray-500">Country</label>
                <p className="text-sm">{lead.country}</p>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Lead Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <label className="text-sm font-medium text-gray-500">Status</label>
              <p className="text-sm">
                <span
                  className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                    lead.status === 'new'
                      ? 'bg-blue-100 text-blue-800'
                      : lead.status === 'converted'
                      ? 'bg-green-100 text-green-800'
                      : lead.status === 'lost'
                      ? 'bg-red-100 text-red-800'
                      : 'bg-gray-100 text-gray-800'
                  }`}
                >
                  {lead.status}
                </span>
              </p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Source</label>
              <p className="text-sm">{lead.source.replace('_', ' ')}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Inquiry Type</label>
              <p className="text-sm">{lead.inquiry_type.replace('_', ' ')}</p>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-500">Created</label>
              <p className="text-sm">{format(new Date(lead.created_at), 'PPpp')}</p>
            </div>
          </CardContent>
        </Card>

        {lead.message && (
          <Card className="md:col-span-2">
            <CardHeader>
              <CardTitle>Message</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm whitespace-pre-wrap">{lead.message}</p>
            </CardContent>
          </Card>
        )}

        {lead.notes && (
          <Card className="md:col-span-2">
            <CardHeader>
              <CardTitle>Notes</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm whitespace-pre-wrap">{lead.notes}</p>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  )
}

