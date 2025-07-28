// /js/gallery.js

import { apiFetch } from './api.js';
import { createImageCard } from './components/imageCard.js';

let page = 1;
let totalPages = null;
let images = [];

export async function loadNextGalleryPage(container, { perPage = 100, sortBy = 'created_at', order = 'desc' } = {}) {
  if (totalPages && page > totalPages) {
    page = 1; // Loop back to beginning
  }

  container.querySelectorAll('.skeleton').forEach(e => e.parentNode.remove());
  
  renderSkeletons(container, 6); // Show while loading
  
  try {
    const res = await apiFetch(`/gallery?page=${page}&per_page=${perPage}&sort_by=${sortBy}&order=${order}`);
    const data = await res.json();
    
    await new Promise(r => setTimeout(r, 500));

    if (!res.ok) throw new Error(data.error || 'Failed to load gallery');

    const batch = data.images || [];
    totalPages = data.total_pages;
    images = [...images, ...batch];


    for (const img of batch) {
      const col = document.createElement('div');
      col.className = 'col-md-4 col-sm-6';
      col.appendChild(createImageCard(img, images));
      container.appendChild(col);
    }
    container.querySelectorAll('.skeleton').forEach(e => e.parentNode.remove()); // Remove when ready

    page++;
  } catch (err) {
    console.error('[Gallery Load Error]', err);
  }
}

export function renderSkeletons(container, count = 6) {
  for (let i = 0; i < count; i++) {
    const col = document.createElement('div');
    col.className = 'col-md-4 col-sm-6';
    const skel = document.createElement('div');
    skel.className = 'skeleton';
    col.appendChild(skel);
    container.appendChild(col);
  }
}

export function resetGalleryState() {
  page = 1;
  totalPages = null;
  images = [];
}