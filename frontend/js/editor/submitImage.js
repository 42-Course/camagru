import { getCurrentBaseImage } from './preview.js';
import { stickersState } from './state.js';
import { apiFetch } from '../api.js';

export function setupImageSubmission() {
  const btn = document.getElementById('submit-image-btn');
  btn.addEventListener('click', async () => {
    if (btn.classList.contains('disabled')) return;

    const container = document.getElementById('preview-stickers');
    if (!container) return;

    const preview_width = container.offsetWidth;
    const preview_height = container.offsetHeight;
    
    // Lock UI
    btn.classList.add('disabled');
    showImageModal('Saving your image...');

    const image = getCurrentBaseImage();
    const stickers = stickersState.getAllMetadata();

    try {
      const res = await apiFetch('/images', {
        method: 'POST',
        body: JSON.stringify({ image, preview_width, preview_height, stickers })
      });
      
      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.error || 'Upload failed');
      }

      showImageModalPreview(data.file_path);
    } catch (err) {
      console.error(err);
      showImageModal(`<p class="text-danger">Something went wrong:<br>${err.message}</p>`);
      disableModalClose(false);
    } finally {
      btn.classList.remove('disabled');
    }
  });
}

function showImageModal(contentHtml) {
  const modal = document.getElementById('image-modal');
  const body = document.getElementById('image-modal-body');

  modal.classList.remove('d-none');
  body.innerHTML = typeof contentHtml === 'string' ? contentHtml : '';
  disableModalClose(true);

  document.body.style.overflow = 'hidden'; // Prevent scrolling
}

function showImageModalPreview(filePath) {
  const body = document.getElementById('image-modal-body');

  body.innerHTML = `
    <h5 class="mb-3">Image Created Successfully 🎉</h5>
    <img src="${filePath}" class="img-fluid mb-3 rounded shadow" />
    <div class="d-flex justify-content-center gap-3">
      <button id="modal-close-btn" class="btn btn-outline-secondary">Close</button>
      <a href="/profile.html" class="btn btn-success">See in Profile</a>
    </div>
  `;

  disableModalClose(false);

  document.getElementById('modal-close-btn').addEventListener('click', closeModal);
}

function closeModal() {
  document.getElementById('image-modal').classList.add('d-none');
  document.body.style.overflow = '';
}

function disableModalClose(disabled) {
  const modal = document.getElementById('image-modal');

  if (disabled) {
    modal.removeEventListener('click', modalClickHandler);
    window.removeEventListener('keydown', modalKeyHandler);
  } else {
    modal.addEventListener('click', modalClickHandler);
    window.addEventListener('keydown', modalKeyHandler);
  }
}

function modalClickHandler(e) {
  if (e.target.id === 'image-modal') {
    closeModal();
  }
}

function modalKeyHandler(e) {
  if (e.key === 'Escape') {
    closeModal();
  }
}
