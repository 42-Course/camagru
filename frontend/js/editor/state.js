// Centralized store for placed stickers

export const stickersState = {
  placed: [],
  selected: null,

  add(stickerEl) {
    this.placed.push(stickerEl);
    this.selected = stickerEl;
    updateSaveButtonState();
  },

  remove(stickerEl) {
    this.placed = this.placed.filter(el => el !== stickerEl);
    if (this.selected === stickerEl) this.selected = null;
    updateSaveButtonState();
  },

  getSelected() {
    return this.selected;
  },

  setSelected(el) {
    this.selected = el;
  },

  getAllMetadata() {
    return this.placed.map(el => ({
      sticker_id: parseInt(el.dataset.stickerId),
      x: parseFloat(el.dataset.x),
      y: parseFloat(el.dataset.y),
      scale: parseFloat(el.dataset.scale),
      rotation: parseFloat(el.dataset.rotation),
    }));
  }
};

function updateSaveButtonState() {
  const btn = document.getElementById('submit-image-btn');
  if (!btn) return;

  btn.classList.toggle('disabled', stickersState.placed.length === 0);
}
