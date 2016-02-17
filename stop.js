var output;
var ast;
var input;
var options;
var Options;
var fs;
var translatePat;
var translateExpr;
var translateBlock;
var translate;
var globals;
var b;
var recast;
var p;
var TypePatField;
var TypePat;
var StrPat;
var NumPat;
var IdPat;
var MRule;
var TypeExpr;
var AppExpr;
var FnExpr;
var MatchExpr;
var SeqExpr;
var AssignExpr;
var MemberExpr;
var BinExpr;
var ListExpr;
var StrExpr;
var NumExpr;
var IdExpr;

IdExpr = function type(value) {
    if (this instanceof type) {
        this.value = value;
    } else {
        return new type(value);
    }
};

NumExpr = function type(value) {
    if (this instanceof type) {
        this.value = value;
    } else {
        return new type(value);
    }
};

StrExpr = function type(value) {
    if (this instanceof type) {
        this.value = value;
    } else {
        return new type(value);
    }
};

ListExpr = function type(values) {
    if (this instanceof type) {
        this.values = values;
    } else {
        return new type(values);
    }
};

BinExpr = function type(kind, left, right) {
    if (this instanceof type) {
        this.kind = kind;
        this.left = left;
        this.right = right;
    } else {
        return new type(kind, left, right);
    }
};

MemberExpr = function type(expr, id) {
    if (this instanceof type) {
        this.expr = expr;
        this.id = id;
    } else {
        return new type(expr, id);
    }
};

AssignExpr = function type(lval, expr) {
    if (this instanceof type) {
        this.lval = lval;
        this.expr = expr;
    } else {
        return new type(lval, expr);
    }
};

SeqExpr = function type(left, right) {
    if (this instanceof type) {
        this.left = left;
        this.right = right;
    } else {
        return new type(left, right);
    }
};

MatchExpr = function type(expr, mrules) {
    if (this instanceof type) {
        this.expr = expr;
        this.mrules = mrules;
    } else {
        return new type(expr, mrules);
    }
};

FnExpr = function type(ids, expr) {
    if (this instanceof type) {
        this.ids = ids;
        this.expr = expr;
    } else {
        return new type(ids, expr);
    }
};

AppExpr = function type(expr, args) {
    if (this instanceof type) {
        this.expr = expr;
        this.args = args;
    } else {
        return new type(expr, args);
    }
};

TypeExpr = function type(fields) {
    if (this instanceof type) {
        this.fields = fields;
    } else {
        return new type(fields);
    }
};

MRule = function type(pat, expr) {
    if (this instanceof type) {
        this.pat = pat;
        this.expr = expr;
    } else {
        return new type(pat, expr);
    }
};

IdPat = function type(value) {
    if (this instanceof type) {
        this.value = value;
    } else {
        return new type(value);
    }
};

NumPat = function type(value) {
    if (this instanceof type) {
        this.value = value;
    } else {
        return new type(value);
    }
};

StrPat = function type(value) {
    if (this instanceof type) {
        this.value = value;
    } else {
        return new type(value);
    }
};

TypePat = function type(id, fields) {
    if (this instanceof type) {
        this.id = id;
        this.fields = fields;
    } else {
        return new type(id, fields);
    }
};

TypePatField = function type(key, pat) {
    if (this instanceof type) {
        this.key = key;
        this.pat = pat;
    } else {
        return new type(key, pat);
    }
};

p = require("./parser").parser;
p.yy.IdExpr = IdExpr;
p.yy.NumExpr = NumExpr;
p.yy.StrExpr = StrExpr;
p.yy.ListExpr = ListExpr;
p.yy.BinExpr = BinExpr;
p.yy.MemberExpr = MemberExpr;
p.yy.AssignExpr = AssignExpr;
p.yy.SeqExpr = SeqExpr;
p.yy.MatchExpr = MatchExpr;
p.yy.FnExpr = FnExpr;
p.yy.AppExpr = AppExpr;
p.yy.TypeExpr = TypeExpr;
p.yy.MRule = MRule;
p.yy.IdPat = IdPat;
p.yy.NumPat = NumPat;
p.yy.StrPat = StrPat;
p.yy.TypePat = TypePat;
p.yy.TypePatField = TypePatField;
recast = require("recast");
b = recast.types.builders;

