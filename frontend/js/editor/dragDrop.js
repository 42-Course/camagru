import { stickersState } from './state.js';
import { selectSticker } from './transformControls.js';
import { clamp } from '../utils.js';

export function enableStickerDragAndDrop() {
  const preview = document.getElementById('preview-container');
  const content = document.getElementById('preview-stickers');

  // Allow drop
  preview.addEventListener('dragover', (e) => {
    e.preventDefault();
  });

  // Handle drop
  preview.addEventListener('drop', (e) => {
    e.preventDefault();

    const stickerId = e.dataTransfer.getData('sticker-id');
    if (!stickerId) return;

    const src = e.dataTransfer.getData('sticker-src');
    if (!src) return;

    const previewRect = content.getBoundingClientRect();
    const x = e.clientX - previewRect.left;
    const y = e.clientY - previewRect.top;

    const sticker = document.createElement('img');
    sticker.src = src;
    sticker.className = 'placed-sticker position-absolute';
    sticker.style.left = `${x}px`;
    sticker.style.top = `${y}px`;
    sticker.style.transform = 'rotate(0deg)';
    sticker.style.cursor = 'pointer';

    // Custom data
    sticker.dataset.stickerId = stickerId;
    sticker.dataset.x = x;
    sticker.dataset.y = y;
    sticker.dataset.scale = 1;
    sticker.dataset.rotation = 0;

    // Append and track it
    content.appendChild(sticker);
    makeMovable(sticker);
    stickersState.add(sticker);
    selectSticker(sticker);
  });

  // Make all stickers in the tray carry metadata on drag
  document.getElementById('sticker-list').addEventListener('dragstart', (e) => {
    if (e.target.tagName === 'IMG') {
      e.dataTransfer.setData('sticker-id', e.target.dataset.stickerId);
      e.dataTransfer.setData('sticker-src', e.target.src);
    }
  });
}

function makeMovable(el) {
  let isDragging = false;
  let offsetX, offsetY;

  el.addEventListener('click', () => {
    selectSticker(el);
  });
  
  el.addEventListener('mousedown', (e) => {
    e.preventDefault();
    isDragging = true;
    offsetX = e.offsetX;
    offsetY = e.offsetY;
    el.style.zIndex = 1000; // Bring to front
  });

  document.addEventListener('mousemove', (e) => {
    if (!isDragging) return;

    const container = document.getElementById('preview-stickers');
    const rect = container.getBoundingClientRect();
    const x = e.clientX - rect.left - offsetX;
    const y = e.clientY - rect.top - offsetY;

    const stickerSize = el.offsetWidth || 60;
    const clampedX = clamp(x, -stickerSize + 20, container.offsetWidth - 20);
    const clampedY = clamp(y, -stickerSize + 20, container.offsetHeight - 20);

    el.style.left = `${clampedX}px`;
    el.style.top = `${clampedY}px`;

    el.dataset.x = clampedX;
    el.dataset.y = clampedY;

  });

  document.addEventListener('mouseup', () => {
    if (isDragging) {
      isDragging = false;
      el.style.zIndex = ''; // Reset
    }
  });
}
