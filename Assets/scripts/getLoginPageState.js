var alerts = [
    ['success', 'alert-success'],
    ['info', 'alert-info'],
    ['warning', 'alert-warning'],
    ['danger', 'alert-danger']
];

var al = [];

alerts.forEach((alrt) => {
    var d = document.getElementsByClassName(alrt[1]);
    Array.from(d).forEach((g) => {
        if(!g.className.split(' ').includes('hide')){
            al.push({
                type: alrt[0],
                text: g.innerText
            });
        }
    })
})

var o = {
    alerts: al
}

o