// reactions.js - Botão de reação (👍) por post.
//
// Lê o atributo data-reaction-key do container (gerado pelo Hugo a partir de
// .TranslationKey, compartilhado entre PT/EN) e sincroniza com o endpoint
// /reactions (Cloudflare Pages Function + KV).
//
// Uso no template (single.html):
//   <div class="reactions text-center" data-reaction-key="{{ .TranslationKey }}">
//     <button class="reaction-btn btn btn-outline-primary" data-emoji="👍" type="button">
//       <span class="reaction-emoji" aria-hidden="true">👍</span>
//       <span class="reaction-count">0</span>
//     </button>
//   </div>

(function () {
  "use strict";

  var container = document.querySelector("[data-reaction-key]");
  if (!container) return;

  var key = container.getAttribute("data-reaction-key");
  var button = container.querySelector(".reaction-btn");
  if (!button) return;

  var emoji = button.getAttribute("data-emoji") || "👍";
  var countEl = container.querySelector(".reaction-count");
  var storageKey = "reaction:" + key + ":" + emoji;
  var pending = false;

  function render(count) {
    if (countEl) countEl.textContent = String(count);
  }

  // Contagem atual (best-effort: falha silenciosa mantém o botão utilizável).
  fetch("/reactions?key=" + encodeURIComponent(key))
    .then(function (res) {
      return res.ok ? res.json() : {};
    })
    .then(function (data) {
      render((data && data[emoji]) || 0);
    })
    .catch(function () {
      render(0);
    });

  // Já reagiu neste navegador: desabilita sem nova requisição.
  var reacted = false;
  try {
    reacted = localStorage.getItem(storageKey) === "1";
  } catch (e) {
    // localStorage indisponível (privado/bloqueado): permite reagir sempre.
  }
  if (reacted) {
    button.setAttribute("aria-pressed", "true");
    button.setAttribute("disabled", "disabled");
    return;
  }

  button.addEventListener("click", function () {
    if (pending) return;
    pending = true;
    button.setAttribute("disabled", "disabled");

    fetch("/reactions", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ key: key, emoji: emoji }),
    })
      .then(function (res) {
        return res.ok ? res.json() : null;
      })
      .then(function (data) {
        if (data) {
          render(data[emoji] || 0);
          button.setAttribute("aria-pressed", "true");
          try {
            localStorage.setItem(storageKey, "1");
          } catch (e) {
            // segue sem persistir (privado/bloqueado): pode reagir de novo
            pending = false;
            button.removeAttribute("disabled");
          }
        }
      })
      .catch(function () {
        // Falhou (offline etc.): restaura o botão.
        pending = false;
        button.removeAttribute("disabled");
      });
  });
})();
