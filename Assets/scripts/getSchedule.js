var table = Array.from(document.getElementsByClassName('schedule-table')[0].children[1].children)

var timings = table.map((e) => {
    var t = e.children[0];
    return {
        from: t.children[1].innerText,
        to: t.children[2].innerText
    }
});

var d = table.map((e) => {
    var arr = Array.from(e.children);
    arr.shift();
    return {
        index: parseInt(e.children[0].children[0].innerText),
        lessons: arr.map((d) => {
            if(d.children[0] == undefined) return undefined;
            return {
                name: d.children[0].children[0].innerText,
                teacher: {
                    fullName: d.children[0].children[1].innerText,
                    profileUrl: d.children[0].children[1].children[0].href,
                },
                classAudience: d.children[0].children[2].innerText
            }
        })
    }
});

var r = [];

for(var i = 0; i < d[0].lessons.length; i++){
    var ll = [];
    for(var x = 0; x < d.length; x++){
        ll.push(d[x].lessons[i]);
    }
    var day = table[0].parentElement.parentElement.children[0].children[0].children[i + 1];
    r.push({
        lessons: ll,
        today: day.children[0].innerText == "сьогодні" || day.children[0].innerText == "сегодня",
        date: day.children[1].innerText + ' ' + day.children[2].innerText,
    });
}

var o = {
    days: r,
    timings: timings,
}

o