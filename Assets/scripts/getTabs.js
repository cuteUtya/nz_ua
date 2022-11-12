var tabs = Array.from(document.getElementById("w0").children).map((e) => {
  if(e != undefined) {
    return {
        link: e.children[0].href,
        name: e.children[0].innerText,
        active: e.className === "active",
    };
  }
});
var o = { tabs: tabs };

o;
