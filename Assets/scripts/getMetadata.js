//metadata

var result = {};
var profile = document.getElementsByClassName('h-user-info')[0].children[0]
result.me = {
    profileUrl: profile.href,
    fullName: profile.children[1].innerText
}
var leftBlock = document.getElementsByClassName('rs-block');
var homework = leftBlock[0];

//todo check when homework be
var hasHomework = leftBlock.length == 4;

console.log(hasHomework);

result.comingHomework = !hasHomework ? [] :  Array.from(homework.children[1].children).map((e) => {
    //TODO: support links and bold in homework.exercise
    return {
        date: e.children[0].children[0].innerText + '' + e.children[0].children[1].innerText,
        exercises: Array.from(e.children[1].children).map((d) => {
            return {
                lesson: d.children[0].innerText,
                exercise: d.children[1].innerText
            }
        })
    };
})
result.latestMarks = Array.from(leftBlock[hasHomework ? 1 : 0].children[1].children).map((e) => {
    return {
        value: parseInt(e.children[1].innerText),
        lesson: e.children[0].innerText
    }
})
result.closestBirthdays = Array.from(leftBlock[hasHomework ? 2 : 1].children[1].children).map((e) => {
    var name = e.children[0].innerText;
    var date = e.children[2].innerText.replace(/\n/g, '').trim();
    return {
        date: date,
        user: {
            fullName: name,
            profileUrl: e.children[0].href
        }
    }
})

result