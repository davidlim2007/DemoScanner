/* scanner for a sample programming language */

/* To include lex_specs.l in the Visual Studio Build Process, 
   See :
   Specify custom build tools
   https://docs.microsoft.com/en-us/cpp/build/specifying-custom-build-tools?view=vs-2019
*/


%{
/* need this for the call to atof() below */
#include <math.h>
// need this for the call to atoi() below.
#include <stdlib.h>
// need this for the call to strcpy_s() below.
#include <string.h>
// The following is my own way of over-coming POSIX problem involing fileno().
// For some further discussion on such issues, see : 
// Get rid of warning: implicit declaration of function ‘fileno’ in flex
// https://stackoverflow.com/questions/46213840/get-rid-of-warning-implicit-declaration-of-function-fileno-in-flex
#define fileno _fileno
%}

DIGIT						[0-9]
ID							[a-zA-Z_][a-zA-Z_0-9]*

%%

{DIGIT}+					printf( "integer: %s (%d)\n", yytext, atoi( yytext ) );

{DIGIT}+"."{DIGIT}*			printf( "float: %s (%g)\n", yytext, atof( yytext ) );

if|else						printf( "keyword: %s\n", yytext );

{ID}						printf( "identifier: %s\n", yytext );

">"|">="|"<"|"<="			printf( "comparison operator: %s\n", yytext );

"="							printf("assignment operator : %s\n", yytext );

"=="						printf("equality operator : %s\n", yytext );

"!="						printf("inequality operator : %s\n", yytext );

";"							printf("terminator: %s\n", yytext);

"{"    						printf("statement block start: %s\n", yytext);

"}"    						printf("statement block end: %s\n", yytext);

"("    						printf("expression block start: %s\n", yytext);

")"    						printf("expression block end: %s\n", yytext);

"+"|"-"|"*"|"/"				printf( "operator: %s\n", yytext );

[ \t\n]+					/* No code is put in place. We simply eat up whitespace */

.							printf( "unrecognized character: %s\n", yytext );

"/*"						{
								printf("Start Processing Multi-Line Comment.\n");

								register int c;

								for ( ; ; )
								{
									while ((c = input()) != '*' && c != EOF )
										;	   /* eat up text of comment */

									if ( c == '*' )
									{
										while ( (c = input()) == '*' )
											;
										if ( c == '/' )
											break;    /* found the end */
									}

									if ( c == EOF )
									{
										/* error( "EOF in comment" ); */
										printf("EOF in comment\n");
										break;
									}
								}
			     
								printf("End Processing Multi-Line Comment.\n");
							}

"//"|"##"					{
								char szComment[3];		
								strcpy_s(szComment, sizeof(szComment), yytext);
								printf("Start Processing Single-Line Comment [%s].\n", szComment);

								register int c;

								while ((c = input()) != '\n' && c != EOF )
									; /* eat up text of comment until the end of the line */                                  
			     
								printf("End Processing Single-Line Comment [%s].\n", szComment);

								// Other ways of processing single-line comments :
								// "//".*                                    { /* consume //-comment */ }
								// The above regular expression means : on encountering a token that begins with "//" followed by zero or more characters except '\n'.
							}

%%

int yywrap(void)
{
	return 1;
}

void main(int argc, char** argv)
{
    ++argv, --argc;  /* skip over program name */
    if ( argc > 0 )
            fopen_s(&yyin, argv[0], "r" );
    else
            yyin = stdin;

    yylex();
}
