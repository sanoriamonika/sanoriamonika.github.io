(function(){
  const current = location.pathname.replace(/\/index\.html$/, '/');
  for (const a of document.querySelectorAll('nav a[data-nav]')){
    const href = a.getAttribute('href');
    if (href === current || (href !== '/' && current.startsWith(href))) {
      a.classList.add('active');
    }
  }
})();
document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".copy-link").forEach(btn => {
    btn.addEventListener("click", () => {
      const url = btn.getAttribute("data-url");
      navigator.clipboard.writeText(url).then(() => {
        btn.textContent = "Copied!";
        setTimeout(() => (btn.textContent = "Copy Link"), 2000);
      });
    });
  });
});

/* =============================== */
/* DOUBLE-CLICK IMAGE ZOOM FEATURE */
/* =============================== */

document.addEventListener("DOMContentLoaded", function() {
  let zoomedImg = null;
  let overlay = null;

  function zoomImage(img) {
    // If already zoomed, unzoom
    if (zoomedImg) {
      return unzoomImage();
    }

    zoomedImg = img;
    img.classList.add("img-zoomed");

    overlay = document.createElement("div");
    overlay.className = "img-zoom-overlay";
    document.body.appendChild(overlay);

    overlay.addEventListener("click", unzoomImage);
  }

  function unzoomImage() {
    if (!zoomedImg) return;

    zoomedImg.classList.remove("img-zoomed");
    zoomedImg = null;

    if (overlay) {
      overlay.remove();
      overlay = null;
    }
  }

  // Attach to all images inside your .figure blocks
  document.querySelectorAll(".figure img").forEach(img => {
    img.addEventListener("dblclick", () => zoomImage(img));
  });
});