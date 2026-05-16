/* Shared client-side Markdown browser.
 *
 * Used by docs/browse.html and docs/tutorial/browse.html.
 * Renders .md files from a fixed directory via fetch() + marked.js.
 * Hash-based routing keeps it GitHub-Pages-friendly (no server rewrites):
 *   browse.html#README.md  →  loads ./md/README.md
 *
 * The host page must define window.MD_BROWSER_CONFIG = {
 *   title:       "Sidebar heading",
 *   baseDir:     "md/",                // relative to the host HTML
 *   files:       ["README.md", ...],   // order shown in sidebar
 *   defaultFile: "README.md"
 * }
 * before loading this script.
 */

(function () {
  "use strict";

  const cfg = window.MD_BROWSER_CONFIG;
  if (!cfg) {
    document.body.innerHTML =
      '<p class="error">MD_BROWSER_CONFIG is not defined.</p>';
    return;
  }

  // --- marked / highlight.js wiring --------------------------------------

  marked.setOptions({
    gfm: true,
    breaks: false,
    headerIds: true,
    mangle: false,
    highlight: function (code, lang) {
      if (window.hljs) {
        if (lang && hljs.getLanguage(lang)) {
          try { return hljs.highlight(code, { language: lang }).value; }
          catch (_) { /* fall through */ }
        }
        try { return hljs.highlightAuto(code).value; }
        catch (_) { /* fall through */ }
      }
      return code;
    },
  });

  // --- DOM scaffolding ---------------------------------------------------

  const app = document.createElement("div");
  app.className = "app";
  app.innerHTML =
    '<nav class="sidebar">' +
      '<div class="siblings"></div>' +
      '<h1></h1>' +
      '<ul></ul>' +
    '</nav>' +
    '<main class="content"><p class="status">Loading…</p></main>';
  document.body.appendChild(app);

  const sidebarTitle = app.querySelector(".sidebar h1");
  const sidebarList  = app.querySelector(".sidebar ul");
  const siblingsBox  = app.querySelector(".sidebar .siblings");
  const content      = app.querySelector(".content");

  sidebarTitle.textContent = cfg.title || "Documents";

  (cfg.siblings || []).forEach(function (s) {
    const a = document.createElement("a");
    a.href = s.href;
    a.textContent = s.label;
    a.className = "sibling" + (s.current ? " current" : "");
    siblingsBox.appendChild(a);
  });

  cfg.files.forEach(function (file) {
    const li = document.createElement("li");
    const a  = document.createElement("a");
    a.href = "#" + encodeURIComponent(file);
    a.textContent = file;
    a.dataset.file = file;
    li.appendChild(a);
    sidebarList.appendChild(li);
  });

  // --- routing -----------------------------------------------------------

  function currentFile() {
    const raw = window.location.hash.replace(/^#/, "");
    if (!raw) return cfg.defaultFile;
    try { return decodeURIComponent(raw); }
    catch (_) { return cfg.defaultFile; }
  }

  function markActive(file) {
    sidebarList.querySelectorAll("a").forEach(function (a) {
      a.classList.toggle("active", a.dataset.file === file);
    });
  }

  // Rewrite links inside rendered markdown:
  //  - links to *.md inside cfg.files become hash links (in-app navigation)
  //  - everything else is left alone (external links, anchors, code paths)
  function rewriteLinks(root) {
    const known = new Set(cfg.files);
    root.querySelectorAll("a[href]").forEach(function (a) {
      const href = a.getAttribute("href");
      if (!href) return;
      if (/^[a-z][a-z0-9+.-]*:/i.test(href)) return;  // http:, mailto: …
      if (href.startsWith("#")) return;                // in-page anchor

      // strip optional ./ prefix and trailing #fragment for matching
      const [path, frag] = href.split("#");
      const clean = path.replace(/^\.\//, "");

      if (known.has(clean)) {
        a.setAttribute(
          "href",
          "#" + encodeURIComponent(clean) + (frag ? "#" + frag : "")
        );
      }
      // Links to files outside cfg.files (e.g. ../../main.c) are left
      // as-is — they resolve relative to the host HTML on GitHub Pages.
    });
  }

  async function load(file) {
    markActive(file);
    content.innerHTML = '<p class="status">Loading ' + file + '…</p>';
    try {
      const res = await fetch(cfg.baseDir + file, { cache: "no-cache" });
      if (!res.ok) throw new Error("HTTP " + res.status);
      const md = await res.text();
      content.innerHTML = marked.parse(md);
      rewriteLinks(content);
      if (window.hljs) {
        content.querySelectorAll("pre code").forEach(function (block) {
          try { hljs.highlightElement(block); } catch (_) {}
        });
      }
      // Scroll to in-page anchor if the hash contained one (file.md#sec).
      const sub = window.location.hash.split("#")[2];
      if (sub) {
        const el = document.getElementById(sub);
        if (el) el.scrollIntoView();
      } else {
        window.scrollTo(0, 0);
      }
      document.title = file + " — " + (cfg.title || "Docs");
    } catch (err) {
      content.innerHTML =
        '<div class="error">Failed to load <code>' + file +
        '</code>: ' + err.message + '</div>';
    }
  }

  window.addEventListener("hashchange", function () { load(currentFile()); });
  load(currentFile());
})();
