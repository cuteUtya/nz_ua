var t = document.getElementById('classselectform-date_from-kvdate')
var obj = {
    interval: {
        from: t.children[0].children[0].value,
        to: t.children[2].children[0].value
    },
    lines: Array.from(document.getElementsByClassName('marks-report')[0].children[1].children).map((e) => {
        return {
            index: parseInt(e.children[0].innerText),
            lessonName: e.children[1].innerText,
            marks: e.children[2].innerText.replace(/ */g, '').split(',')
        }
    })
}

obj
