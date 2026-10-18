var entries = __LAYOUT__;
var holder = new Array(entries.length);  // entry index -> window holding it

var applying = false;
var setSize = {};  // window id -> size apply() asked for, to tell the client's own resizes from echoes
function apply(w, e) {
  applying = true;
  w.desktops = e.desktops.map(function (n) { return workspace.desktops[n - 1]; });
  w.fullScreen = false;
  w.setMaximize(false, false);
  w.frameGeometry = { x: Math.round(e.x), y: Math.round(e.y), width: Math.round(e.w), height: Math.round(e.h) };
  if (e.maximized) w.setMaximize((e.maximized & 1) != 0, (e.maximized & 2) != 0);
  if (e.fullScreen) w.fullScreen = true;
  applying = false;
  setSize[w.internalId] = { w: Math.round(e.w), h: Math.round(e.h) };
}
// Same-class windows are told apart by the size the app gives them, then by caption.
// Size is the better signal: Firefox restores its own window size at login, while its caption is a
// placeholder ("Mozilla Firefox") until the page loads and often differs from the saved one.
// Firefox maps a window at a default size and resizes it to the restored one a moment later, so the
// size is re-read on every resize the app makes (not on the echo of the size apply() set).
// Cost per (window, entry), cheapest first: size distance in 2% steps, caption mismatch, not the
// current holder, open order. Greedy over all pairs, so each window and entry is used once.
// For SETTLE_MS after an entry is claimed the assignment is redone on every change; a window is
// moved only when its entry changes. After that the entry is locked to its window until the window
// closes: captions drift while you browse and must never move windows. When a window closes (a
// splash screen, for example) its entry passes to another window of that class.
var SETTLE_MS = 30000;
var since = new Array(entries.length);  // entry index -> time it was last assigned
var born = {};                          // window id -> latest size chosen by the app itself
function sizeCost(w, e) {
  var b = born[w.internalId];
  return Math.round((Math.abs(b.w - e.w) / e.w + Math.abs(b.h - e.h) / e.h) * 50);
}
function rebalance(closing) {
  var now = Date.now();
  var wins = workspace.windowList().filter(function (w) { return w.normalWindow && w !== closing; });
  var next = new Array(entries.length);
  var taken = [];
  var pairs = [];
  for (var i = 0; i < entries.length; i++) {
    if (holder[i] && holder[i] !== closing && wins.indexOf(holder[i]) >= 0 && now - since[i] > SETTLE_MS) {
      next[i] = holder[i];
      taken.push(holder[i]);
      continue;
    }
    wins.forEach(function (w, j) {
      if (w.resourceClass !== entries[i].cls || !born[w.internalId]) return;
      pairs.push({ i: i, w: w, cost: [sizeCost(w, entries[i]), w.caption === entries[i].caption ? 0 : 1, holder[i] === w ? 0 : 1, j] });
    });
  }
  pairs.sort(function (a, b) {
    for (var k = 0; k < 4; k++) if (a.cost[k] !== b.cost[k]) return a.cost[k] - b.cost[k];
    return 0;
  });
  pairs.forEach(function (p) {
    if (next[p.i] || taken.indexOf(p.w) >= 0) return;
    next[p.i] = p.w;
    taken.push(p.w);
  });
  for (var i = 0; i < entries.length; i++) {
    if (next[i] === holder[i]) continue;
    since[i] = now;
    if (next[i]) {
      console.info("WINLAYOUT-APPLY entry " + i + " <- '" + next[i].caption + "' born " + Math.round(born[next[i].internalId].w) + "x" + Math.round(born[next[i].internalId].h));
      apply(next[i], entries[i]);
    }
  }
  holder = next;
}
function appSized(w) {
  var g = w.frameGeometry, set = setSize[w.internalId];
  if (set && Math.abs(g.width - set.w) <= 2 && Math.abs(g.height - set.h) <= 2) return;
  born[w.internalId] = { w: g.width, h: g.height };
  rebalance();
}
function watch(w) {
  born[w.internalId] = { w: w.frameGeometry.width, h: w.frameGeometry.height };
  w.frameGeometryChanged.connect(function () { if (!applying) appSized(w); });
  w.windowClassChanged.connect(function () { rebalance(); });
  w.captionChanged.connect(function () { rebalance(); });
  rebalance();
}
workspace.windowAdded.connect(watch);
workspace.windowRemoved.connect(rebalance);
workspace.windowList().forEach(watch);
