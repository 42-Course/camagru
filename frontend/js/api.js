import { getToken } from './auth.js';

const API_BASE = 'http://localhost:9292';

export function getApiBase() {
  return API_BASE
}

export async function apiFetch(path, options = {}) {
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  const token = getToken();
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const url = `${getApiBase()}${path}`;
  return fetch(url, { ...options, headers });
}
