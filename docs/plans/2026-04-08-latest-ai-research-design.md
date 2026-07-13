# AgentsPulse Site Design

## Goal

Bootstrap `agentspulse.github.io` using the visual and content structure of the reference site at `/Users/krystal/Documents/Playground/aicatnews.github.io`, while keeping the new repo lightweight and easy to rebrand later.

## Scope

- Reuse the reference site's Jekyll theme skeleton, layouts, includes, Sass, and the tutorials-style homepage.
- Copy a small set of sample tutorial posts so the site renders real content immediately.
- Remove or replace reference-site identity, verification tokens, and heavyweight media assets.
- Keep the result compatible with GitHub Pages style hosting via a Jekyll build.

## Non-Goals

- No attempt to preserve the full article archive from the reference site.
- No production analytics, comments, or search-console ownership setup yet.
- No custom domain or SEO fine-tuning beyond sensible default metadata.

## Migration Approach

1. Copy only the directories and files required to build the template and render a tutorials listing.
2. Keep custom plugins that the listing page depends on, but avoid copying large generated output folders and caches.
3. Rebrand the site configuration to `AgentsPulse` and neutralize identity-specific data.
4. Seed a few example tutorials from the reference site, including only the images those pages require.
5. Add a smoke test that proves the generated homepage contains the new site title.

## Risks and Mitigations

- Missing theme assets could break rendering.
  Mitigation: build locally and inspect generated output.
- Sample tutorials may reference missing images.
  Mitigation: choose a very small sample set and copy only referenced image folders.
- Reference-site plugins may pull in extra dependencies.
  Mitigation: keep the copied plugin set aligned with the copied `Gemfile` and verify with a local build.
