var dates = document.getElementsByClassName('pt-text')[0].children[0].innerText.split('(')[1].slice(0, -1).split('— ');
var interval = {fromTime: dates[0], toTime: dates[1]}
var days = Array.from(document.getElementsByClassName('dn-items')[0].children)

days = days.filter((e) => e.className.split(' ')[0] == 'dn-item');

days = days.map((e) => {
    return {
        dayDate: e.children[0].children[0].innerText,
        lines: Array.from(e.children[1].children).map((d) => {
            var contentParents = Array.from(d.children[2].children).filter((j) => j.className == 'dnip-div');
            var content = [];
                contentParents.forEach((contentParent) => {
                    var classAudience = '';
                    try{classAudience = contentParent.children[0].children[0].innerText;}catch(e){}
                    var curr = '';
                    try{curr = contentParent.children[1].children[0].children[0].innerText;
                       curr = curr.replace(`${workType}: `, '');
                           }catch(e){}
                    var workType = '';
                    try{workType = curr.split(':')[0]}catch(e){};
                    var mark = '';
                    try{mark = contentParent.children[1].children[0].children[1].children[0].innerText}catch(e){}
                    var name = '';
                    try{name = contentParent.children[0].innerText}catch(e){}
                    var homework = '';
                    try{
                        homework = contentParent.children[1].innerText.split('\n').filter((e) => e.slice(0, 4) == "Д/з:");
                    }catch(e){}
                    var lessonName = classAudience == '' ? name : name.replace(classAudience, '').slice(0, -1);
                    content.push({
                        classAudience: classAudience,
                        name: lessonName,
                        workType: workType,
                        topic: curr,
                        mark: mark,
                        homework:
                            [{exercises: [{exercise: homework[0]}]}]
                    });
                });

            var t = d.children[1].innerText.split('\n');
            return {
                index: parseInt(d.children[0].innerText.replace('.', '')),
                lessonTime: {
                    fromTime: t[0],
                    toTime: t[1]
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
