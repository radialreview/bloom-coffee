import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/useAuth'

function AdminDashboardPage() {
  const navigate = useNavigate()
  const { logout } = useAuth()

  async function handleLogout() {
    await logout()
    navigate('/admin/login')
  }

  return (
    <main className="page-wrapper">
      <section className="auth-card">
        <h1>Admin Area</h1>
        <p className="subtle-text">
          You are authenticated. This protected page represents the Story 1 admin section.
        </p>

        <div className="admin-actions">
          <button type="button" onClick={handleLogout}>
            Log out
          </button>
        </div>
      </section>
    </main>
  )
}

export default AdminDashboardPage
