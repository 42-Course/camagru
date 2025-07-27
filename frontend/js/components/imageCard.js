// /js/components/createImageCard.js

import { openImageModal } from './imageModal.js';

export function createImageCard(image, allImages = []) {
  const wrapper = document.createElement('div');
  wrapper.className = 'position-relative image-card overflow-hidden';
  wrapper.style.cursor = 'pointer';

  const img = document.createElement('img');
  img.src = image.file_path;
  img.alt = 'Image';
  img.className = 'w-100';

  const overlay = document.createElement('div');
  overlay.className = 'overlay d-flex justify-content-center align-items-center';
  overlay.innerHTML = `
    <div class="text-white d-flex gap-3 fs-5">
      <div><i class="bi bi-heart-fill"></i> ${image.likes?.length || 0}</div>
      <div><i class="bi bi-chat-fill"></i> ${image.comments?.length || 0}</div>
    </div>
  `;

  overlay.style = `
    position: absolute;
    top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0, 0, 0, 0.4);
    opacity: 0;
    transition: opacity 0.2s;
  `;

  wrapper.appendChild(img);
  wrapper.appendChild(overlay);

  wrapper.addEventListener('mouseenter', () => overlay.style.opacity = '1');
  wrapper.addEventListener('mouseleave', () => overlay.style.opacity = '0');

  wrapper.addEventListener('click', () => openImageModal(image, allImages));

  return wrapper;
}
