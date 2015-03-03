// COMP2010
// Group 10
// Coursework 1

// Version 0.5 - Synchronizing files


/* NEEDED FOR PARSER INTERFACING */
//import java_cup.runtime.*;

%%

//Generated class will be called Lexer.java.
%class Lexer

//Use unicode.
%unicode

//Turns on CUP compatability.
//%cup

//Allows accessing of line and column values of current token.
%line
%column

//Used when not interfacing with CUP.
%standalone

/* USED FOR GENERATING SYMBOLS USED BY THE PARSER */

%{
    StringBuilder string = new StringBuilder();

	//private Symbol symbol(int type) {
	//	return new Symbol(type, yyline, yycolumn);
	//}

	//private Symbol symbol(int type, Object value) {
	//	return new Symbol(type, yyline, yycolumn, value);
	//}
%}


/* REGULAR EXPRESSIONS */
LineTerminator     = \r|\n|\r\n
WhiteSpace         = {LineTerminator} | [ \t\f]

Integer            = 0 | [1-9][0-9]*								// Added -* here to match, e.g. ----9
Float              = (0| [1-9][0-9]*)("."[0-9]+)				        //TODO - add "f" ending for float?
Rational           = [1-9]* " "* "/" " "* [1-9]* | [1-9]* "_" [1-9]* "/" [1-9]* | 0 | [1-9][0-9]*
BooleanConstant    = "T" | "F"
Character          = "'" [A-Z] "'" | "'" [a-z] "'" | '0' | "'" [+-]?[1-9][0-9]* "'"

Identifier         = [:jletter:] [:jletterdigit:]*
InputCharacter     = [^\r\n]

