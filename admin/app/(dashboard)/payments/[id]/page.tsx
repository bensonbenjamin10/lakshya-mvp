import { PaymentDetail } from '@/components/payments/payment-detail'

export default function PaymentDetailPage({ params }: { params: { id: string } }) {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Payment Details</h1>
        <p className="text-gray-600 mt-1">View and manage payment information</p>
      </div>

      <PaymentDetail paymentId={params.id} />
    </div>
  )
}


