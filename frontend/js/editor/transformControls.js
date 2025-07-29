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
  

  const deleteBtn = document.getElementById('delete-sticker-btn');
  deleteBtn.onclick = () => {
    const selected = stickersState.getSelected();
    if (!selected) return;

    selected.remove();
    stickersState.remove(selected);

    // Clear controls
    document.getElementById('sticker-controls').classList.add('d-none');
  };

  updateStickerDebugInfo(stickerEl);
}


export function updateStickerDebugInfo(sticker) {
  const infoBox = document.getElementById('selected-sticker-info');
  if (!infoBox) return;

  const scale = parseFloat(sticker.dataset.scale || 1);
  const rotation = parseFloat(sticker.dataset.rotation || 0);
  const x = parseInt(sticker.dataset.x || 0, 10);
  const y = parseInt(sticker.dataset.y || 0, 10);
  const width = sticker.offsetWidth;
  const height = sticker.offsetHeight;

  const naturalWidth = sticker.naturalWidth;
  const naturalHeight = sticker.naturalHeight;

  infoBox.innerHTML = `
    <strong>Sticker Debug Info</strong><br>
    ID: ${sticker.dataset.stickerId}<br>
    Src: ${sticker.dataset.src}<br>
    Position: (${x}, ${y})<br>
    Scale: ${scale.toFixed(2)}<br>
    Rotation: ${rotation.toFixed(1)}°<br>
    Original Size: ${naturalWidth}x${naturalHeight}<br>
    Display Size: ${width}x${height}
  `;
}
