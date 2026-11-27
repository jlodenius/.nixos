async function route() {
  const tab = await chrome.tabs.getCurrent();
  const payload = location.hash.slice(1);
  history.replaceState(null, "", location.pathname);
  if (!payload) {
    await chrome.tabs.remove(tab.id);
    return;
  }

  const urls = JSON.parse(decodeURIComponent(payload)).map((url) => new URL(url));
  if (!urls.length || urls.some((url) => !["http:", "https:", "file:"].includes(url.protocol))) {
    throw new Error("Unsupported URL");
  }

  const windows = await chrome.windows.getAll({ windowTypes: ["normal"] });
  // Chromium allocates window IDs in creation order within a session.
  const windowId = Math.min(...windows.filter((win) => !win.incognito).map((win) => win.id));
  for (const url of urls) {
    await chrome.tabs.create({ windowId, url: url.href });
  }
  await chrome.windows.update(windowId, { focused: true }).catch(() => { });
  await chrome.tabs.remove(tab.id);
}

route().catch(() => {
  document.querySelector("#status").textContent = "Could not open in the main Helium window.";
});
