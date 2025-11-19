// Minimal menu toggler to sync visibility and ARIA state.
(() => {
  const nav = document.querySelector('.site-nav');
  const toggle = document.querySelector('.nav-toggle');
  const panel = document.querySelector('.nav-panel');
  if (!nav || !toggle || !panel) return;

  const setOpen = (open) => {
    toggle.setAttribute('aria-expanded', open);
    panel.setAttribute('aria-hidden', !open);
    nav.classList.toggle('is-open', open);
  };

  setOpen(false);
  toggle.addEventListener('click', () => setOpen(toggle.getAttribute('aria-expanded') !== 'true'));
})();