globals = function type(nextVar, nextLabel) {
    if (this instanceof type) {
        this.nextVar = nextVar;
        this.nextLabel = nextLabel;
    } else {
        return new type(nextVar, nextLabel);
    }
}(0, 0);

translate = function(ast) {
    var p;
    p = b.program(translateBlock(ast));
    return recast.print(p).code;
};

translateBlock = function(expr) {
    var expr;
    var stmts;
    var vars;
    vars = [];
    stmts = [];
    expr = translateExpr(vars, stmts, expr);

    vars.forEach(function(id) {
        var declarator;
        declarator = b.variableDeclarator(b.identifier(id), null);
        return stmts.unshift(b.variableDeclaration("var", [declarator]));
    });

    stmts.push(b.expressionStatement(expr));
    return stmts;
};

translateExpr = function(vars, stmts, expr) {
    var e;
    var cond;
    var assignments;
    var ids;
    var f;
    var args;
    var f;
    var a;
    var e;
    var stmt;
    var bstmts;
    var e;
    var i;
    var v;
    var mstmts;
    var label;
    var value;
    var result;
    var m;
    var e;
    var seqe;
    var seqr;
    var seql;
    var expr;
    var lval;
    var $5;
    var $4;
    var e;
    var l;
    var e;
    var i;
    var e;
    var op;
    var $3;
    var $2;
    var binright;
    var binleft;
    var binr;
    var binl;
    var bink;
    var listvalues;
    var strvalue;
    var numvalue;
    var idvalue;
    var $1;
    var $0;

    label0:
    {
        $1 = expr;

        if ($1 instanceof IdExpr) {
            idvalue = $1.value;
            $0 = b.identifier(idvalue);
            break label0;
        }

        if ($1 instanceof NumExpr) {
            numvalue = $1.value;
            $0 = b.literal(numvalue);
            break label0;
        }

        if ($1 instanceof StrExpr) {
            strvalue = $1.value;
            $0 = b.literal(strvalue);
            break label0;
        }

        if ($1 instanceof ListExpr) {
            listvalues = $1.values;

            $0 = b.arrayExpression(listvalues.map(function(listvalue) {
                return translateExpr(vars, stmts, listvalue);
            }));

            break label0;
        }

        if ($1 instanceof BinExpr) {
            bink = $1.kind;
            binl = $1.left;
            binr = $1.right;
            binleft = translateExpr(vars, stmts, binl);
            binright = translateExpr(vars, stmts, binr);

            label1:
            {
                $3 = bink;

                if ($3 === "and") {
                    $2 = b.logicalExpression("&&", binleft, binright);
                    break label1;
                }

                if ($3 === "or") {
                    $2 = b.logicalExpression("||", binleft, binright);
                    break label1;
                }

                op = $3;
                $2 = b.binaryExpression(bink, binleft, binright);
                break label1;
            }

            $0 = $2;
            break label0;
        }

        if ($1 instanceof MemberExpr) {
            e = $1.expr;
            i = $1.id;
            e = translateExpr(vars, stmts, e);
            $0 = b.memberExpression(e, b.identifier(i));
            break label0;
        }

        if ($1 instanceof AssignExpr) {
            l = $1.lval;
            e = $1.expr;
            "FIXME: Only push var if it is undeclared";

            label2:
            {
                $5 = l;

                if ($5 instanceof IdExpr) {
                    $4 = vars.push(l.value);
                    break label2;
                }
            }

            $4;
            lval = translateExpr(vars, stmts, l);
            expr = translateExpr(vars, stmts, e);
            $0 = b.assignmentExpression("=", lval, expr);
            break label0;
        }

        if ($1 instanceof SeqExpr) {
            seql = $1.left;
            seqr = $1.right;
            seqe = translateExpr(vars, stmts, seql);
            stmts.push(b.expressionStatement(seqe));
            $0 = translateExpr(vars, stmts, seqr);
            break label0;
        }

        if ($1 instanceof MatchExpr) {
            e = $1.expr;
            m = $1.mrules;
            result = "$" + globals.nextVar;
            vars.push(result);
            globals.nextVar = globals.nextVar + 1;
            value = "$" + globals.nextVar;
            vars.push(value);
            globals.nextVar = globals.nextVar + 1;
            label = b.identifier("label" + globals.nextLabel);
            globals.nextLabel = globals.nextLabel + 1;
            mstmts = [];
            v = translateExpr(vars, mstmts, e);
            mstmts.push(b.expressionStatement(b.assignmentExpression("=", b.identifier(value), v)));

            m.forEach(function(mrule) {
                var e;
                var bstmts;
                bstmts = translatePat(vars, mstmts, b.identifier(value), mrule.pat);
                e = translateExpr(vars, bstmts, mrule.expr);

                bstmts.push(
                    b.expressionStatement(b.assignmentExpression("=", b.identifier(result), e))
                );

                return bstmts.push(b.breakStatement(label));
            });

            stmts.push(b.labeledStatement(label, b.blockStatement(mstmts)));
            $0 = b.identifier(result);
            break label0;
        }

        if ($1 instanceof FnExpr) {
            i = $1.ids;
            e = $1.expr;
            bstmts = translateBlock(e);
            stmt = bstmts.pop();
            bstmts.push(b.returnStatement(stmt.expression));

            $0 = b.functionExpression(null, i.map(function(id) {
                return b.identifier(id);
            }), b.blockStatement(bstmts));

            break label0;
        }

        if ($1 instanceof AppExpr) {
            e = $1.expr;
            a = $1.args;
            f = translateExpr(vars, stmts, e);

            args = a.map(function(arg) {
                return translateExpr(vars, stmts, arg);
            });

            $0 = b.callExpression(f, args);
            break label0;
        }

        if ($1 instanceof TypeExpr) {
            f = $1.fields;

            ids = f.map(function(id) {
                return b.identifier(id);
            });

            assignments = ids.map(function(id) {
                return b.expressionStatement(
                    b.assignmentExpression("=", b.memberExpression(b.thisExpression(), id), id)
                );
            });

            cond = b.binaryExpression("instanceof", b.thisExpression(), b.identifier("type"));

            $0 = b.functionExpression(b.identifier("type"), ids, b.blockStatement([b.ifStatement(
                cond,
                b.blockStatement(assignments),
                b.blockStatement([b.returnStatement(b.newExpression(b.identifier("type"), ids))])
            )]));

            break label0;
        }

        e = $1;
        $0 = "Unknown expression: " + JSON.stringify(e, null, 4);
        break label0;
    }

    return $0;
};

