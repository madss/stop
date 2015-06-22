%lex
%%

\s+                   { /* skip whitespace */ }
[0-9]+("."[0-9]+)?\b  { return 'NUMBER'; }
<<EOF>>               { return 'EOF'; }
.                     { return 'INVALID'; }

/lex

/* operator associations and precedence */

%start main

%% /* language grammar */

main
    : expr EOF { return $1; }
    ;

expr
    : NUMBER
        { $$ = new yy.NumExpr(Number(yytext)); }
    ;
