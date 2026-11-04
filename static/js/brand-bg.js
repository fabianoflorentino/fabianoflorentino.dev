(() => {
  "use strict";

  const canvas = document.getElementById("brand-particles");
  if (!canvas) return;

  const ctx = canvas.getContext("2d");
  if (!ctx) return;

  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");
  const LINK_DISTANCE = 130;
  const POINTER_DISTANCE = 150;

  let width = 0;
  let height = 0;
  let particles = [];
  let palette = [];
  let frame = 0;
  let running = false;
  let inView = true;
  let lastTime = 0;

  const pointer = { x: -9999, y: -9999 };

  function hexToRgb(value) {
    let hex = (value || "").trim().replace("#", "");
    if (hex.length === 3) {
      hex = hex
        .split("")
        .map((char) => char + char)
        .join("");
    }
    if (hex.length !== 6) return null;
    const num = parseInt(hex, 16);
    if (Number.isNaN(num)) return null;
    return {
      r: (num >> 16) & 255,
      g: (num >> 8) & 255,
      b: num & 255,
    };
  }

  function readPalette() {
    const styles = getComputedStyle(document.body);
    const names = ["--brand-teal", "--brand-cyan", "--brand-violet"];
    const colors = names
      .map((name) => hexToRgb(styles.getPropertyValue(name)))
      .filter(Boolean);
    palette = colors.length ? colors : [{ r: 107, g: 255, b: 214 }];
  }

  function particleCount() {
    return Math.max(18, Math.min(64, Math.round((width * height) / 26000)));
  }

  function randomBetween(min, max) {
    return min + Math.random() * (max - min);
  }

  function createParticle() {
    return {
      x: Math.random() * width,
      y: Math.random() * height,
      vx: randomBetween(-11, 11) || 0.5,
      vy: randomBetween(-11, 11) || 0.5,
      radius: randomBetween(0.7, 1.8),
      color: palette[Math.floor(Math.random() * palette.length)],
    };
  }

  function seed() {
    readPalette();
    particles = Array.from({ length: particleCount() }, createParticle);
  }

  function resize() {
    const rect = canvas.getBoundingClientRect();
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    width = Math.max(1, Math.round(rect.width));
    height = Math.max(1, Math.round(rect.height));
    canvas.width = Math.round(width * dpr);
    canvas.height = Math.round(height * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    seed();
    if (reduceMotion.matches) sync();
  }

  function update(dt) {
    for (const particle of particles) {
      particle.x += particle.vx * dt;
      particle.y += particle.vy * dt;

      const dx = particle.x - pointer.x;
      const dy = particle.y - pointer.y;
      const distance = Math.hypot(dx, dy);
      if (distance > 0 && distance < POINTER_DISTANCE) {
        const force = (1 - distance / POINTER_DISTANCE) * 26;
        particle.x += (dx / distance) * force * dt;
        particle.y += (dy / distance) * force * dt;
      }

      if (particle.x < -20) particle.x = width + 20;
      if (particle.x > width + 20) particle.x = -20;
      if (particle.y < -20) particle.y = height + 20;
      if (particle.y > height + 20) particle.y = -20;
    }
  }

  function draw() {
    ctx.clearRect(0, 0, width, height);

    for (let i = 0; i < particles.length; i += 1) {
      const a = particles[i];
      for (let j = i + 1; j < particles.length; j += 1) {
        const b = particles[j];
        const dx = a.x - b.x;
        const dy = a.y - b.y;
        const distance = Math.hypot(dx, dy);
        if (distance > LINK_DISTANCE) continue;
        const alpha = (1 - distance / LINK_DISTANCE) * 0.16;
        ctx.strokeStyle = `rgba(${b.color.r}, ${b.color.g}, ${b.color.b}, ${alpha})`;
        ctx.lineWidth = 0.7;
        ctx.beginPath();
        ctx.moveTo(a.x, a.y);
        ctx.lineTo(b.x, b.y);
        ctx.stroke();
      }
    }

    for (const particle of particles) {
      const { r, g, b } = particle.color;
      ctx.fillStyle = `rgba(${r}, ${g}, ${b}, 0.62)`;
      ctx.beginPath();
      ctx.arc(particle.x, particle.y, particle.radius, 0, Math.PI * 2);
      ctx.fill();
    }
  }

  function loop(now) {
    if (!running) return;
    const dt = Math.min((now - lastTime) / 1000, 0.05) || 0;
    lastTime = now;
    update(dt);
    draw();
    frame = requestAnimationFrame(loop);
  }

  function start() {
    if (running || reduceMotion.matches || !inView || document.hidden) return;
    running = true;
    lastTime = performance.now();
    frame = requestAnimationFrame(loop);
  }

  function stop() {
    running = false;
    if (frame) cancelAnimationFrame(frame);
    frame = 0;
  }

  function sync() {
    if (reduceMotion.matches) {
      stop();
      draw();
      return;
    }
    if (!inView || document.hidden) {
      stop();
      return;
    }
    start();
  }

  function handlePointer(event) {
    if (event.pointerType === "touch") return;
    const rect = canvas.getBoundingClientRect();
    pointer.x = event.clientX - rect.left;
    pointer.y = event.clientY - rect.top;
  }

  function clearPointer() {
    pointer.x = -9999;
    pointer.y = -9999;
  }

  window.addEventListener("resize", resize, { passive: true });
  window.addEventListener("pointermove", handlePointer, { passive: true });
  document.addEventListener("pointerleave", clearPointer, { passive: true });
  document.addEventListener("visibilitychange", sync);

  if ("IntersectionObserver" in window) {
    const observer = new IntersectionObserver(
      (entries) => {
        inView = entries[0] ? entries[0].isIntersecting : true;
        sync();
      },
      { threshold: 0 },
    );
    observer.observe(canvas);
  }

  if (typeof reduceMotion.addEventListener === "function") {
    reduceMotion.addEventListener("change", sync);
  }

  const themeToggle = document.getElementById("theme-toggle");
  if (themeToggle) {
    themeToggle.addEventListener("click", () => {
      window.setTimeout(() => {
        seed();
        if (!running) draw();
      }, 0);
    });
  }

  resize();
  sync();
})();
