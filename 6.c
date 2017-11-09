#include <stdio.h>
#include <string.h>

int main(int argc, char* argv[]){
	char first[20] = "\e[38;5;";
	char write[40] = "";
	char numb[3] = "";

	for(int i = 0; i < 256; i++){
		strcpy(write, first);
		sprintf(numb, "%d", i);
		strcat(write, numb);
		strcat(write, "mHello,World!\n");
		printf("%s", write);
	}
}
