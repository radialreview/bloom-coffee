import { useEffect, useMemo, useRef, useState } from 'react'
import { Link } from 'react-router-dom'
import { apiClient } from '../api/client'
import { useOrder } from '../context/useOrder'
import { formatMoney } from '../utils/format'

function CustomerMenuPage() {
  const { addItem, itemCount, total } = useOrder()
  const [drinks, setDrinks] = useState([])
  const [addOns, setAddOns] = useState([])
  const [activeDrinkId, setActiveDrinkId] = useState(null)
  const [selectedAddOnIds, setSelectedAddOnIds] = useState([])
  const [error, setError] = useState('')
  const [isLoading, setIsLoading] = useState(true)
  const customizerRef = useRef(null)

  useEffect(() => {
    let active = true

    Promise.all([apiClient.get('/api/v1/drinks'), apiClient.get('/api/v1/add_ons')])
      .then(([drinksResponse, addOnsResponse]) => {
        if (!active) return
        setDrinks(drinksResponse.data.drinks || [])
        setAddOns(addOnsResponse.data.add_ons || [])
      })
      .catch(() => {
        if (!active) return
        setError('Unable to load the menu right now.')
      })
      .finally(() => {
        if (!active) return
        setIsLoading(false)
      })

    return () => {
      active = false
    }
  }, [])

  const activeDrink = useMemo(
    () => drinks.find((drink) => drink.id === activeDrinkId) || null,
    [drinks, activeDrinkId],
  )

  const selectedAddOns = useMemo(
    () => addOns.filter((addOn) => selectedAddOnIds.includes(addOn.id)),
    [addOns, selectedAddOnIds],
  )

  const activeLineTotal = useMemo(() => {
    if (!activeDrink) return 0
    const addOnTotal = selectedAddOns.reduce((sum, addOn) => sum + Number(addOn.price), 0)
    return Number(activeDrink.base_price) + addOnTotal
  }, [activeDrink, selectedAddOns])

  useEffect(() => {
    if (!activeDrink || !customizerRef.current) return

    customizerRef.current.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }, [activeDrink])

  function openCustomizer(drinkId) {
    setActiveDrinkId(drinkId)
    setSelectedAddOnIds([])
  }

  function toggleAddOn(addOnId) {
    setSelectedAddOnIds((current) =>
      current.includes(addOnId) ? current.filter((id) => id !== addOnId) : [...current, addOnId],
    )
  }

  function addActiveDrinkToOrder() {
    if (!activeDrink) return
    addItem(activeDrink, selectedAddOns)
    setActiveDrinkId(null)
    setSelectedAddOnIds([])
  }

  return (
    <main className="customer-page">
      <header className="customer-header">
        <div>
          <h1>Bloom Coffee</h1>
          <p className="subtle-text">Good coffee, made your way.</p>
        </div>
        <div className="row-actions">
          <Link className="page-footer" to="/admin/login">Log in</Link>
          {itemCount > 0 ? (
            <Link className="inline-link-button" to="/order">
              Review order ({itemCount})
            </Link>
          ) : null}
        </div>
      </header>

      {isLoading ? <p className="subtle-text">Loading menu...</p> : null}
      {error ? <p className="error-text">{error}</p> : null}

      <section className="menu-hero">
        <h2>Let&apos;s make something you&apos;ll love.</h2>
        <p className="subtle-text">Pick a drink, add your extras, and we&apos;ll have it ready for you.</p>
      </section>

      <hr className="menu-divider" />

      <section className="menu-layout">
        <div className="drinks-list">
          <div className="menu-header-row">
            <p className="menu-chip">Our menu</p>
          </div>
          <div className="menu-grid">
            {drinks.map((drink) => (
              <article key={drink.id} className="menu-card">
                <h3>{drink.name}</h3>
                <p className="subtle-text">{drink.description || 'No description.'}</p>
                <div className="customizer-footer">
                  <p className="drink-price">{formatMoney(drink.base_price)}</p>
                  <button type="button" onClick={() => openCustomizer(drink.id)}>
                    Customize
                  </button>
                </div>
              </article>
            ))}
          </div>
        </div>

        {activeDrink ? (
          <section ref={customizerRef} className="customizer-card">
            <h2>{activeDrink.name}</h2>
            <p className="subtle-text">Add extras to your drink.</p>

            {addOns.length > 0 ? (
              <div className="add-ons-grid">
                {addOns.map((addOn) => (
                  <label key={addOn.id} className="add-on-option">
                    <input
                      type="checkbox"
                      checked={selectedAddOnIds.includes(addOn.id)}
                      onChange={() => toggleAddOn(addOn.id)}
                    />
                    <span>
                      {addOn.name} <span className="subtle-text">+{formatMoney(addOn.price)}</span>
                    </span>
                  </label>
                ))}
              </div>
            ) : (
              <p className="subtle-text">No add-ons available right now.</p>
            )}

            <div className="customizer-footer">
              <p>
                <strong>{formatMoney(activeLineTotal)}</strong>
              </p>
              <div className="row-actions">
                <button type="button" className="secondary-button" onClick={() => setActiveDrinkId(null)}>
                  Cancel
                </button>
                <button type="button" onClick={addActiveDrinkToOrder}>
                  Add to order
                </button>
              </div>
            </div>
          </section>
        ) : (
          <section className="customizer-card">
            <h2>Your drink</h2>
            <p className="subtle-text">Tap any drink on the menu to start customizing.</p>
          </section>
        )}
      </section>

      {itemCount > 0 ? (
        <footer className="order-summary-bar">
          <p>
            {itemCount} item{itemCount === 1 ? '' : 's'} &middot; <strong>{formatMoney(total)}</strong>
          </p>
          <Link className="inline-link-button" to="/order">
            Review &amp; checkout
          </Link>
        </footer>
      ) : null}
    </main>
  )
}

export default CustomerMenuPage
