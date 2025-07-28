import {
  setupWebcamPreview,
  takeSnapshot,
  setPreviewImage,
  getCurrentBaseImage
} from './preview.js';

function addToImageHistory(base64) {
  const container = document.getElementById('image-history');

  const thumb = document.createElement('img');
  thumb.src = base64;
  thumb.className = 'rounded border';
  thumb.style.width = '60px';
  thumb.style.cursor = 'pointer';
  thumb.title = 'Click to use this image';

  thumb.addEventListener('click', () => {
    setPreviewImage(base64);
  });

  container.prepend(thumb);
}

function addWebcamThumbnail() {
  const container = document.getElementById('image-history');

  const thumb = document.createElement('div');
  thumb.className = 'rounded border d-flex justify-content-center align-items-center bg-light';
  thumb.style.width = '60px';
  thumb.style.height = '60px';
  thumb.style.cursor = 'pointer';
  thumb.title = 'Live Webcam';

  thumb.innerHTML = '<i class="bi bi-camera" style="font-size: 1.5rem;"></i>';

  thumb.addEventListener('click', () => {
    setupWebcamPreview();
  });

  container.prepend(thumb);
}

export async function initEditorPreview() {
  await setupWebcamPreview()
  addWebcamThumbnail();

  document.getElementById('take-picture-btn').addEventListener('click', () => {
    const snapshot = takeSnapshot();
    if (!snapshot) return;

    addToImageHistory(snapshot);
    setPreviewImage(snapshot);
  });

  document.getElementById('upload-image-input').addEventListener('change', (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = () => {
      const base64 = reader.result;
      addToImageHistory(base64);
      setPreviewImage(base64);
    };
    reader.readAsDataURL(file);
  });
}
