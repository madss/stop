%lex
%%

\s+                      { /* skip whitespace */ }
"="                      { return '='; }
"|"                      { return '|'; }
","                      { return ','; }
";"                      { return ';'; }
"("                      { return '('; }
")"                      { return ')'; }
"->"                     { return '->'; }
"match"                  { return 'MATCH'; }
"of"                     { return 'OF'; }
"end"                    { return 'END'; }
"fn"                     { return 'FN'; }
"print"                  { return 'PRINT'; }
[0-9]+("."[0-9]+)?\b     { return 'NUMBER'; }
[_a-zA-Z][_a-zA-Z0-9]*\b { return 'ID'; }
<<EOF>>                  { return 'EOF'; }
.                        { return 'INVALID'; }

/lex

/* operator associations and precedence */

%left ';'
%left '='
%left 'FN', 'PRINT', 'ID'

%start main

%% /* language grammar */

main
    : expr EOF { return $1; }
    ;

expr
    : ID
        { $$ = new yy.IdExpr(yytext); }
    | NUMBER
        { $$ = new yy.NumExpr(Number(yytext)); }
    | '(' expr ')'
        { $$ = $2; }
    | ID '=' expr
        { $$ = new yy.AssignExpr($1, $3); }
    | expr ';' expr
        { $$ = new yy.SeqExpr($1, $3); }
    | MATCH expr OF matches END
        { $$ = new yy.MatchExpr($2, $4); }
    | FN ID '->' expr
        { $$ = new yy.FnExpr($2, $4); }
    | ID expr
        { $$ = new yy.AppExpr($1, $2); }
    | PRINT expr
        { $$ = new yy.PrintExpr($2); }
    ;

matches
    : matches '|' mrule
        { $$ = $1; $1.push($3); }
    | mrule
        { $$ = [$1]; }
    ;

mrule
    : pat '->' expr
        { $$ = new yy.MRule($1, $3); }
    ;

pat
    : ID
        { $$ = new yy.IdPat(yytext); }
    | NUMBER
        { $$ = new yy.NumPat(Number(yytext)); }
    ;
