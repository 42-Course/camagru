// /js/components/imageModal.js

let currentIndex = 0;
let imageList = [];

export function openImageModal(image, allImages = []) {
  const modal = document.getElementById('image-modal');
  const content = modal.querySelector('.modal-content');

  imageList = allImages;
  currentIndex = allImages.findIndex(img => img.id === image.id);
  if (currentIndex === -1) currentIndex = 0;

  renderImageModal(image);
  modal.classList.remove('d-none');

  // Close on click-outside
  modal.style.cursor = 'zoom-out';
  modal.onclick = (e) => {
    if (e.target === modal) closeModal();
  };

  document.addEventListener('keydown', handleKeyNav);
}

function renderImageModal(image) {
  const modal = document.getElementById('image-modal');
  const content = modal.querySelector('.modal-content');

  content.innerHTML = `
    <div class="d-flex flex-column align-items-center position-relative p-0">
      <img src="${image.file_path}" alt="Image" class="img-fluid" />

      <!-- Floating arrows with Bootstrap Icons -->
      <button class="nav-arrow left" aria-label="Previous">
        <i class="bi bi-chevron-left"></i>
      </button>
      <button class="nav-arrow right" aria-label="Next">
        <i class="bi bi-chevron-right"></i>
      </button>

      <div class="w-100 p-3 border-top comment-section">
        <h5 class="mb-3">Comments</h5>
        <div class="comment-list">
          ${image.comments?.length
            ? image.comments.map(c => `<div class="mb-2"><hr><span class="fw-semibold">@${c.username || 'user'}:</span> ${c.content}</div>`).join('')
            : '<div class="text-muted">No comments yet.</div>'
          }
        </div>
      </div>
    </div>
  `;

  content.querySelector('.nav-arrow.left').onclick = showPrev;
  content.querySelector('.nav-arrow.right').onclick = showNext;
}

function showPrev() {
  currentIndex = (currentIndex - 1 + imageList.length) % imageList.length;
  renderImageModal(imageList[currentIndex]);
}

function showNext() {
  currentIndex = (currentIndex + 1) % imageList.length;
  renderImageModal(imageList[currentIndex]);
}

function closeModal() {
  const modal = document.getElementById('image-modal');
  modal.classList.add('d-none');
  document.removeEventListener('keydown', handleKeyNav);
}

function handleKeyNav(e) {
  if (e.key === 'ArrowLeft') showPrev();
  else if (e.key === 'ArrowRight') showNext();
  else if (e.key === 'Escape') closeModal();
}