translatePat = function(vars, stmts, expr, pat) {
    var _;
    var cond;
    var body;
    var Body;
    var f;
    var i;
    var cond;
    var bstmts;
    var v;
    var cond;
    var bstmts;
    var v;
    var v;
    var $7;
    var $6;

    label3:
    {
        $7 = pat;

        if ($7 instanceof IdPat) {
            v = $7.value;
            vars.push(v);
            stmts.push(b.expressionStatement(b.assignmentExpression("=", b.identifier(v), expr)));
            $6 = stmts;
            break label3;
        }

        if ($7 instanceof NumPat) {
            v = $7.value;
            bstmts = [];
            cond = b.binaryExpression("===", expr, b.literal(v));
            stmts.push(b.ifStatement(cond, b.blockStatement(bstmts)));
            $6 = bstmts;
            break label3;
        }

        if ($7 instanceof StrPat) {
            v = $7.value;
            bstmts = [];
            cond = b.binaryExpression("===", expr, b.literal(v));
            stmts.push(b.ifStatement(cond, b.blockStatement(bstmts)));
            $6 = bstmts;
            break label3;
        }

        if ($7 instanceof TypePat) {
            i = $7.id;
            f = $7.fields;

            Body = function type(stmts) {
                if (this instanceof type) {
                    this.stmts = stmts;
                } else {
                    return new type(stmts);
                }
            };

            body = Body([]);
            cond = b.binaryExpression("instanceof", expr, b.identifier(i));
            stmts.push(b.ifStatement(cond, b.blockStatement(body.stmts)));

            f.forEach(function(field) {
                return body.stmts = translatePat(
                    vars,
                    body.stmts,
                    b.memberExpression(expr, b.identifier(field.key)),
                    field.pat
                );
            });

            $6 = body.stmts;
            break label3;
        }

        _ = $7;
        $6 = "Unknown pattern";
        break label3;
    }

    return $6;
};

fs = require("fs");

Options = function type(encoding) {
    if (this instanceof type) {
        this.encoding = encoding;
    } else {
        return new type(encoding);
    }
};

options = Options("utf-8");
input = fs.readFileSync(process.argv.slice(2).shift(), options);
ast = p.parse(input);
output = translate(ast);
console.log(output);
