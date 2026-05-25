(function() {
  let activeColors = null;

  function hexToRgb(hex) {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return { r, g, b };
  }

  function hexToHsl(hex) {
    let { r, g, b } = hexToRgb(hex);
    r /= 255; g /= 255; b /= 255;
    const max = Math.max(r, g, b), min = Math.min(r, g, b);
    let h, s, l = (max + min) / 2;
    if (max === min) {
      h = s = 0;
    } else {
      const d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      switch (max) {
        case r: h = (g - b) / d + (g < b ? 6 : 0); break;
        case g: h = (b - r) / d + 2; break;
        case b: h = (r - g) / d + 4; break;
      }
      h /= 6;
    }
    return { h: Math.round(h * 360), s: Math.round(s * 100), l: Math.round(l * 100) };
  }

  function generateShades(hex, count) {
    const { r, g, b } = hexToRgb(hex);
    const shades = [];
    for (let i = 0; i < count; i++) {
      const factor = i / (count - 1);
      shades.push({
        r: Math.round(r * (1 - factor * 0.85)),
        g: Math.round(g * (1 - factor * 0.85)),
        b: Math.round(b * (1 - factor * 0.85))
      });
    }
    return shades;
  }

  function applyColors() {
    if (!activeColors) return;

    const root = document.documentElement;

    // Temporarily disconnect observer
    if (observer) observer.disconnect();

    // === ACCENT COLOR (primary) ===
    if (activeColors.primary) {
      const rgb = hexToRgb(activeColors.primary);
      const hsl = hexToHsl(activeColors.primary);

      root.style.setProperty('--theme-accent-rgb-r', rgb.r, 'important');
      root.style.setProperty('--theme-accent-rgb-g', rgb.g, 'important');
      root.style.setProperty('--theme-accent-rgb-b', rgb.b, 'important');

      // Primary shades 1-14 (nightTab uses these for all UI tinting)
      for (let i = 1; i <= 14; i++) {
        root.style.setProperty('--theme-primary-' + i + '-r', rgb.r, 'important');
        root.style.setProperty('--theme-primary-' + i + '-g', rgb.g, 'important');
        root.style.setProperty('--theme-primary-' + i + '-b', rgb.b, 'important');
        root.style.setProperty('--theme-primary-' + i + '-h', hsl.h, 'important');
      }
    }

    // === BACKGROUND COLOR (surface) ===
    if (activeColors.surface) {
      const rgb = hexToRgb(activeColors.surface);
      root.style.setProperty('--theme-background-color-rgb-r', rgb.r, 'important');
      root.style.setProperty('--theme-background-color-rgb-g', rgb.g, 'important');
      root.style.setProperty('--theme-background-color-rgb-b', rgb.b, 'important');
    }

    // === LAYOUT COLOR (surface_container) ===
    if (activeColors.surface_container) {
      const hsl = hexToHsl(activeColors.surface_container);
      root.style.setProperty('--theme-layout-color-hsl-h', hsl.h, 'important');
      root.style.setProperty('--theme-layout-color-hsl-s', hsl.s, 'important');
      root.style.setProperty('--theme-layout-color-hsl-l', hsl.l, 'important');
      root.style.setProperty('--theme-layout-color-opacity', '50', 'important');
    }

    // === HEADER COLOR (surface_container_high) ===
    if (activeColors.surface_container_high) {
      const hsl = hexToHsl(activeColors.surface_container_high);
      root.style.setProperty('--theme-header-color-hsl-h', hsl.h, 'important');
      root.style.setProperty('--theme-header-color-hsl-s', hsl.s, 'important');
      root.style.setProperty('--theme-header-color-hsl-l', hsl.l, 'important');
    }

    // === BOOKMARK COLOR (secondary_container) ===
    if (activeColors.secondary_container) {
      const hsl = hexToHsl(activeColors.secondary_container);
      root.style.setProperty('--theme-bookmark-color-hsl-h', hsl.h, 'important');
      root.style.setProperty('--theme-bookmark-color-hsl-s', hsl.s, 'important');
      root.style.setProperty('--theme-bookmark-color-hsl-l', hsl.l, 'important');
    }

    // Reconnect observer
    if (observer) observer.observe(root, { attributes: true, attributeFilter: ['style'] });
  }

  // Watch for nightTab's own style changes and re-enforce our colors
  const observer = new MutationObserver(() => { applyColors(); });

  // Fetch the Matugen-generated color data
  fetch('./colors.json')
    .then(r => r.json())
    .then(colors => {
      activeColors = colors;
      applyColors();
      observer.observe(document.documentElement, { attributes: true, attributeFilter: ['style'] });
    })
    .catch(e => console.log('Matugen Integration: colors.json not found yet.'));
})();
