(() => {
  "use strict";

  const button = document.getElementById("back-to-top");
  if (!button) return;

  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  const threshold = 400;
  let ticking = false;

  function update() {
    ticking = false;
    button.classList.toggle("is-visible", window.scrollY > threshold);
  }

  function onScroll() {
    if (ticking) return;
    ticking = true;
    window.requestAnimationFrame(update);
  }

  button.addEventListener("click", () => {
    window.scrollTo({
      top: 0,
      behavior: reduceMotion.matches ? "auto" : "smooth",
    });
  });

  window.addEventListener("scroll", onScroll, { passive: true });
  update();
})();
