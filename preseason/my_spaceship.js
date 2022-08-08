


function my_spaceship(code) {
    let x = 0
    let y = 0
    
    let directions = ["up", "right", "down", "left"]
    let direction = 0

    function rotate(dir) {

        if (dir == "R") {
            if (direction == 3) {
                direction = 0
                return
            }
            direction += 1
        }

        if (dir == "L") {
            if (direction == 0) {
                direction = 3
                return
            }
            direction -= 1
        }

        console.log(" direction -->" + directions[direction])
    }

    function jets(num) {
        console.log("jets pointed at " + num + directions[num])
        if (num == 0) {
            console.log("going up")
            y -=1
            return
        }
        if (num == 1) {
            console.log("going right")
            x += 1
            return
        }
        if (num == 2) {
            console.log("going down")
            y += 1
            return
        }

        if (num == 3) {
            console.log("going left")
            x -= 1
            return
        }
    }

    function mover(letter) {
        switch (letter) {
            case 'A':
                console.log("command selector --> " + direction + "\"" + directions[direction] + "\"")
                jets(direction)
                break;
            case 'R':
                console.log("rotating right")
                rotate("R")
                break;
            case 'L':
 
                rotate("L")
                break;
        }

    }

    [...code].forEach(element => {
        console.log("Command --> " + element)
        mover(element)
    });
    string = 
    "{x: " + x + ", " + "y: " + y + ", " + "direction:" + "\'" + directions[direction] + " \'" + "}"

    return string

}
