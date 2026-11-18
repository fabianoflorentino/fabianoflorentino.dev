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

  var lang = (document.documentElement.lang || "").toLowerCase();
  var isPt = lang.indexOf("pt") === 0;
  var MSG_ERROR = isPt
    ? "Não foi possível registrar sua reação. Tente novamente."
    : "Couldn't register your reaction. Please try again.";

  var msgEl = document.createElement("small");
  msgEl.className = "reaction-message d-block mt-2";
  msgEl.setAttribute("role", "status");
  msgEl.style.display = "none";
  container.appendChild(msgEl);

  function showMessage(text) {
    msgEl.textContent = text;
    msgEl.classList.add("text-danger");
    msgEl.style.display = "block";
  }

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
    msgEl.style.display = "none";

    fetch("/reactions", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ key: key, emoji: emoji }),
    })
      .then(function (res) {
        if (!res.ok) {
          throw new Error("reaction request failed: " + res.status);
        }
        return res.json();
      })
      .then(function (data) {
        render((data && data[emoji]) || 0);
        button.setAttribute("aria-pressed", "true");
        try {
          localStorage.setItem(storageKey, "1");
        } catch (e) {
          // segue sem persistir localmente; a contagem já foi registrada.
        }
      })
      .catch(function () {
        // Falhou (offline, endpoint indisponível, erro no servidor): restaura o
        // botão e avisa o usuário em vez de desabilitar em silêncio.
        pending = false;
        button.removeAttribute("disabled");
        showMessage(MSG_ERROR);
      });
  });
})();
