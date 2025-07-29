import { apiFetch } from '../api.js';

export async function loadStickers() {
  const list = document.getElementById('sticker-list');
  list.innerHTML = '<div class="text-muted">Loading stickers...</div>';

  try {
    const res = await apiFetch('/stickers');
    if (!res.ok) throw new Error('Failed to fetch sticker list');

    const stickers = await res.json();
    renderStickerTray(stickers);
  } catch (err) {
    console.error('[StickerTray] Error loading stickers:', err);
    list.innerHTML = '<p class="text-danger">Failed to load stickers.</p>';
  }
}

function renderStickerTray(stickers) {
  const list = document.getElementById('sticker-list');
  list.innerHTML = '';

  for (const sticker of stickers) {
    const img = document.createElement('img');
    img.src = sticker.file_path;
    img.alt = sticker.name;
    img.title = sticker.name;
    img.className = 'sticker-thumb border rounded';
    img.style.width = '60px';
    img.style.height = '60px';
    img.style.cursor = 'grab';
    img.draggable = true;

    img.dataset.stickerId = sticker.id;

    list.appendChild(img);
  }
}
