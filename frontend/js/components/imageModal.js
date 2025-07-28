// /js/components/imageModal.js

import { isLoggedIn, getCurrentUser } from '../auth.js';
import { apiFetch } from '../api.js';

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

  const username = image.user?.username || 'anonymous';
  const createdAt = new Date(image.created_at).toLocaleString();

  const currentUser = isLoggedIn() ? getCurrentUser() : null;
  const userLiked = currentUser && image.likes.some(like => like.username === currentUser.identity);

  content.innerHTML = `
    <div class="d-flex flex-column align-items-center position-relative p-0">
      <!-- Metadata -->
      <div class="w-100 d-flex justify-content-between align-items-center px-3 py-2 border-bottom">
        <span class="fw-semibold">@${username}</span>
        <small class="text-muted">${createdAt}</small>
      </div>

      <img src="${image.file_path}" alt="Image" class="img-fluid" />

      <!-- Floating arrows -->
      <button class="nav-arrow left" aria-label="Previous"><i class="bi bi-chevron-left"></i></button>
      <button class="nav-arrow right" aria-label="Next"><i class="bi bi-chevron-right"></i></button>

      <!-- Owner menu (archive/delete) -->
      ${currentUser && currentUser.identity === image.user?.username ? `
        <div class="dropdown-manual position-absolute top-0 end-0" style="margin: 3rem 0.5rem 0;">
          <button id="dropdown-toggle" class="btn btn-sm btn-light rounded-circle">
            <i class="bi bi-three-dots-vertical"></i>
          </button>
          <div id="dropdown-menu" class="dropdown-menu-manual d-none">
            <button class="dropdown-item-manual text-danger d-flex align-items-center gap-2" id="delete-btn">
              <i class="bi bi-trash-fill"></i> Delete
            </button>
            <button class="dropdown-item-manual text-warning d-flex align-items-center gap-2" id="archive-btn">
              <i class="bi bi-archive-fill"></i> Archive
            </button>
          </div>
        </div>
        ` : ''
      }

      <!-- Likes -->
      ${currentUser ? `
        <div class="w-100 px-3 py-2 border-top d-flex align-items-center">
          <button class="btn btn-link p-0 me-2 like-btn" title="Toggle Like">
            <i class="bi ${userLiked ? 'bi-heart-fill text-danger' : 'bi-heart'} fs-4"></i>
          </button>
          <span class="like-count">${image.likes.length}</span> likes
        </div>
      ` : ''}

      <!-- Comments -->
      <div class="w-100 p-3 border-top comment-section">
        
        ${currentUser ? `
          <form class="d-flex gap-2" id="comment-form">
            <input type="text" class="form-control" placeholder="Add a comment..." required />
            <button type="submit" class="btn btn-primary">Post</button>
          </form>
        ` : ''}

        <div class="comment-list">
          ${
            image.comments?.length
              ? image.comments.map(c => `
                  <div class="mb-2">
                    <hr>
                    <span class="fw-semibold">@${c.username || 'user'}:</span>
                    <span>${c.content}</span>
                  </div>
                `).join('')
              : '<div class="text-muted">No comments yet.</div>'
          }
        </div>
      </div>
    </div>
  `;

  content.querySelector('.nav-arrow.left').onclick = showPrev;
  content.querySelector('.nav-arrow.right').onclick = showNext;

  // Like button behavior
  if (currentUser) {
    const likeBtn = content.querySelector('.like-btn');
    const likeIcon = likeBtn.querySelector('i');
    const likeCountSpan = content.querySelector('.like-count');

    likeBtn.onclick = async () => {
      const alreadyLiked = image.likes.some(like => like.username === currentUser.identity);
      const endpoint = `/images/${image.id}/${alreadyLiked ? 'unlike' : 'like'}`;

      try {
        const res = await apiFetch(endpoint, {
          method: alreadyLiked ? 'DELETE' : 'POST'
        });

        if (res.ok) {
          // Update the local state
          if (alreadyLiked) {
            image.likes = image.likes.filter(like => like.username !== currentUser.identity);
            likeIcon.className = 'bi bi-heart fs-4';
          } else {
            image.likes.push({ username: currentUser.identity }); // minimal structure
            likeIcon.className = 'bi bi-heart-fill fs-4 text-danger';
          }

          likeCountSpan.textContent = image.likes.length;
        }
      } catch (err) {
        console.error('[Like Error]', err);
      }
    };
  }

  // Comment submission
  const form = content.querySelector('#comment-form');
  if (form) {
    form.onsubmit = async (e) => {
      e.preventDefault();
      const input = form.querySelector('input');
      const text = input.value.trim();
      if (!text) return;

      const res = await apiFetch(`/images/${image.id}/comments`, {
        method: 'POST',
        body: JSON.stringify({ content: text })
      });

      if (res.ok) {
        image.comments.push({
          content: text,
          username: currentUser.username || currentUser.identity
        });

        renderImageModal(image); // re-render with new comment
      }
    };
  }

  /// Archive/Delete logic (dropdown menu)
  if (currentUser && currentUser.identity === image.user?.username) {
    const dropdownToggle = content.querySelector('#dropdown-toggle');
    const dropdownMenu = content.querySelector('#dropdown-menu');

    if (dropdownToggle && dropdownMenu) {
      dropdownToggle.addEventListener('click', (e) => {
        e.stopPropagation();
        dropdownMenu.classList.toggle('d-none');

        const handleOutsideClick = (event) => {
          if (
            !dropdownMenu.contains(event.target) &&
            event.target !== dropdownToggle
          ) {
            dropdownMenu.classList.add('d-none');
            document.removeEventListener('click', handleOutsideClick);
          }
        };

        document.addEventListener('click', handleOutsideClick);
      });

      const archiveBtn = content.querySelector('#archive-btn');
      const deleteBtn = content.querySelector('#delete-btn');

      archiveBtn.onclick = async () => {
        if (confirm('Are you sure you want to archive this image?')) {
          const res = await apiFetch(`/images/${image.id}/archive`, { method: 'POST' });
          if (res.ok) {
            closeModal();
            location.reload();
          } else {
            alert('Failed to archive image.');
          }
        }
      };

      deleteBtn.onclick = async () => {
        if (confirm('Are you sure you want to permanently delete this image?')) {
          const res = await apiFetch(`/images/${image.id}`, { method: 'DELETE' });
          if (res.ok) {
            closeModal();
            location.reload();
          } else {
            alert('Failed to delete image.');
          }
        }
      };
    }
  }

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
