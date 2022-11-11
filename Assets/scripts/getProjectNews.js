//dashboard/global-news
var r = Array.from(document.getElementById("school-news-list").children);
r.shift();
var o = {news: r.map((e) => {
    console.log(e.children)
    return {
    news: e.children[1].innerText,
    newsTime: e.children[0].children[0].innerText,
    author: null,
  };
})
}

o