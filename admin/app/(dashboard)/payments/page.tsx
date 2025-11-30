import { createClient } from '@/lib/supabase/server'
import { PaymentsTable } from '@/components/payments/payments-table'
import { PaymentAnalytics } from '@/components/payments/payment-analytics'

export default async function PaymentsPage() {
  const supabase = await createClient()

  const [paymentsData, coursesData] = await Promise.all([
    supabase.from('payments').select('*').order('created_at', { ascending: false }),
    supabase.from('courses').select('*'),
  ])

  const payments = paymentsData.data || []
  const courses = coursesData.data || []

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Payments</h1>
        <p className="text-gray-600 mt-1">Manage and track all payment transactions</p>
      </div>

      <PaymentAnalytics payments={payments} courses={courses} />

      <PaymentsTable />
    </div>
  )
}

