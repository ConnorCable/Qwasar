char letters[27] = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z', " "};
int times[27] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

void reader(char* a){
    
    for(int i = 0; i < 27; i++){
        if(a == letters[i]){
            times[i]++
        }
    }
}

void putter(){
    for(int i = 0; i < 27, i++){
        if(times[i] > 0){
            printf("%c:%d", letters[i], times[i])
        }
    }
}

// argv -> pointer to an array of arguments
int main(int argc, char** argv){

    // read the string
    for(int i = 1; i < argc; i++  ){ // iterate through arguements
        int j = 0;
        while(argv[i] != '\0'){
            reader(argv[i][j]);
            j++;
        }
    }
    // parse the character
    // check if character has been read already
    // if not, create entry for character 
    // if, increment counter for character
    // return string with all characters and their counters


    return 0
}