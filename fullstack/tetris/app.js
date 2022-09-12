document.addEventListener('DOMContentLoaded', () => {
    // create 210 divs, in the grid div
    function drawgrid() {
        let grid = document.querySelector('.grid')
        for (let i = 0; i < 210; i++) {
            let element = document.createElement('div');
            // creates the floor of the grid, where collision happens initially
            if (i >= 200) {
                element.classList.add('taken');
            }
            grid.appendChild(element);
        }
    }

    drawgrid()


    const grid = document.querySelector('.grid')
    // create an array, and each element contains one div
    let squares = Array.from(document.querySelectorAll('.grid div'))
    const Scores = document.querySelector("#score")
    const StartButton = document.querySelector("#start-button")
    const ResetButton = document.querySelector("#reset")
    const didlose = false

    const gridspacing = 10
    var audio = document.querySelector('#audio');
    var sadsong = new Audio("sadsong.mp3")
    let nextRandom = 0
    let timerid
    let score = 0
    const colors = [
        'DarkSlateGray',
        'maroon',
        'Sienna',
        'LightSlateGrey',
        'SaddleBrown',
    ]


    const lTetro = [
        [1, gridspacing + 1, gridspacing * 2 + 1, 2],
        [gridspacing, gridspacing + 1, gridspacing + 2, gridspacing * 2 + 2],
        [1, gridspacing + 1, gridspacing * 2 + 1, gridspacing * 2],
        [gridspacing, gridspacing * 2, gridspacing * 2 + 1, gridspacing * 2 + 2]
    ]

    const sTetro = [
        [gridspacing * 2, gridspacing + 1, gridspacing * 2 + 1, gridspacing + 2],
        [0, gridspacing, gridspacing + 1, gridspacing * 2 + 1],
        [gridspacing * 2, gridspacing + 1, gridspacing * 2 + 1, gridspacing + 2],
        [0, gridspacing, gridspacing + 1, gridspacing * 2 + 1]
    ]

    const tTetro = [
        [gridspacing, 1, gridspacing + 1, gridspacing + 2],
        [1, gridspacing + 1, gridspacing * 2 + 1, gridspacing + 2],
        [gridspacing, gridspacing + 1, gridspacing * 2 + 1, gridspacing + 2],
        [gridspacing, 1, gridspacing + 1, gridspacing * 2 + 1]
    ]

    const oTetro = [
        [0, gridspacing, 1, gridspacing + 1],
        [0, gridspacing, 1, gridspacing + 1],
        [0, gridspacing, 1, gridspacing + 1],
        [0, gridspacing, 1, gridspacing + 1]
    ]

    const iTetro = [
        [1, gridspacing + 1, gridspacing * 2 + 1, gridspacing * 3 + 1],
        [gridspacing, gridspacing + 1, gridspacing + 2, gridspacing + 3],
        [1, gridspacing + 1, gridspacing * 2 + 1, gridspacing * 3 + 1],
        [gridspacing, gridspacing + 1, gridspacing + 2, gridspacing + 3]
    ]

    const Tetros = [lTetro, sTetro, tTetro, oTetro, iTetro]
    let random = Math.floor(Math.random() * Tetros.length)
    let currentpos = 4
    let currentrotation = 0
    let current_tetro = Tetros[random][currentrotation]

    // the draw function will take the values from the current tetromino array, and iterate over them. Then, it will add the classlist of 'tetromino' in order to render them on the screen
    // draw() will also add a background color to the shape as well
    function draw() {
        current_tetro.forEach(square => {
            let selected_square = squares[currentpos + square]
            selected_square.classList.add('tetromino') // add the tetromino class list where selected_square exists
            selected_square.style.backgroundColor = colors[random]
        })
    }


    function undraw() {
        current_tetro.forEach(square => {
            let selected_square = squares[currentpos + square]
            selected_square.classList.remove('tetromino')
            selected_square.style.backgroundColor = ''
        })
    }


    function control(e) {
        if (e.keyCode === 37) {
            moveLeft()
        }
        else if (e.keyCode === 38) {
            rotateright()
        }
        else if (e.keyCode === 67) {
            rotateleft()
        }
        else if (e.keyCode === 39) {
            moveRight()
        }
        else if (e.keyCode === 40) {
            moveDown()
        }
        else if (e.keyCode === 72) {
            hold()
        }
        else if (e.keyCode === 32) {
            hardDrop()
        }
    }

    document.addEventListener('keyup', control)

    

    // moveDown, as the name implies, moves the shape down. It will only move the shape down if the class 'taken' is not included, which means that the tetromino can't be frozen.
    function moveDown() {
        if (!current_tetro.some(square => squares[currentpos + square + gridspacing].classList.contains('taken'))) {
            undraw()
            currentpos += gridspacing
            draw()
        } else {
            freeze()
        }
    }

    function hardDrop(){
        // this function will move the piece down until it hits another piece
        // move the piece down
        // check for collision,
        while(!current_tetro.some(square => squares[currentpos + square + gridspacing].classList.contains('taken'))){
            moveDown()
        }
    }


    //  freeze is kind of the master function. it will add the class 'taken' to the tetromino, generate the next one, and then draw it at the top of the screen again.
    // it will also check for a row completed, display the next shape in line, and check for a gameover
    function freeze() {
        current_tetro.forEach(square => squares[currentpos + square].classList.add('taken'))
        random = nextRandom
        nextRandom = Math.floor(Math.random() * Tetros.length)
        current_tetro = Tetros[random][currentrotation]
        currentpos = 4
        addScore()
        draw()
        displayShape()
        gameOver()
    }

    function moveLeft() {
        undraw()
        const isAtLeftEdge = current_tetro.some(square => (currentpos + square) % gridspacing === 0)
        if (!isAtLeftEdge) currentpos -= 1
        if (current_tetro.some(square => squares[currentpos + square].classList.contains('taken'))) {
            currentpos += 1
        }

        draw()
    }

    function moveRight() {
        undraw()
        const isAtRightEdge = current_tetro.some(square => (currentpos + square) % gridspacing === gridspacing - 1)

        if (!isAtRightEdge) currentpos += 1
        // if there is a piece to the right and you try to move into it, move the piece back to its original position to the left
        if (current_tetro.some(square => squares[currentpos + square].classList.contains('taken'))) {
            currentpos -= 1
        }

        draw()
    }

    function rotateright() {
        checkRotatedPosition()
        undraw()
        currentrotation++
        if (currentrotation == current_tetro.length) {
            currentrotation = 0
        }
        current_tetro = Tetros[random][currentrotation]
        draw()
    }

    function rotateleft() {
        checkRotatedPosition()
        undraw()
        currentrotation--
        if (currentrotation == -1) {
            currentrotation = 3
        }
        current_tetro = Tetros[random][currentrotation]
        draw()
    }

    const displaySquares = document.querySelectorAll(".mini-grid div")
    const displayWidth = 4
    let displayIndex = 0


    const heldTetro = [
        [1, displayWidth + 1, displayWidth * 2 + 1, 2],
        [0, displayWidth, displayWidth + 1, displayWidth * 2 + 1],
        [1, displayWidth, displayWidth + 1, displayWidth + 2],
        [0, 1, displayWidth, displayWidth + 1],
        [1, displayWidth + 1, displayWidth * 2 + 1, displayWidth * 3 + 1]
    ]

    const HoldSquares = document.querySelectorAll(".hold div")
    

    function hold(){
        
        HoldSquares.forEach(square => {
            square.classList.remove('tetromino')
            square.style.backgroundColor = ''
        })
        heldTetro[random].forEach(square => {
            HoldSquares[displayIndex + square].classList.add('tetromino')
            HoldSquares[displayIndex + square].style.backgroundColor = colors[random]
        })

        undraw()
        random = nextRandom
        nextRandom = Math.floor(Math.random() * Tetros.length)
        current_tetro = Tetros[random][currentrotation]
        //currentpos = 4
        

    }

    function displayShape() {
        displaySquares.forEach(square => {
            square.classList.remove('tetromino')
            square.style.backgroundColor = ''
        })

        heldTetro[nextRandom].forEach(square => {
            displaySquares[displayIndex + square].classList.add('tetromino')
            displaySquares[displayIndex + square].style.backgroundColor = colors[nextRandom]
        })
    }

    function isAtRight() {
        return current_tetro.some(square => (currentpos + square + 1) % gridspacing === 0)
    }

    function isAtLeft() {
        return current_tetro.some(square => (currentpos + square) % gridspacing === 0)
    }

    function checkrotate() {
        //if(current_tetro.some(square => (currentpos + square + 1) % gridspacing === 0 || current_tetro.some(square => (currentpos + square - 1) % gridspacing === 0 ))
        // if the piece is on the right edge -> if the next rotation ends up inside the left edge, move the piece left one square, and then rotate it.
    }

    function checkRotatedPosition(P) {
        P = P || currentpos //get current_tetro position.  Then, check if the piece is near the left side.
        if ((P + 1) % gridspacing < 4) { //add 1 because the position square can be 1 less than where the piece is (with how they are indexed).     
            if (isAtRight()) { //use actual position to check if it's flipped over to right side
                currentpos += 1 //if so, add one to wrap it back around
                checkRotatedPosition(P) //check again.  Pass position from start, since long block might need to move more.
            }
        } else if (P % gridspacing > 5) {
            if (isAtLeft()) {
                currentpos -= 1
                checkRotatedPosition(P)
            }
        }
    }

    

    StartButton.addEventListener('click', () => {
        if (didlose) return

        if (timerid) {
            clearInterval(timerid)
            timerid = null
        } else {
            draw()
            timerid = setInterval(moveDown, 1000)
            if (!squares.some(square => square.classList.contains("tetromino"))) {
                nextRandom = Math.floor(Math.random() * Tetros.length)
            }
            displayShape()
        }
    })

    ResetButton.addEventListener('click', () => {
        clearBoard()
        clearInterval(timerid)
        timerid = null
        nextRandom = Math.floor(Math.random() * Tetros.length)
        current_tetro = Tetros[nextRandom][currentrotation]
        score = 0
        Scores.innerHTML = score
        didlose = false
    })

    function clearBoard() {
        currentpos = 4
        for (let i = 0; i < 199; i += gridspacing) {
            const row = [i, i + 1, i + 2, i + 3, i + 4, i + 5, i + 6, i + 7, i + 8, i + 9]

            row.forEach(square => {
                squares[square].classList.remove('taken')
                squares[square].classList.remove('tetromino')
                squares[square].style.backgroundColor = ''
            })
            const squaresRemoved = squares.splice(i, gridspacing)
            squares = squaresRemoved.concat(squares)
            squares.forEach(cell => grid.appendChild(cell))

        }
    }

    function addScore() {
        for (let i = 0; i < 199; i += gridspacing) {
            const row = [i, i + 1, i + 2, i + 3, i + 4, i + 5, i + 6, i + 7, i + 8, i + 9]

            if (row.every(square => squares[square].classList.contains('taken'))) {
                score += 10
                Scores.innerHTML = score
                row.forEach(square => {
                    squares[square].classList.remove('taken')
                    squares[square].classList.remove('tetromino')
                    squares[square].style.backgroundColor = ''
                })
                const squaresRemoved = squares.splice(i, gridspacing)
                squares = squaresRemoved.concat(squares)
                squares.forEach(cell => grid.appendChild(cell))
            }
        }
    }

    function gameOver() {
        if (current_tetro.some(square => squares[currentpos + square].classList.contains('taken'))) {
            Scores.innerHTML = " Game Over!"
            clearInterval(timerid)
            audio.pause()
            sadsong.loop = false;
            sadsong.play()
            audio.play()
            clearBoard()
            didlose = true
        }
    }


})