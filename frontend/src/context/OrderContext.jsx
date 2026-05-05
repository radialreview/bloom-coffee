import { useCallback, useMemo, useState } from 'react'
import { OrderContext } from './order-context'

function makeItemId() {
  return `${Date.now()}-${Math.random().toString(16).slice(2)}`
}

function roundMoney(value) {
  return Number(value.toFixed(2))
}

function computeLineTotal(item) {
  const addOnTotal = item.addOns.reduce((sum, addOn) => sum + Number(addOn.price), 0)
  return roundMoney((Number(item.drink.base_price) + addOnTotal) * item.quantity)
}

export function OrderProvider({ children }) {
  const [items, setItems] = useState([])

  const addItem = useCallback((drink, selectedAddOns) => {
    setItems((current) => [
      ...current,
      {
        id: makeItemId(),
        drink,
        addOns: selectedAddOns,
        quantity: 1,
      },
    ])
  }, [])

  const removeItem = useCallback((itemId) => {
    setItems((current) => current.filter((item) => item.id !== itemId))
  }, [])

  const updateQuantity = useCallback((itemId, quantity) => {
    if (quantity <= 0) {
      setItems((current) => current.filter((item) => item.id !== itemId))
      return
    }

    setItems((current) =>
      current.map((item) => (item.id === itemId ? { ...item, quantity } : item)),
    )
  }, [])

  const clearOrder = useCallback(() => {
    setItems([])
  }, [])

  const itemsWithTotals = useMemo(
    () => items.map((item) => ({ ...item, lineTotal: computeLineTotal(item) })),
    [items],
  )

  const total = useMemo(
    () => roundMoney(itemsWithTotals.reduce((sum, item) => sum + item.lineTotal, 0)),
    [itemsWithTotals],
  )

  const itemCount = useMemo(
    () => itemsWithTotals.reduce((count, item) => count + item.quantity, 0),
    [itemsWithTotals],
  )

  const value = useMemo(
    () => ({ items: itemsWithTotals, total, itemCount, addItem, updateQuantity, removeItem, clearOrder }),
    [itemsWithTotals, total, itemCount, addItem, updateQuantity, removeItem, clearOrder],
  )

  return <OrderContext.Provider value={value}>{children}</OrderContext.Provider>
}
