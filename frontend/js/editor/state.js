// Centralized store for placed stickers

export const stickersState = {
  placed: [],
  selected: null,

  add(stickerEl) {
    this.placed.push(stickerEl);
    this.selected = stickerEl;
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
