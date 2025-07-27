// /frontend/js/auth.js

const AUTH_KEY = 'camagru_auth_token';
const USER_KEY = 'camagru_user';

export function saveAuth(token, user) {
  localStorage.setItem(AUTH_KEY, token);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function getToken() {
  return localStorage.getItem(AUTH_KEY);
}

export function getCurrentUser() {
  const data = localStorage.getItem(USER_KEY);
  return data ? JSON.parse(data) : null;
}

export function isLoggedIn() {
  return !!getToken();
}

export function logout() {
  localStorage.removeItem(AUTH_KEY);
  localStorage.removeItem(USER_KEY);
  location.href = '/login.html';
}

export function authHeaders() {
  const token = getToken();
  return token ? { 'Authorization': `Bearer ${token}` } : {};
}

export function redirectIfLoggedIn(redirectTo = '/profile.html') {
  if (isLoggedIn()) {
    window.location.href = redirectTo;
  }
}
