import { useState } from 'react'
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

  function addItem(drink, selectedAddOns) {
    setItems((current) => [
      ...current,
      {
        id: makeItemId(),
        drink,
        addOns: selectedAddOns,
        quantity: 1,
      },
    ])
  }

  function updateQuantity(itemId, quantity) {
    if (quantity <= 0) {
      removeItem(itemId)
      return
    }

    setItems((current) =>
      current.map((item) => (item.id === itemId ? { ...item, quantity } : item)),
    )
  }

  function removeItem(itemId) {
    setItems((current) => current.filter((item) => item.id !== itemId))
  }

  function clearOrder() {
    setItems([])
  }

  const itemsWithTotals = items.map((item) => ({
    ...item,
    lineTotal: computeLineTotal(item),
  }))
  const total = roundMoney(itemsWithTotals.reduce((sum, item) => sum + item.lineTotal, 0))
  const itemCount = itemsWithTotals.reduce((count, item) => count + item.quantity, 0)

  const value = {
    items: itemsWithTotals,
    total,
    itemCount,
    addItem,
    updateQuantity,
    removeItem,
    clearOrder,
  }

  return <OrderContext.Provider value={value}>{children}</OrderContext.Provider>
}
