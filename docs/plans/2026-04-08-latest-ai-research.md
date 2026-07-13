# AgentsPulse Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Bootstrap the new GitHub Pages repository from the reference Jekyll template with lightweight sample content and repo-specific branding.

**Architecture:** Copy a minimal subset of the reference Jekyll site into the new repository, keep only the directories needed to build the tutorials homepage, then rebrand configuration and seed a few sample tutorial entries plus their required images. Verify with a smoke test and a local Jekyll build.

**Tech Stack:** Jekyll, Liquid, Sass, Ruby gems from the reference `Gemfile`, shell verification.

---

### Task 1: Add a smoke test for the generated homepage

**Files:**
- Create: `tests/smoke_homepage.sh`

**Step 1: Write the failing test**

Create a shell script that fails when `_site/index.html` is missing or does not include `AgentsPulse`.

**Step 2: Run test to verify it fails**

Run: `bash tests/smoke_homepage.sh`
Expected: FAIL because `_site/index.html` does not exist yet.

**Step 3: Write minimal implementation**

Copy the required Jekyll skeleton and content so the build can later produce `_site/index.html`.

**Step 4: Run test to verify it passes**

Run after build: `bash tests/smoke_homepage.sh`
Expected: PASS with the expected site title present.

### Task 2: Copy the minimal Jekyll skeleton

**Files:**
- Create: `Gemfile`
- Create: `_config.yml`
- Create: `_includes/*`
- Create: `_layouts/*`
- Create: `_sass/*`
- Create: `_plugins/*`
- Create: `_pages/*`
- Create: `_data/*`
- Create: `assets/*`

**Step 1: Copy only the minimal directories and files needed to build**

Exclude heavy generated folders, caches, vendor directories, and search-engine verification files.

**Step 2: Verify structure exists**

Run: `find . -maxdepth 2 | sort`
Expected: key Jekyll directories exist in the new repo.

### Task 3: Rebrand and trim the configuration

**Files:**
- Modify: `_config.yml`
- Modify: `_data/socials.yml`
- Modify: `_pages/tutorials.md`

**Step 1: Replace reference-site identity and metadata**

Set the new site title, description, URL, and neutral social placeholders.

**Step 2: Remove setup that should not be inherited**

Disable or blank Google/Bing verification and any old site-specific branding.

**Step 3: Keep homepage content generic but useful**

Retain the tutorials listing structure while changing the visible heading/subheading to fit the new site.

### Task 4: Seed lightweight sample content

**Files:**
- Create: `_tutorials/*` for a few sample articles
- Create: `images/*` only for those articles

**Step 1: Choose a very small sample set**

Copy a few tutorial markdown files from the reference site.

**Step 2: Copy only referenced image folders**

Ensure the sample pages render without broken local images.

### Task 5: Verify build output

**Files:**
- No new source files expected beyond generated output

**Step 1: Install gems if needed**

Run: `bundle install`

**Step 2: Build the site**

Run: `bundle exec jekyll build`
Expected: successful build output with `_site/index.html` generated.

**Step 3: Run smoke test**

Run: `bash tests/smoke_homepage.sh`
Expected: PASS.
