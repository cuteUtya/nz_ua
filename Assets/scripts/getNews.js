//dashboard/news
var o = {news: Array.from(
  Array.from(document.getElementsByClassName("messages-list"))[0].children
).map((e) => {
  return {
    news: e.children[1].innerText,
    newsTime: e.children[0].children[1].innerText,
    author: {
      fullName: e.children[0].children[0].children[0].title,
      profileUrl: e.children[0].children[0].children[0].href,
      profilePhotoUrl: e.children[0].children[0].children[0].children[0].src,
    },
  };
})
}

o