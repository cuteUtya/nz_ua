var active;
var tabs = Array.from(document.getElementById("w0").children).map((e) => {
  if (e.className === "active") active = e;
  return { link: e.children[0].href, name: e.children[0].text };
});
var o = { tabs: tabs, activeTab: active.children[0].text };

o;
