import axios from 'axios'

const TOKEN_KEY = 'bloom_admin_token'
const baseURL = import.meta.env.VITE_API_URL || 'http://localhost:4567'

export const apiClient = axios.create({
  baseURL,
  headers: {
    'Content-Type': 'application/json',
  },
})

export function setAuthToken(token) {
  if (token) {
    apiClient.defaults.headers.common.Authorization = `Bearer ${token}`
  } else {
    delete apiClient.defaults.headers.common.Authorization
  }
}

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401 && apiClient.defaults.headers.common.Authorization) {
      localStorage.removeItem(TOKEN_KEY)
      setAuthToken(null)
      window.location.href = '/admin/login'
    }
    return Promise.reject(error)
  },
)
