/**
 * matugen_loader.js
 * On every new tab open, loads the full Matugen-patched nightTab backup into
 * localStorage BEFORE nightTab's bundle initializes. nightTab reads it on first load.
 *
 * The backup (nighttab-current.json) is regenerated on every wallpaper switch
 * by nighttab-update.py via post-matugen.sh.
 */
(function () {
  const STORAGE_KEY     = 'nightTab';
  const FINGERPRINT_KEY = 'matugenColors';

  try {
    // Synchronous XHR — must complete before nightTab's deferred bundle runs
    const xhr = new XMLHttpRequest();
    xhr.open('GET', './nighttab-current.json', false);
    xhr.setRequestHeader('Cache-Control', 'no-store, no-cache');
    xhr.send(null);

    if (xhr.status !== 200) return;

    const backup = JSON.parse(xhr.responseText);

    // Use primary color as fingerprint — skip write if wallpaper hasn't changed
    const fingerprint = backup.state && backup.state.theme
      ? backup.state.theme.color.range.primary.h + '|' + backup.state.theme.accent.rgb.r
      : null;

    if (fingerprint && localStorage.getItem(FINGERPRINT_KEY) === fingerprint) return;

    // Write the complete backup to localStorage — identical to what nightTab's own Import does
    localStorage.setItem(STORAGE_KEY, JSON.stringify(backup));
    if (fingerprint) localStorage.setItem(FINGERPRINT_KEY, fingerprint);

  } catch (e) {
    // Silent fail — never break nightTab
  }
})();
