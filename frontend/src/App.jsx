import { Navigate, Route, Routes } from 'react-router-dom'
import './App.css'
import { useAuth } from './context/useAuth'
import AdminAddOnsPage from './pages/AdminAddOnsPage'
import AdminDrinksPage from './pages/AdminDrinksPage'
import AdminLoginPage from './pages/AdminLoginPage'
import CustomerMenuPage from './pages/CustomerMenuPage'
import CustomerOrderPage from './pages/CustomerOrderPage'
import OrderConfirmationPage from './pages/OrderConfirmationPage'
import ProtectedRoute from './components/ProtectedRoute'

function AdminLandingRedirect() {
  const { isAuthenticated } = useAuth()
  return <Navigate to={isAuthenticated ? '/admin/drinks' : '/admin/login'} replace />
}

function App() {
  return (
    <Routes>
      <Route path="/" element={<Navigate to="/menu" replace />} />
      <Route path="/menu" element={<CustomerMenuPage />} />
      <Route path="/order" element={<CustomerOrderPage />} />
      <Route path="/order/confirmation/:id" element={<OrderConfirmationPage />} />
      <Route path="/admin" element={<AdminLandingRedirect />} />
      <Route path="/admin/login" element={<AdminLoginPage />} />
      <Route
        path="/admin/drinks"
        element={
          <ProtectedRoute>
            <AdminDrinksPage />
          </ProtectedRoute>
        }
      />
      <Route
        path="/admin/add-ons"
        element={
          <ProtectedRoute>
            <AdminAddOnsPage />
          </ProtectedRoute>
        }
      />
      <Route path="*" element={<Navigate to="/menu" replace />} />
    </Routes>
  )
}

export default App
