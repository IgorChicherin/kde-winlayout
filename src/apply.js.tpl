var entries = __LAYOUT__;
var holder = new Array(entries.length);  // entry index -> window holding it

function apply(w, e) {
  w.desktops = e.desktops.map(function (n) { return workspace.desktops[n - 1]; });
  w.fullScreen = false;
  w.setMaximize(false, false);
  w.frameGeometry = { x: Math.round(e.x), y: Math.round(e.y), width: Math.round(e.w), height: Math.round(e.h) };
  if (e.maximized) w.setMaximize((e.maximized & 1) != 0, (e.maximized & 2) != 0);
  if (e.fullScreen) w.fullScreen = true;
}
function holds(w) {
  for (var i = 0; i < entries.length; i++) if (holder[i] === w) return true;
  return false;
}
function claim(w) {
  if (!w.normalWindow || holds(w)) return;
  for (var i = 0; i < entries.length; i++) {
    if (entries[i].cls !== w.resourceClass || holder[i]) continue;
    holder[i] = w;
    apply(w, entries[i]);
    return;
  }
}
function release(w) {
  for (var i = 0; i < entries.length; i++) {
    if (holder[i] !== w) continue;
    holder[i] = null;
    // hand the entry to another live window of the same class (e.g. splash closed, main window stays)
    workspace.windowList().forEach(function (o) { if (o !== w) claim(o); });
  }
}
function watch(w) {
  claim(w);
  w.windowClassChanged.connect(function () { claim(w); });
}
workspace.windowAdded.connect(watch);
workspace.windowRemoved.connect(release);
workspace.windowList().forEach(watch);
