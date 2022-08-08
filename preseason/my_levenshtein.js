const my_levenshtein = (str1 , str2) => {

    if (str1.length != str2.length){
        return -1
    }
    count = 0
    for(let i = 0; i < str1.length; i++){
        if (str1[i] != str2[i]){
            count++
        }
    }

    return count

}


let word = my_levenshtein("ACCAGGG", "ACTATGG")
console.log(word)