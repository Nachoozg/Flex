
%{
char *titulo;
char *x_min, *x_max;
char *domain_min, *domain_max;
char *formula_mas_larga;
int num_graficas = 0;

%}


%x TIKZ AXIS PLOT COORDINATES TITLE XMIN XMAX DOMAINMIN DOMAINMAX

sp (" "|"\t")*

%%

<INITIAL>\\begin{sp}\{{sp}tikzpicture{sp}\} { BEGIN(TIKZ); /* Cuando lee \begin{tikzpicture} entra a TIKZ*/}

<TIKZ>.|\n                { /* Para que no imprima todo en TIKZ y solo lo necesario */ }

<TIKZ>\\begin{sp}\{{sp}axis{sp}\}  { BEGIN(AXIS); /* Cuando lee \begin{axis} entra a AXIS */ }

<AXIS>title{sp}={sp}\{          { BEGIN(TITLE); }

<TITLE>[^}]+ 			{ titulo = strdup(yytext); BEGIN(AXIS); }

<TITLE>.|\n 		 {/* Para que no imprima nada de más */}

<AXIS>xmin{sp}={sp}             { BEGIN(XMIN); }

<XMIN>[^,]+             { 	char *temp = strdup(yytext);
							double temp_value = atof(temp);
							if (x_min == NULL || temp_value < atof(x_min)) {
								free(x_min);
								x_min = temp;
							} else {
								free(temp);
							}
							BEGIN(AXIS);  
						}

<AXIS>xmax{sp}={sp}             { BEGIN(XMAX); }

<XMAX>[^,]+				{   char *temp = strdup(yytext);
							double temp_value = atof(temp);
							if (x_max == NULL || temp_value > atof(x_max)) {
								free(x_max);
								x_max = temp;
							} else {
								free(temp);
							}
							BEGIN(AXIS);}            

<AXIS>\\addplot 		{ BEGIN(PLOT); }

<PLOT>domain{sp}={sp}      { BEGIN(DOMAINMIN); }

<DOMAINMIN>[^:]+      { char *temp = strdup(yytext);
						double temp_value = atof(temp);
						if (domain_min == NULL || temp_value < atof(domain_min)) {
							free(domain_min);
							domain_min = temp;
						} else {
							free(temp);
						}
						BEGIN(DOMAINMAX); } 

<DOMAINMIN>.|\n 		  {/* Para que no imprima nada de más */}

<DOMAINMAX>{sp}[^:,]+     { char *temp = strdup(yytext);
							double temp_value = atof(temp);
							if (domain_max == NULL || temp_value > atof(domain_max)) {
								free(domain_max);
								domain_max = temp;
							} else {
								free(temp);
							}
						  	BEGIN(PLOT); } 

<DOMAINMAX>.|\n 		 {/* Para que no imprima nada de más */}

<PLOT>\{[^}]+       {
		    			formula_mas_larga = strdup(yytext+1);  //Asigno a formula_mas_larga la formula actual que se lee
						int len = strlen(yytext+1);    //A len le doy el valor de la longitud de la formula que se lee
						char formula[1000];   		   //Creo otra variable llamada formula para operar después
						strcpy(formula, yytext+1);     //A formula le asigno el texto que se lee 
						while (1) {    //Mientras el valor sea 1, es decir, mientras no llegue el final de la lectura
								int caracter = yylex();   //A caracter le asigno cada token que se lee
								if (caracter == 0)        //Si el caracter llega a 0 (final de la entrada o archivo)
									break; 			      //Hago el break del while
								len += strlen(yytext+1);  //se suma a len la longitud del token actual
								strcat(formula, yytext+1);  //Concateno el texto a la variable formula
						}
						if (len > strlen(formula_mas_larga)) {     //Si len es mayor a la longitud de la mas larga almacenada
								formula_mas_larga = strdup(formula);  //Le asigno a formula_mas_larga el valor de formula
						}
							num_graficas++;   //Sumo el contador del número de graficas que tenemos
					}

<PLOT>\;			{ BEGIN(AXIS); }

<COORDINATES>.|\n		{ /* Para que no imprima todo en COORDINATES */}

<PLOT>.|\n			{ /* Para que no imprima todo en PLOT */}

<AXIS>.|\n                { /* Para que no imprima todo en AXIS y solo lo necesario */ }

<AXIS>\\end{sp}\{{sp}axis{sp}\}        { BEGIN(TIKZ); }

<TIKZ>\\end{sp}\{{sp}tikzpicture{sp}\}       { BEGIN(INITIAL); }

.|\n   

%%


int main(int argc, char **argv){
	if(argc > 1) {
		FILE *file;
		file=fopen(argv[1], "r");
		if(!file) {
			fprintf(stderr, "no se puede abrir %s\n", argv[1]);
			exit(1);
		}
		yyin = file;
	} // else yyin=stdin; 
	yylex();
	if(titulo){
		printf("El título es \"%s\".\n", titulo);
	}else{
		printf("El título es \"\".\n");
	}
	free(titulo);
    	if(x_min && x_max){
    		printf("Coordenada mínima: %s y máxima: %s\n", x_min, x_max);
    	}else if(domain_min && domain_max){
    		printf("Coordenada mínima: %s y máxima: %s\n", domain_min, domain_max);	
    	}
    	printf("El gráfico contiene %d gráficas/series\n", num_graficas);
    	printf("La fórmula más larga es \"%s\".\n", formula_mas_larga);
	return 0;
}
