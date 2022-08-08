#ifndef STRUCT_STRING_ARRAY
#define STRUCT_STRING_ARRAY
#include <string.h>

#include <stdio.h>
typedef struct s_string_array
{
    int size;
    char** array;
} string_array;
#endif


char* my_join(string_array* string, char* limit)
{
    int size = 0;

    for(int i = 0; i < string->size; i++ ){
        size += strlen(string->array[i]); // allocate memory for each string, based on the length of the string
    }
    size += ((string->size -1) * strlen(limit) + 1);

    
    char ans[size];


   // printf("%d", size);
    int track = 0;
    int j = 0;
    // append the strings onto ans , with delimiters between the strings


    

    while(j < string->size){
        for(int i = 0; i < strlen(string->array[j]); i++){
           char app = string->array[j][i];
         //  printf("%c", app);
           ans[track] = app;
           track++;
          // printf("%d", track);
        }
        /*
        if(j < string->size - 1 ){
            for(int k = 0; k < strlen(limit); k++){
                ans[track] = limit[k];
                track++;
            }
        }
            */
        j++;
    }
   // strcat(ans, 0);
   // printf("%s", ans);
    
    char *ptr = ans;

    return ptr;


}

int main(){
    char *test1[] = {"abc", "def", "gh", "!"};
    char *limit[] = "-";



    printf("%s", my_join(test1,limit));

    return 0;






}