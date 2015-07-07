%lex
%%

\s+                      { /* skip whitespace */ }
"="                      { return '='; }
";"                      { return ';'; }
[0-9]+("."[0-9]+)?\b     { return 'NUMBER'; }
[_a-zA-Z][_a-zA-Z0-9]+\b { return 'ID'; }
<<EOF>>                  { return 'EOF'; }
.                        { return 'INVALID'; }

/lex

/* operator associations and precedence */

%left ';'
%nonassoc '='

%start main

%% /* language grammar */

main
    : expr EOF { return $1; }
    ;

expr
    : NUMBER
        { $$ = new yy.NumExpr(Number(yytext)); }
    | ID '=' expr
        { $$ = new yy.AssignExpr($1, $3); }
    | expr ';' expr
        { $$ = new yy.SeqExpr($1, $3); }
    ;
