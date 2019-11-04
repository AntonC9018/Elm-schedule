"use strict"

async function init() {
    var app = await initElm();
    app.ports.activateButtons.subscribe(onActivateButton);
}


async function initElm() {
    return Elm.Main.init({
        node: document.getElementById('elm-app'),
        flags: {
            url: "./orar.json",
            orarString: printret(await (await fetch("./orar.json")).text())
        }
    })
}

function onActivateButton(string) {
    print(string);
    var elems = document.querySelectorAll('.fixed-action-btn');
    M.FloatingActionButton.init(elems, options);
}


function printret(val) {
    console.log(JSON.parse(val));
    return val;
}

