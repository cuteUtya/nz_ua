var dates = document.getElementsByClassName('pt-text')[0].children[0].innerText.split('(')[1].slice(0, -1).split('— ');
var interval = {from: dates[0], to: dates[1]}
var days = Array.from(document.getElementsByClassName('dn-items')[0].children)

days = days.filter((e) => e.className.split(' ')[0] == 'dn-item');

days = days.map((e) => {
    return {
        dayDate: e.children[0].children[0].innerText,
        lines: Array.from(e.children[1].children).map((d) => {
            var contentParents = Array.from(d.children[2].children).filter((j) => j.className == 'dnip-div');
            var content = undefined;

            if(contentParents.length != 0){
            if(contentParents == undefined || contentParents[0].children[0].children[0] == undefined){
            } else {
                content = [];
                contentParents.forEach((contentParent) => {
                    var classAudience = contentParent.children[0].children[0].innerText;
                    var curr = contentParent.children[1].children[0].children[0].innerText;
                    var workType = curr.split(':')[0];
                    var mark = contentParent.children[1].children[0].children[1];
                    content.push({
                        classAudience: classAudience,
                        name: contentParent.children[0].innerText.replace(classAudience, '').slice(0, -1),
                        worktype: workType,
                        topic: curr.replace(`${workType}: `, ''),
                        mark: mark.children[0] == undefined ? undefined : mark.children[0].children[0].innerText,
                        homework: contentParent.children[1].innerText.split('\n').filter((e) => e.slice(0, 4) == "Д/з:")
                    });
                });
            }
            }

            var t = d.children[1].innerText.split('\n');
            return {
                index: int.parse(d.children[0].innerText.replace('.', '')),
                lessonTime: {
                    from: t[0],
                    to: t[1]
                },
                content: content,
            };
        })
    }
})

var o = {
    content: days,
    interval: interval
}

o
