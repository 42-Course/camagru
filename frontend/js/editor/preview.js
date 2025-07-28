let stream = null;
let activeSource = null; // "webcam", "image", "snapshot"
let videoEl = null;

export async function setupWebcamPreview() {
  const container = document.getElementById('preview-background');
  container.innerHTML = '';

  videoEl = document.createElement('video');
  videoEl.autoplay = true;
  videoEl.playsInline = true;
  videoEl.className = 'w-100 h-100 object-fit-contain';

  try {
    stream = await navigator.mediaDevices.getUserMedia({ video: true });
    videoEl.srcObject = stream;
    container.appendChild(videoEl);
    activeSource = 'webcam';
  } catch (err) {
    console.error('[Webcam] Error:', err);
    container.innerHTML = '<p class="text-danger">Webcam not available.</p>';
  }
  document.getElementById('take-picture-btn')?.classList.remove('d-none');
}

export function stopWebcam() {
  if (stream) {
    stream.getTracks().forEach(track => track.stop());
    stream = null;
  }
}

export function takeSnapshot() {
  if (!videoEl) return null;

  const canvas = document.createElement('canvas');
  canvas.width = videoEl.videoWidth;
  canvas.height = videoEl.videoHeight;
  const ctx = canvas.getContext('2d');
  ctx.drawImage(videoEl, 0, 0);

  return canvas.toDataURL('image/png');
}

export function setPreviewImage(base64) {
  stopWebcam(); // If switching from live feed

  const container = document.getElementById('preview-background');
  container.innerHTML = '';

  const img = document.createElement('img');
  img.src = base64;
  img.className = 'w-100 h-100 object-fit-contain';
  container.appendChild(img);

  activeSource = 'image';
  document.getElementById('take-picture-btn')?.classList.add('d-none');
}

export function getCurrentBaseImage() {
  if (activeSource === 'webcam') {
    return takeSnapshot();
  }

  const img = document.querySelector('#preview-background img');
  return img?.src || null;
}

export function getActiveSource() {
  return activeSource;
}
