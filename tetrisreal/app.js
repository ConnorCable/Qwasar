// CANVAS SETTING
var canvas = document.createElement("canvas");
canvas.setAttribute('width', '200');
canvas.setAttribute('height', '400');
canvas.setAttribute('id', 'tetris_grid')

var grid = document.getElementById("tetris_grid")

var square = canvas.getContext("2d");
square.fillStyle = "black";
let x = 40
let y = 40
const iTetro = () => {
    square.fillRect(x,y,20,80)
}

const lTetro = () => {
    square.fillRect(x,y,20,60)
    square.fillRect(x+20,y,20,20)
}


const shapes = [iTetro, lTetro]

lTetro();

document.body.appendChild(canvas)

//square.fillRect(x,y,20,20);


let movedown = (x,y,shape) => {
    square.clearRect(x, y, 20, 20);
    y += 20;
    square.fillRect(x, y, 20, 20);
}

//setInterval(movedown, 1000)