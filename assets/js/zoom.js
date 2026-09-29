// Initialize Medium Zoom without requiring jQuery.
(function () {
  function initMediumZoom() {
    if (typeof mediumZoom !== "function") return;
    window.medium_zoom = mediumZoom("[data-zoomable]", {
      background: getComputedStyle(document.documentElement).getPropertyValue("--global-bg-color") + "ee",
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initMediumZoom, { once: true });
  } else {
    initMediumZoom();
  }
})();
