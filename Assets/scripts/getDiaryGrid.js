var table = document.getElementsByClassName('point-table')[0];
var datesText =document.getElementsByClassName('point-table')[0].children[0].children[0].children[0].children[0].innerText;
var dates = datesText.split('—');

var from = dateToFormat(getThisStartDate());
var to = new Date(from);
to.setDate(to.getDate() + 14);
to = dateToFormat(to);

var interval = {
    fromTime: from,
    toTime: to,
}

function dateToFormat(c) {
    var tzoffset = (new Date()).getTimezoneOffset() * 60000;
    return new Date((new Date(c - tzoffset))).toISOString().split('T')[0]
}

function getThisStartDate(){
    var d = dates[0];
    var f = parseInt(d.split(' '))

var l = d.split(' ')[1].trim();

var m = {
'січня': 1,
'лютого':2,
'березня': 3,
'квітня': 4,
'травня': 5,
'червня':6,
'липня':7,
'серпня':8,
'вересня':9,
'жовтня': 10,
'листопада': 11,
'грудня': 12,
}[l];

    return new Date(Date.parse(new Date(`${new Date().getFullYear()}-${m}-${f}`)));
}

var i = 0;

var lines = Array.from(table.children[1].children).map((e) => {
    var name = '';
    var values = [];

    var arr = Array.from(e.children);
    arr.map((c) => {
        if(arr.indexOf(c) == 0) {
            name = c.innerText;
        } else {
            values.push(c.innerText)
        }
    })

    return {
        lessonName: name,
        marks: values,
    }
})

var d = {
    interval: interval,
    lines: lines,
}

console.log('im here');
console.log(JSON.stringify(d));

d