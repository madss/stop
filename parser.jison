%lex
%%

"#".*\n                  { /* skip comments */ }
\s+                      { /* skip whitespace */ }
"->"                     { return '->'; }
"+"                      { return '+'; }
"-"                      { return '-'; }
"=="                     { return '=='; }
"="                      { return '='; }
"|"                      { return '|'; }
"."                      { return '.'; }
","                      { return ','; }
";"                      { return ';'; }
"("                      { return '('; }
")"                      { return ')'; }
"["                      { return '['; }
"]"                      { return ']'; }
"match"                  { return 'MATCH'; }
"of"                     { return 'OF'; }
"end"                    { return 'END'; }
"fn"                     { return 'FN'; }
"type"                   { return 'TYPE'; }
[0-9]+("."[0-9]+)?\b     { return 'NUMBER'; }
"'"[^']*"'"              { return 'STRING'; }
[_a-zA-Z][_a-zA-Z0-9]*\b { return 'ID'; }
<<EOF>>                  { return 'EOF'; }
.                        { return 'INVALID'; }

/lex

/* operator associations and precedence */

%left ';'
%left '='
%left 'FN', 'ID'
%left '=='
%left '+', '-'
%left '.'
%nonassoc '('

%start main

%% /* language grammar */

main
    : expr EOF { return $1; }
    ;

expr
    : NUMBER
        { $$ = new yy.NumExpr(Number(yytext)); }
    | STRING
        { $$ = new yy.StrExpr(yytext.substr(1, yytext.length - 2)); }
    | lval
        { $$ = $1; }
    | '(' expr ')'
        { $$ = $2; }
    | '[' exprs ']'
        { $$ = new yy.ListExpr($2); }
    | expr '+' expr
        { $$ = new yy.BinExpr($2, $1, $3); }
    | expr '-' expr
        { $$ = new yy.BinExpr($2, $1, $3); }
    | expr '==' expr
        { $$ = new yy.BinExpr($2, $1, $3); }
    | lval '=' expr
        { $$ = new yy.AssignExpr($1, $3); }
    | expr ';' expr
        { $$ = new yy.SeqExpr($1, $3); }
    | MATCH expr OF matches END
        { $$ = new yy.MatchExpr($2, $4); }
    | FN '(' ids ')' '->' expr
        { $$ = new yy.FnExpr($3, $6); }
    | expr '(' exprs ')'
        { $$ = new yy.AppExpr($1, $3); }
    | TYPE '(' ids ')'
        { $$ = new yy.TypeExpr($3); }
    ;

exprs
    :
        { $$ = []; }
    | expr
        { $$ = [$1]; }
    | exprs ',' expr
        { $$ = $1; $$.push($3); }
    ;

lval
    : ID
        { $$ = new yy.IdExpr(yytext); }
    | expr '.' ID
        { $$ = new yy.MemberExpr($1, $3); }
    ;

ids
    :
        { $$ = []; }
    | ID
        { $$ = [$1]; }
    | ids ',' ID
        { $$ = $1; $$.push($3); }
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
    | STRING
        { $$ = new yy.NumPat(yytext.substr(1, yytext.length - 2)); }
    | ID '(' pattypefields ')'
        { $$ = new yy.TypePat($1, $3); }
    ;

pattypefields
    :
        { $$ = []; }
    | ID '=' pat
        { $$ = [new yy.TypePatField($1, $3)]; }
    | pattypefields ',' ID '=' pat
        { $$ = $1; $$.push(new yy.TypePatField($3, $5)); }
    ;
