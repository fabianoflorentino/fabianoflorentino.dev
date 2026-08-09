(function () {
  "use strict";

  var DEBOUNCE_MS = 300;
  var MAX_RESULTS = 20;
  var indexPromise = null;

  function getIndexUrl() {
    var lang = document.documentElement.lang || "";
    return lang.indexOf("en") === 0 ? "/en/index.json" : "/index.json";
  }

  function normalize(s) {
    return s.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
  }

  function tokenize(q) {
    return normalize(q).split(/\s+/).filter(Boolean);
  }

  function escapeHtml(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
  }

  function escapeRegex(s) {
    return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  function highlight(text, terms) {
    var out = escapeHtml(text);
    terms.forEach(function (term) {
      out = out.replace(new RegExp("(" + escapeRegex(escapeHtml(term)) + ")", "gi"), "<mark>$1</mark>");
    });
    return out;
  }

  function makeSnippet(item, terms) {
    var plain = (item.plain || "").replace(/\s+/g, " ").trim();
    if (!plain) return "";
    var lower = normalize(plain);
    var idx = -1;
    terms.forEach(function (term) {
      var i = lower.indexOf(term);
      if (i !== -1 && (idx === -1 || i < idx)) idx = i;
    });
    if (idx === -1) idx = 0;
    var start = Math.max(0, idx - 60);
    var end = Math.min(plain.length, start + 200);
    var snippet = plain.slice(start, end);
    if (start > 0) snippet = "…" + snippet;
    if (end < plain.length) snippet = snippet + "…";
    return snippet;
  }

  function isValidUrl(url) {
    try {
      var parsedUrl = new URL(url, window.location.origin);
      return parsedUrl.protocol === "http:" || parsedUrl.protocol === "https:";
    } catch (e) {
      return false;
    }
  }

  function loadIndex() {
    if (!indexPromise) {
      indexPromise = fetch(getIndexUrl())
        .then(function (response) {
          if (!response.ok) throw new Error("Failed to fetch search data: " + response.status);
          return response.json();
        })
        .catch(function (error) {
          indexPromise = null;
          throw error;
        });
    }
    return indexPromise;
  }

  function scoreItem(item, terms) {
    var title = normalize(item.title || "");
    var desc = normalize(item.description || "");
    var plain = normalize(item.plain || "");
    var score = 0;
    terms.forEach(function (term) {
      if (title.indexOf(term) !== -1) score += 10;
      if (desc.indexOf(term) !== -1) score += 5;
      if (plain.indexOf(term) !== -1) score += 1;
    });
    return score;
  }

  function positionDropdown() {
    var searchInputs = document.querySelectorAll("#search");
    if (searchInputs.length < 2) return;

    var searchContent = document.getElementById("search-content");
    if (!searchContent) return;

    var rect;
    if (window.innerWidth > 768) {
      rect = searchInputs[0].getBoundingClientRect();
      searchContent.style.width = "500px";
    } else {
      rect = searchInputs[1].getBoundingClientRect();
      searchContent.style.width = "300px";
    }
    searchContent.style.top = rect.top + 50 + "px";
    searchContent.style.left = rect.left + "px";
  }

  function renderResults(searchQuery, items) {
    var container = document.getElementById("search-results");
    if (!container) return;
    container.innerHTML = "";

    if (items.length === 0) {
      var noResults = document.createElement("p");
      noResults.className = "text-center py-3";
      noResults.textContent = 'No results found for "' + searchQuery + '"';
      container.appendChild(noResults);
      return;
    }

    var terms = tokenize(searchQuery);
    items.slice(0, MAX_RESULTS).forEach(function (item) {
      if (!item.permalink || !isValidUrl(item.permalink)) return;

      var card = document.createElement("div");
      card.className = "card";

      var link = document.createElement("a");
      link.href = item.permalink;

      var contentDiv = document.createElement("div");
      contentDiv.className = "p-3";

      var title = document.createElement("h5");
      title.innerHTML = highlight(item.title || "Untitled", terms);

      var snippet = document.createElement("div");
      snippet.innerHTML = highlight(makeSnippet(item, terms) || item.description || "", terms);

      contentDiv.appendChild(title);
      contentDiv.appendChild(snippet);
      link.appendChild(contentDiv);
      card.appendChild(link);
      container.appendChild(card);
    });

    if (items.length > MAX_RESULTS) {
      var more = document.createElement("p");
      more.className = "text-center text-muted py-1";
      more.textContent = "Showing top " + MAX_RESULTS + " of " + items.length + " results";
      container.appendChild(more);
    }
  }

  function performSearch(searchQuery) {
    var searchContent = document.getElementById("search-content");
    var container = document.getElementById("search-results");
    if (!searchContent || !container) return;

    if (searchQuery === "") {
      searchContent.style.display = "none";
      container.innerHTML = "";
      return;
    }

    var terms = tokenize(searchQuery);
    if (terms.length === 0) {
      searchContent.style.display = "none";
      container.innerHTML = "";
      return;
    }

    positionDropdown();

    loadIndex()
      .then(function (index) {
        var results = index
          .filter(function (item) {
            return item && typeof item === "object" && scoreItem(item, terms) > 0;
          })
          .sort(function (a, b) {
            var scoreDiff = scoreItem(b, terms) - scoreItem(a, terms);
            if (scoreDiff !== 0) return scoreDiff;
            return (b.date || "").localeCompare(a.date || "");
          });

        renderResults(searchQuery, results);
        searchContent.style.display = "block";
      })
      .catch(function (error) {
        console.error("Error fetching search data:", error);
        container.innerHTML = "";
      });
  }

  function searchOnChange(evt) {
    clearTimeout(searchOnChange.timer);
    searchOnChange.timer = setTimeout(function () {
      performSearch(evt.target.value.trim());
    }, DEBOUNCE_MS);
  }

  document.addEventListener("keydown", function (evt) {
    if ((evt.ctrlKey || evt.metaKey) && evt.key.toLowerCase() === "k") {
      evt.preventDefault();
      var input = document.querySelector("#search:not([disabled])");
      if (input) input.focus();
    }
  });

  window.searchOnChange = searchOnChange;
})();
