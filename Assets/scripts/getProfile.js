var p = document.getElementsByClassName('profile-col-2')[0].children[2].innerText.split('\n');
var c1 = document.getElementsByClassName('profile-col-1')[0];

var isTeacher = p[0] == "Предмети:" || p[0] == "Предметы:";
var subjects = null;
var fullName = document.getElementsByClassName('profile-name')[0].innerText;
var classes = null;
var masterOfClass = null;
var schoolName = null;
var currentClass = null;
var birthDate = document.getElementsByClassName('profile-birthday')[0].innerText;
var profilePhotoUrl = document.getElementsByClassName('profile-photo')[0].children[0].src;
var parents = null;

if(isTeacher){
    classes = p[p.length - 3 ].split(',').map((e) => e.replace(/\s/g, ''));
    classes.splice(classes.length-1, 1);
    subjects = [];

    for(var i = 0; i < p.length; i++){
        var e = p[i];
        console.log(e);
        if(e == "") break;
        subjects.push(e);
    }

    if(c1.children.length == 5) masterOfClass = c1.children[2].children[0].innerText;
    schoolName = p[p.length-1];
} else {
    schoolName = document.getElementsByClassName('profile-col-2')[0].children[2].innerText.split('\n')[0]
    currentClass =document.getElementsByClassName('profile-col-2')[0].children[2].children[0].innerText
    parents = [p[3], p[4]];
}

var o = {
    isTeacher: isTeacher,
    fullName: fullName,
    classes: classes,
    formMasterOf: masterOfClass,
    subjects: subjects,
    schoolName: schoolName,
    currentClass: currentClass,
    birthDate: birthDate,
    photoProfileUrl: profilePhotoUrl,
    parents: parents
}

o