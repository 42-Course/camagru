// Centralized store for placed stickers

export const stickersState = {
  placed: [],
  selected: null,

  add(stickerEl) {
    const maxLayer = Math.max(0, ...this.placed.map(el => parseInt(el.dataset.layer || 0)));
    stickerEl.dataset.layer = maxLayer + 1;
    stickerEl.style.zIndex = stickerEl.dataset.layer;

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
    const maxLayer = Math.max(0, ...this.placed.map(el => parseInt(el.dataset.layer || 0)));
    el.dataset.layer = maxLayer + 1;
    el.style.zIndex = el.dataset.layer;

    this.selected = el;
  },

  getAllMetadata() {
    return [...this.placed]
      .sort((a, b) => parseInt(b.dataset.layer || 0) - parseInt(a.dataset.layer || 0))
      .map(el => ({
        sticker_id: parseInt(el.dataset.stickerId),
        x: parseFloat(el.dataset.x),
        y: parseFloat(el.dataset.y),
        scale: parseFloat(el.dataset.scale),
        rotation: parseFloat(el.dataset.rotation),
        layer: parseInt(el.dataset.layer || 0)
      }));
  }
};

function updateSaveButtonState() {
  const btn = document.getElementById('submit-image-btn');
  if (!btn) return;

  btn.classList.toggle('disabled', stickersState.placed.length === 0);
}
