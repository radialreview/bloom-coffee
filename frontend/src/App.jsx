import { Navigate, Route, Routes } from 'react-router-dom'
import './App.css'
import { useAuth } from './context/useAuth'
import AdminDrinksPage from './pages/AdminDrinksPage'
import AdminLoginPage from './pages/AdminLoginPage'
import ProtectedRoute from './components/ProtectedRoute'

function AdminLandingRedirect() {
  const { isAuthenticated } = useAuth()
  return <Navigate to={isAuthenticated ? '/admin/drinks' : '/admin/login'} replace />
}

function App() {
  return (
    <Routes>
      <Route path="/" element={<AdminLandingRedirect />} />
      <Route path="/admin/login" element={<AdminLoginPage />} />
      <Route
        path="/admin/dashboard"
        element={<Navigate to="/admin/drinks" replace />}
      />
      <Route
        path="/admin/drinks"
        element={
          <ProtectedRoute>
            <AdminDrinksPage />
          </ProtectedRoute>
        }
      />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}

export default App
