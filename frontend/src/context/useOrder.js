import { useContext } from 'react'
import { OrderContext } from './order-context'

export function useOrder() {
  const value = useContext(OrderContext)
  if (!value) {
    throw new Error('useOrder must be used inside an OrderProvider')
  }

  return value
}
