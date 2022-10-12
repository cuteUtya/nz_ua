//metadata

var result = {};
var profile = document.getElementsByClassName('h-user-info')[0].children[0]
result.me = {
    profileUrl: profile.href,
    fullName: profile.children[1].innerText
}
var leftBlock = document.getElementsByClassName('rs-block');
var homework = leftBlock[0];
result.comingHomework = Array.from(homework.children[1].children).map((e) => {
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
result.latestMarks = Array.from(leftBlock[1].children[1].children).map((e) => {
    return {
        value: parseInt(e.children[1].innerText),
        lesson: e.children[0].innerText
    }
})
result.closestBirthdays = Array.from(leftBlock[2].children[1].children).map((e) => {
    return {
        date: e.children[2].innerText,
        user: {
            fullName: e.children[0].innerText,
            profileUrl: e.children[0].href
        }
    }
})

result