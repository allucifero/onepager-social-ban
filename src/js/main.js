/* ══════════════════════════════════════════
   GESUNDHEITS-RESERVE – main.js
   (Script is at bottom of <body> → DOM is ready, no DOMContentLoaded needed)
══════════════════════════════════════════ */

// ── 1. Lucide Icons ──────────────────────────────────────────────────────────
if (typeof lucide !== 'undefined') lucide.createIcons();

// ── 2. Tageszeit-Begrüßung ───────────────────────────────────────────────────
(function setGreeting() {
  const hour = new Date().getHours();
  let text, icon;

  if (hour >= 5 && hour < 12)       { text = 'Guten Morgen!';  icon = 'sun'; }
  else if (hour >= 12 && hour < 17) { text = 'Guten Mittag!';  icon = 'sun-medium'; }
  else if (hour >= 17 && hour < 22) { text = 'Guten Abend!';   icon = 'sunset'; }
  else                               { text = 'Noch wach?';     icon = 'moon'; }

  ['desktop', 'tablet', 'mobile'].forEach(id => {
    const badge = document.getElementById(`greeting-${id}`);
    const label = document.getElementById(`greeting-text-${id}`);
    if (!badge || !label) return;
    label.textContent = text;
    const iconEl = badge.querySelector('[data-lucide]');
    if (iconEl) iconEl.setAttribute('data-lucide', icon);
  });

  // Re-render after updating icon names
  if (typeof lucide !== 'undefined') lucide.createIcons();
})();

// ── 3. Domain anzeigen ───────────────────────────────────────────────────────
(function setDomain() {
  const hostname = window.location.hostname || 'diese Seite';
  ['domain-desktop', 'domain-tablet', 'domain-mobile'].forEach(id => {
    const el = document.getElementById(id);
    if (el) el.textContent = hostname;
  });
})();

// ── 4. Zufälliges Zitat ──────────────────────────────────────────────────────
(function setRandomQuote() {
  const quotes = [
    '„Das echte Leben hat keine Ladezeiten." 🌿',
    '„Jede Minute offline ist eine Minute für dich." ☕',
    '„Dein bester Feed ist der Blick aus dem Fenster." 🪟',
    '„Drei Züge Schach > drei Stunden Doomscrolling." ♟️',
    '„Ruf jemanden an. Nicht anschreiben. Anrufen." 📞',
    '„Draußen gibt\'s kein Buffering." 🌳',
    '„Deine Aufmerksamkeit gehört dir — nicht dem Algorithmus." 🧠',
    '„Pro-Tipp: Wasser trinken, Fenster auf, tief atmen." 💧',
  ];
  const quote = quotes[Math.floor(Math.random() * quotes.length)];
  ['quote-desktop', 'quote-tablet', 'quote-mobile'].forEach(id => {
    const el = document.getElementById(id);
    if (el) el.textContent = quote;
  });
})();
