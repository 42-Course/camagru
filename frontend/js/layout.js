// /js/layout.js

import { getCurrentUser, logout } from './auth.js';

export function renderNavbar() {
  const user = getCurrentUser();
  const nav = document.createElement('nav');
  nav.className = 'navbar navbar-expand-lg navbar-light bg-light mb-4';

  nav.innerHTML = `
    <div class="container-fluid">
      <a class="navbar-brand" href="index.html">Camagru</a>
      <div>
        ${user ? `
          <a href="camagru.html" class="btn btn-outline-secondary me-2">
            <i class="bi bi-camera"></i> Camagru
          </a>
          <a href="profile.html" class="btn btn-outline-primary me-2">
            <i class="bi bi-person-circle"></i> Profile
          </a>
          <button class="btn btn-outline-danger" id="logout-btn">
            <i class="bi bi-box-arrow-right"></i> Logout
          </button>
        ` : `
          <a href="login.html" class="btn btn-outline-primary me-2">
            <i class="bi bi-box-arrow-in-right"></i> Login
          </a>
          <a href="register.html" class="btn btn-outline-success">
            <i class="bi bi-person-plus"></i> Sign Up
          </a>
        `}
      </div>
    </div>
  `;

  if (user) {
    setTimeout(() => {
      const btn = nav.querySelector('#logout-btn');
      btn?.addEventListener('click', () => {
        logout();
        location.reload();
      });
    }, 0);
  }

  return nav;
}

export function renderFooter() {
  const footer = document.createElement('footer');
  footer.className = 'text-center py-4 mt-1 border-top text-muted';
  footer.textContent = '© 2025 Camagru by pulgamecanica';
  return footer;
}

export function showLoadingCover() {
  let cover = document.getElementById('loading-cover');
  if (!cover) {
    cover = document.createElement('div');
    cover.id = 'loading-cover';
    cover.innerHTML = `<div class="spinner-border text-primary" role="status"></div>`;
    document.body.appendChild(cover);
  }
  cover.style.display = 'flex';
}

export function hideLoadingCover() {
  const cover = document.getElementById('loading-cover');
  if (cover) cover.style.display = 'none';
}

export async function initLayout(pageCallback) {
  const navbar = renderNavbar();
  const footer = renderFooter();
  const appNav = document.getElementById('app-navbar');
  const appFooter = document.getElementById('app-footer');

  if (appNav) appNav.appendChild(navbar);
  if (appFooter) appFooter.appendChild(footer);

  showLoadingCover();

  try {
    await pageCallback();
  } catch (err) {
    console.error('Page error:', err);
  } finally {
    hideLoadingCover();
  }
}