TraditionalComment = "/#" [^#]+ "#/" | "/#" "#"+ "/"
EndOfLineComment   = "#" {InputCharacter}* {LineTerminator}?
Comment            = {TraditionalComment} | {EndOfLineComment}

Dictionary         = "dict"
Sequence           = "seq"
StringCont         = [^\r\n\"\\]

//A state for handling sequences?
%state SEQ

//State for handling dictionaries
%state DICT

%state DICTSEQ

%state SEQSTRING

//State for handling strings (seq<char>)
%state STRING, TDEF, FDEF

%%


/* LEXICAL RULES */

/* KEYWORDS */
"char"    { System.out.print("CHAR ");     }
"bool"    { System.out.print("BOOL ");     }
"int"     { System.out.print("INT ");      }
"rat"     { System.out.print("RAT ");      }
"float"   { System.out.print("FLOAT ");    }
"top"     { System.out.print("TOP ");      }
<YYINITIAL> "print"   { System.out.print("PRINT ");    }
<YYINITIAL> "alias"   { System.out.print("ALIAS ");    }
<YYINITIAL> "fdef"    { System.out.print("FUNCTION "); }
<YYINITIAL> "tdef"    { System.out.print("TYPEDEF ");  }
<YYINITIAL> "main"    { System.out.print("MAIN ");     }


/* CONTROL FLOW */
<YYINITIAL> "if"      { System.out.print("IF ");     }
<YYINITIAL> "then"    { System.out.print("THEN ");   }
<YYINITIAL> "else"    { System.out.print("ELSE ");   }
<YYINITIAL> "fi"      { System.out.print("FI\n");    }
<YYINITIAL> "while"   { System.out.print("WHILE ");  }
<YYINITIAL> "do"      { System.out.print("DO ");     }
<YYINITIAL> "od"      { System.out.print("OD\n");    }
<YYINITIAL> "forall"  { System.out.print("FORALL "); }
<YYINITIAL> "in"      { System.out.print("IN ");     }
<YYINITIAL> "return"  { System.out.print("RETURN "); }

//Overides the colon's and semi colon's normal meaning of 
//"TYPE" when in the DICT or SEQstate.
<DICTSEQ> ":" { System.out.print("MAPSTO ");                      }
<DICTSEQ> ";" { System.out.print("SEMI\n"); yybegin(YYINITIAL);   }
<DICTSEQ> ")" { System.out.print("RPAREN " ); yybegin(YYINITIAL); }
<SEQ> ";"  { System.out.print("SEMI\n"); yybegin(YYINITIAL); }

/* SEPARATORS - can be matched in any state. */
"{" { System.out.print("LBRACE ");   }
"}" { System.out.print("RBRACE ");   }
"[" { System.out.print("LBRACKET "); }
"]" { System.out.print("RBRACKET "); }
":"	{ System.out.print("TYPE ");     }
"(" { System.out.print("LPAREN ");   }
")" { System.out.print("RPAREN ");   }
"," { System.out.print("COMMA ");  }

/* OPERATORS */
":="  { System.out.print("ASSIGN ");  }
"::"  { System.out.print("CONCAT ");  }
"/"   { System.out.print("DIVIDE "); }
"*"   { System.out.print("TIMES ");  }
"-"   { System.out.print("MINUS ");  }
"+"   { System.out.print("PLUS ");   }
"^"   { System.out.print("POW ");    }

/* HANDLING WHITESPACE AND COMMENTS - apply to any state. */
{WhiteSpace} { /* IGNORE WHITESPACE */ }
{Comment}    { /* IGNORE COMMENTS */   }


<YYINITIAL> {

	/* OPERATORS - Probably could be declared outside this state - 
	 * potentially something to look at. */
	"="   { System.out.print("EQ ");      }
	"!="  { System.out.print("NOTEQ");    }
	"<"   { System.out.print("LTHAN ");   }
	"<="  { System.out.print("LTEQ ");    }
	">"   { System.out.print("GTHAN ");   }
	">="  { System.out.print("GTEQ");     }
	"&&"  { System.out.print("AND ");     }
	"||"  { System.out.print("OR ");      }
	"!"   { System.out.print("NOT ");     }
	"=>"  { System.out.print("IMPLIES "); }
	"."   { System.out.print("DOT ");     }

	//This particular separator is not state independant.
	";"   { System.out.print("SEMI\n");    }

	"len" { System.out.print("LEN ");     }

	/* String literal */
	\"    { yybegin(STRING); string.setLength(0); }

	/* Deal with Dictionaries */
	{Dictionary}             { System.out.print("DICT "); yybegin(DICTSEQ); }

	/* Deal with Sequences */
	{Sequence}               { System.out.print("SEQ "); yybegin(DICTSEQ); }

	/* Deal with individual type inputs */
	{BooleanConstant}        { System.out.print("BOOLCONST(" + yytext() + ") ");   }

	{Character}              { System.out.print("CHAR(" + yytext() + ") "); }

	//Use this when actually returning Integers.
	//return symbol(sym.NUM, new Integer(yytext()));
	{Integer}                { System.out.print("NUM(" + yytext() + ") "); }

	{Float}                  { System.out.print("NUM(" + yytext() + ") "); }

	//Cannot handle rationals - just prints whitespace for some reason.
	{Rational}             { System.out.print("NUM(" + yytext() + ") "); }

	//Use this when actually returning an identifier. 
	//return symbol(sym.ID, new Integer(1));
	{Identifier}             { System.out.print("ID(" + yytext() + ") "); }
}

<STRING> {

							//yybegin(YYINITIAL); return symbol(SEQ<CHAR>, string.toString());
    \"                       { yybegin(YYINITIAL); System.out.print(string.toString() + " "); } //Maybe return SEQ<char> rather than the string itself.

	{StringCont}+            { string.append(yytext()); }

	"\\b"                    { string.append( '\b' ); }
    "\\t"                    { string.append( '\t' ); }
    "\\n"                    { string.append( '\n' ); }
    "\\f"                    { string.append( '\f' ); }
    "\\r"                    { string.append( '\r' ); }
    "\\\""                   { string.append( '\"' ); }
    "\\'"                    { string.append( '\'' ); }
    "\\\\"                   { string.append( '\\' ); }
}

<SEQSTRING> {

							//yybegin(YYINITIAL); return symbol(SEQ<CHAR>, string.toString());
    \"                       { yybegin(DICTSEQ); System.out.print(string.toString() + " "); } //Maybe return SEQ<char> rather than the string itself.

	{StringCont}+            { string.append(yytext()); }

	"\\b"                    { string.append( '\b' ); }
    "\\t"                    { string.append( '\t' ); }
    "\\n"                    { string.append( '\n' ); }
    "\\f"                    { string.append( '\f' ); }
    "\\r"                    { string.append( '\r' ); }
    "\\\""                   { string.append( '\"' ); }
    "\\'"                    { string.append( '\'' ); }
    "\\\\"                   { string.append( '\\' ); }
}

/* LEXICAL STATE TO HANDLE SEQUENCES */
<DICTSEQ> {

	//Deal with operators. Assignment may be ableindependant of any state.
	"<"               { System.out.print("LANGLE ");   }
	">"               { System.out.print("RANGLE ");   }

	//"rat"             { System.out.print("RAT "); yybegin(SEQRATIONAL); }

	\"                { yybegin(SEQSTRING); string.setLength(0); }

	{Sequence}        { System.out.print("SEQ ");    }

	{Dictionary}      { System.out.print("DICT "); }

	//Handle all possible contents of the sequence.
	{Float}           { System.out.print("NUM(" + yytext() + ") ");               }

	{Rational}        { System.out.print("NUM(" + yytext() + ") ");               }

	{Character}       { System.out.print("CHAR(" + yytext() + ") ");              }

	{Integer}         { System.out.print("NUM(" + yytext() + ") ");               }

    {BooleanConstant} { System.out.print("BOOLCONST(" + yytext() + ") ");         }

    {Identifier}      { System.out.print("ID(" + yytext() + ") ");                }

}

[^]                   { System.out.println("Unrecognised: " + yytext()); }
//[^] {throw new Error("Illegal character <" + yytext() + ">");}


/* TODO:
 * -> How are user-defined types dealt with, and where?
 */