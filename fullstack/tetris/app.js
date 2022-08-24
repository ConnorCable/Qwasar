document.addEventListener('DOMContentLoaded', () => {
    const grid = document.querySelector('.grid')
    let squares = Array.from(document.querySelectorAll('.grid div'))
    const Scores = document.querySelector("#score")
    const StartButton = document.querySelector("#start-button")
    const width = 10
    var audio = document.querySelector('#audio');
    var sadsong = new Audio("sadsong.mp3")
    let nextRandom = 0
    let timerid
    let score = 0
    const colors = [
        'orange',
        'red',
        'purple',
        'green',
        'blue',
    ]

    console.log(squares)

    const lTetro = [
        [1, width + 1, width * 2 + 1, 2],
        [width, width + 1, width + 2, width * 2 + 2],
        [1, width + 1, width * 2 + 1, width * 2],
        [width, width * 2, width * 2 + 1, width * 2 + 2]
    ]

    const sTetro = [
        [width * 2, width + 1, width * 2 + 1, width + 2],
        [0, width, width + 1, width * 2 + 1],
        [width * 2, width + 1, width * 2 + 1, width + 2],
        [0, width, width + 1, width * 2 + 1]
    ]

    const tTetro = [
        [width, 1, width + 1, width + 2],
        [1, width + 1, width * 2 + 1, width + 2],
        [width, width + 1, width * 2 + 1, width + 2],
        [width, 1, width + 1, width * 2 + 1]
    ]

    const oTetro = [
        [0, width, 1, width + 1],
        [0, width, 1, width + 1],
        [0, width, 1, width + 1],
        [0, width, 1, width + 1]
    ]

    const iTetro = [
        [1, width + 1, width * 2 + 1, width * 3 + 1],
        [width, width + 1, width + 2, width + 3],
        [1, width + 1, width * 2 + 1, width * 3 + 1],
        [width, width + 1, width + 2, width + 3]

    ]

    const Tetros = [lTetro, sTetro, tTetro, oTetro, iTetro]
    let random = Math.floor(Math.random() * Tetros.length)
    let currentpos = 4
    let currentrotation = 0
    let current = Tetros[random][currentrotation]


    function draw() {
        current.forEach(index => {
            squares[currentpos + index].classList.add('tetromino')
            squares[currentpos + index].style.backgroundColor = colors[random]
        })
    }


    function undraw() {
        current.forEach(index => {
            squares[currentpos + index].classList.remove('tetromino')
            squares[currentpos + index].style.backgroundColor = ''
        })
    }

    // timerId = setInterval(moveDown, 1000)

    function control(e) {
        if (e.keyCode === 37) {
            moveLeft()
        } else if (e.keyCode === 38) {
            rotateright()
        } else if (e.keyCode === 67) {
            rotateleft()
        } else if (e.keyCode === 39) {
            moveRight()
        } else if (e.keyCode === 40) {
            moveDown()
        }
    }

    document.addEventListener('keyup', control)


    function moveDown() {
        if(!current.some(index => squares[currentpos + index + width].classList.contains('taken'))){
            undraw()
            currentpos += width
            draw()
        } else {
            freeze()
        }  
    }

    function freeze() {
            current.forEach(index => squares[currentpos + index].classList.add('taken'))
            random = nextRandom
            nextRandom = Math.floor(Math.random() * Tetros.length)
            current = Tetros[random][currentrotation]
            currentpos = 4
            addScore()
            draw()
            displayShape()
            gameOver()
    }

    function moveLeft() {
        undraw()
        const isAtLeftEdge = current.some(index => (currentpos + index) % width === 0)
        if (!isAtLeftEdge) currentpos -= 1
        if (current.some(index => squares[currentpos + index].classList.contains('taken'))) {
            currentpos += 1
        }

        draw()
    }

    function moveRight() {
        undraw()
        const isAtRightEdge = current.some(index => (currentpos + index) % width === width - 1)

        if (!isAtRightEdge) currentpos += 1

        if (current.some(index => squares[currentpos + index].classList.contains('taken'))) {
            currentpos -= 1
        }

        draw()
    }

    function rotateright() {
        undraw()
        currentrotation++
        if (currentrotation == current.length) {
            currentrotation = 0
        }
        current = Tetros[random][currentrotation]
        draw()
    }

    function rotateleft() {
        undraw()
        currentrotation--
        if (currentrotation == -1) {
            currentrotation = 3
        }
        current = Tetros[random][currentrotation]
        draw()
    }

    const displaySquares = document.querySelectorAll(".mini-grid div")
    const displayWidth = 4
    let displayIndex = 0


    const upNextTetro = [
        [1, displayWidth + 1, displayWidth * 2 + 1, 2],
        [0, displayWidth, displayWidth + 1, displayWidth * 2 + 1],
        [1, displayWidth, displayWidth + 1, displayWidth + 2],
        [0, 1, displayWidth, displayWidth + 1],
        [1, displayWidth + 1, displayWidth * 2 + 1, displayWidth * 3 + 1]
    ]

    function displayShape() {
        displaySquares.forEach(square => {
            square.classList.remove('tetromino')
            square.style.backgroundColor = ''
        })

        upNextTetro[nextRandom].forEach(index => {
            displaySquares[displayIndex + index].classList.add('tetromino')
            displaySquares[displayIndex + index].style.backgroundColor = colors[nextRandom]
        })
    }

    function isAtRight() {
        return current.some(index=> (currentPosition + index + 1) % width === 0)  
      }
      
      function isAtLeft() {
        return current.some(index=> (currentPosition + index) % width === 0)
      }

      function checkRotatedPosition(P){
        P = P || currentpos      //get current position.  Then, check if the piece is near the left side.
        if ((P+1) % width < 4) {         //add 1 because the position index can be 1 less than where the piece is (with how they are indexed).     
          if (isAtRight()){            //use actual position to check if it's flipped over to right side
            currentpos += 1    //if so, add one to wrap it back around
            checkRotatedPosition(P) //check again.  Pass position from start, since long block might need to move more.
            }
        }
        else if (P % width > 5) {
          if (isAtLeft()){
            currentpos -= 1
          checkRotatedPosition(P)
          }
        }
      }


    StartButton.addEventListener('click', () => {
        if (timerid) {
            clearInterval(timerid)
            timerid = null
        } else {
            draw()
            timerid = setInterval(moveDown, 1000)
            nextRandom = Math.floor(Math.random() * Tetros.length)
            displayShape()
        }
    })

    function addScore() {
        for (let i = 0; i < 199; i += width) {
            const row = [i, i + 1, i + 2, i + 3, i + 4, i + 5, i + 6, i + 7, i + 8, i + 9]

            if (row.every(index => squares[index].classList.contains('taken'))) {
                score += 10
                Scores.innerHTML = score
                row.forEach(index => {
                    squares[index].classList.remove('taken')
                    squares[index].classList.remove('tetromino')
                    squares[index].style.backgroundColor = ''
                })
                const squaresRemoved = squares.splice(i, width)
                squares = squaresRemoved.concat(squares)
                squares.forEach(cell => grid.appendChild(cell))
            }
        }
    }

    function gameOver() {
        if (current.some(index => squares[currentpos + index].classList.contains('taken'))) {
            Scores.innerHTML = "end"
            clearInterval(timerid)
            audio.pause()
            sadsong.loop = false;
            sadsong.play()
            //squares.forEach(square => square.classList.remove("taken"))
            squares.forEach(square => square.classList.remove("tetromino"))
        }
    }


})