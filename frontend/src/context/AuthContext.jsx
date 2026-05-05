import { useCallback, useEffect, useMemo, useState } from 'react'
import { apiClient, setAuthToken } from '../api/client'
import { AuthContext } from './auth-context'

const TOKEN_KEY = 'bloom_admin_token'

export function AuthProvider({ children }) {
  const [token, setToken] = useState(() => localStorage.getItem(TOKEN_KEY))
  const [isCheckingSession, setIsCheckingSession] = useState(true)

  useEffect(() => {
    let active = true

    if (!token) {
      setAuthToken(null)
      setIsCheckingSession(false)
      return
    }

    setAuthToken(token)

    apiClient
      .get('/api/v1/admin/session')
      .then(() => {
        if (active) setIsCheckingSession(false)
      })
      .catch(() => {
        if (!active) return
        localStorage.removeItem(TOKEN_KEY)
        setToken(null)
        setAuthToken(null)
        setIsCheckingSession(false)
      })

    return () => {
      active = false
    }
  }, [token])

  const login = useCallback(async (email, password) => {
    const { data } = await apiClient.post('/api/v1/admin/login', { email, password })
    const nextToken = data.token
    localStorage.setItem(TOKEN_KEY, nextToken)
    setToken(nextToken)
    setAuthToken(nextToken)
  }, [])

  const logout = useCallback(async () => {
    try {
      await apiClient.post('/api/v1/admin/logout')
    } catch {
      // Logout must still clear local session even if API call fails.
    } finally {
      localStorage.removeItem(TOKEN_KEY)
      setToken(null)
      setAuthToken(null)
    }
  }, [])

  const value = useMemo(
    () => ({
      token,
      isAuthenticated: Boolean(token),
      isCheckingSession,
      login,
      logout,
    }),
    [token, isCheckingSession, login, logout],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}
