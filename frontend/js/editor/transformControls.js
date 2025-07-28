import { stickersState } from './state.js';

export function selectSticker(stickerEl) {  
  // Deselect all other stickers
  document.querySelectorAll('.selected-sticker').forEach(el => {
    if (el !== stickerEl) el.classList.remove('selected-sticker');
  });

  // Set layer to highest for the selected sticker
  const parent = stickerEl.parentElement;
  if (parent && parent.lastChild !== stickerEl) {
    parent.appendChild(stickerEl);
  }

  // Set and highlight current selection
  stickersState.setSelected(stickerEl);
  stickerEl.classList.add('selected-sticker');

  // Show controls
  const controls = document.getElementById('sticker-controls');
  controls.classList.remove('d-none');

  // Update sliders
  const scaleSlider = document.getElementById('scaleRange');
  const rotationSlider = document.getElementById('rotationRange');

  scaleSlider.value = parseFloat(stickerEl.dataset.scale || 1);
  rotationSlider.value = parseFloat(stickerEl.dataset.rotation || 0);

  // Bind live updates
  scaleSlider.oninput = () => {
    const scale = parseFloat(scaleSlider.value);
    stickerEl.style.transform = `rotate(${stickerEl.dataset.rotation || 0}deg) scale(${scale})`;
    stickerEl.dataset.scale = scale;
  };

  rotationSlider.oninput = () => {
    const rotation = parseFloat(rotationSlider.value);
    stickerEl.style.transform = `rotate(${rotation}deg) scale(${stickerEl.dataset.scale || 1})`;
    stickerEl.dataset.rotation = rotation;
  };
}
