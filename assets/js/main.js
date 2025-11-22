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