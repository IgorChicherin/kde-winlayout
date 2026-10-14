var out = [];
workspace.windowList().forEach(function (w) {
  if (!w.normalWindow) return;
  out.push({
    cls: w.resourceClass, caption: w.caption,
    desktops: w.desktops.map(function (d) { return d.x11DesktopNumber; }),
    x: w.frameGeometry.x, y: w.frameGeometry.y, w: w.frameGeometry.width, h: w.frameGeometry.height,
    fullScreen: w.fullScreen, maximized: w.maximizeMode, screen: workspace.screens.indexOf(w.output),
    exe: w.pid
  });
});
console.info("WINLAYOUT " + JSON.stringify(out));
