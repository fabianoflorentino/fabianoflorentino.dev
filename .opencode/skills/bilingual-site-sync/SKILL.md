---
name: bilingual-site-sync
description: Enforce Portuguese/English parity on this site. Use whenever updating any user-facing content on fabianoflorentino.dev — editing content/posts (pt/en files), hugo.yaml params (about, hero, experience, education), i18n strings, menus, or static text. Validates that every change is mirrored to both languages (pt default + en) before finishing.
---

# Bilingual Site Sync

This Hugo site is **bilingual**:

- `defaultContentLanguage: pt` (Portuguese is the default).
- `languages: pt, en`.

Any **user-facing change** must be mirrored to **both** languages. Before
finishing a task, always check whether the change is user-facing and, if so,
update both sides. If you only update one language, the other stays stale and
inconsistent.

## Where each language lives

| Content type              | Portuguese (pt)                         | English (en)                                  |
| ------------------------- | --------------------------------------- | --------------------------------------------- |
| Blog posts                | `content/posts/<slug>.pt.md`            | `content/posts/<slug>.en.md`                  |
| Site params (about, hero, experience, education, projects, contact) | top-level `params:` in `hugo.yaml`      | `languages.en.params:` in `hugo.yaml`         |
| UI strings (menu labels, read time, etc.) | `i18n/pt.yaml`                  | `i18n/en.yaml`                                |
| Menus                     | `languages.pt.menus` (in `hugo.yaml`)   | `languages.en.menus` (in `hugo.yaml`)         |

Key nuance: there is **no** `languages.pt.params`. The top-level `params:` block
**is** the Portuguese content. English overrides only the keys it defines under
`languages.en.params`; any key absent there falls back to the Portuguese value.

## Checklist — apply on every change

1. **Is the change user-facing text?**
   - Posts, titles, descriptions, summaries, `about`, `hero`, `experience`,
     `education`, `projects`, `contact`, menus, i18n strings → **yes**, sync both.
   - Build tooling (`Makefile`, `Dockerfile`, `docker-compose.yml`), CSS, layout
     structure, Go functions, `.github/` CI → **no**, skip.
2. **Mirror the change to the other language.**
   - For a post, edit both `.pt.md` and `.en.md` with equivalent content.
   - For `hugo.yaml` params, edit both top-level `params` (pt) and
     `languages.en.params` (en).
   - For UI strings, edit both `i18n/pt.yaml` and `i18n/en.yaml`.
3. **Keep the shape identical.** Same keys, same structure; only the prose
   differs. Numbers, links, and markdown formatting should match.
4. **If you changed only one side and can't translate**, either translate
   equivalent content or ask the user — do not silently leave one language
   stale.

## Workflow

- Start by locating the item in one language, then find its counterpart using
  the table above.
- Make the pt and en edits together, not one after finishing the whole task.
- Before declaring done, re-run the checklist and confirm both sides are
  consistent.

## Example

Updating the "Sobre mim" / "About me" section:

- PT → `hugo.yaml` top-level `params.about.content`.
- EN → `hugo.yaml` `languages.en.params.about.content`.

Both blocks must be updated with equivalent text.
