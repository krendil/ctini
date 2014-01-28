/++
This module was automatically generated from the following grammar:

IniGrammar:
    Config      <-  (Section / EOL)*

    Section     <-  SectionHead (Setting / EOL)+
        SectionHead <-  :'[' Identifier ( :'.' Identifier )* :']' EOL

    Setting     <   Identifier Spacing :'=' Spacing Value EOL

    Identifier  <~  identifier #[a-zA-Z_] [a-zA-Z_0-9]*
    Value       <-  (String / Float / Integer / Bool)
        String      <~  DoubleStr #/ SingleStr
            DoubleStr   <~  ["] (!(Newline / ["]) .)* ["]
       #     SingleStr   <~  :['] (!(Newline / [']) .)* :[']
        Float       <~  '-'? [0-9]* [.] [0-9]*
        Integer     <~  '-'? [0-9]+
        Bool        <-  ;"true" / ;"false"

    Spacing     <: [ \t]*
    EOL         <: Spacing* (Comment / Newline / EOF)
        Newline     <: '\r'? '\n'
        Comment     <~ [;#] (!Newline .)* Newline
        EOF         <: !.


+/
module ctini.inigrammar;

public import pegged.peg;
import std.algorithm: startsWith;
import std.functional: toDelegate;

struct GenericIniGrammar(TParseTree)
{
    import pegged.dynamic.grammar;
    struct IniGrammar
    {
    enum name = "IniGrammar";
    static ParseTree delegate(ParseTree)[string] before;
    static ParseTree delegate(ParseTree)[string] after;
    static ParseTree delegate(ParseTree)[string] rules;

    static this()
    {
        rules["Config"] = toDelegate(&IniGrammar.Config);
        rules["Section"] = toDelegate(&IniGrammar.Section);
        rules["SectionHead"] = toDelegate(&IniGrammar.SectionHead);
        rules["Setting"] = toDelegate(&IniGrammar.Setting);
        rules["Identifier"] = toDelegate(&IniGrammar.Identifier);
        rules["Value"] = toDelegate(&IniGrammar.Value);
        rules["String"] = toDelegate(&IniGrammar.String);
        rules["DoubleStr"] = toDelegate(&IniGrammar.DoubleStr);
        rules["Float"] = toDelegate(&IniGrammar.Float);
        rules["Integer"] = toDelegate(&IniGrammar.Integer);
        rules["Bool"] = toDelegate(&IniGrammar.Bool);
        rules["Spacing"] = toDelegate(&IniGrammar.Spacing);
   }

    template hooked(alias r, string name)
    {
        static ParseTree hooked(ParseTree p)
        {
            ParseTree result;

            if (name in before)
            {
                result = before[name](p);
                if (result.successful)
                    return result;
            }

            result = r(p);
            if (result.successful || name !in after)
                return result;

            result = after[name](p);
            return result;
        }

        static ParseTree hooked(string input)
        {
            return hooked!(r, name)(ParseTree("",false,[],input));
        }
    }

    static void addRuleBefore(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar name
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(ruleName,rule; dg.rules)
            if (ruleName != "Spacing") // Keep the local Spacing rule, do not overwrite it
                rules[ruleName] = rule;
        before[parentRule] = rules[dg.startingRule];
    }

    static void addRuleAfter(string parentRule, string ruleSyntax)
    {
        // enum name is the current grammar named
        DynamicGrammar dg = pegged.dynamic.grammar.grammar(name ~ ": " ~ ruleSyntax, rules);
        foreach(name,rule; dg.rules)
        {
            if (name != "Spacing")
                rules[name] = rule;
        }
        after[parentRule] = rules[dg.startingRule];
    }

    static bool isRule(string s)
    {
        return s.startsWith("IniGrammar.");
    }
    import std.typecons:Tuple, tuple;
    static TParseTree[Tuple!(string, size_t)] memo;
    mixin decimateTree;
    static TParseTree Config(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.zeroOrMore!(pegged.peg.or!(Section, EOL)), "IniGrammar.Config")(p);
        }
        else
        {
            if(auto m = tuple(`Config`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.zeroOrMore!(pegged.peg.or!(Section, EOL)), "IniGrammar.Config"), "Config")(p);
                memo[tuple(`Config`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Config(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.zeroOrMore!(pegged.peg.or!(Section, EOL)), "IniGrammar.Config")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.zeroOrMore!(pegged.peg.or!(Section, EOL)), "IniGrammar.Config"), "Config")(TParseTree("", false,[], s));
        }
    }
    static string Config(GetName g)
    {
        return "IniGrammar.Config";
    }

    static TParseTree Section(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(SectionHead, pegged.peg.oneOrMore!(pegged.peg.or!(Setting, EOL))), "IniGrammar.Section")(p);
        }
        else
        {
            if(auto m = tuple(`Section`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(SectionHead, pegged.peg.oneOrMore!(pegged.peg.or!(Setting, EOL))), "IniGrammar.Section"), "Section")(p);
                memo[tuple(`Section`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Section(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(SectionHead, pegged.peg.oneOrMore!(pegged.peg.or!(Setting, EOL))), "IniGrammar.Section")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.and!(SectionHead, pegged.peg.oneOrMore!(pegged.peg.or!(Setting, EOL))), "IniGrammar.Section"), "Section")(TParseTree("", false,[], s));
        }
    }
    static string Section(GetName g)
    {
        return "IniGrammar.Section";
    }

    static TParseTree SectionHead(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("[")), Identifier, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), Identifier)), pegged.peg.discard!(pegged.peg.literal!("]")), EOL), "IniGrammar.SectionHead")(p);
        }
        else
        {
            if(auto m = tuple(`SectionHead`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("[")), Identifier, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), Identifier)), pegged.peg.discard!(pegged.peg.literal!("]")), EOL), "IniGrammar.SectionHead"), "SectionHead")(p);
                memo[tuple(`SectionHead`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree SectionHead(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("[")), Identifier, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), Identifier)), pegged.peg.discard!(pegged.peg.literal!("]")), EOL), "IniGrammar.SectionHead")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!("[")), Identifier, pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.discard!(pegged.peg.literal!(".")), Identifier)), pegged.peg.discard!(pegged.peg.literal!("]")), EOL), "IniGrammar.SectionHead"), "SectionHead")(TParseTree("", false,[], s));
        }
    }
    static string SectionHead(GetName g)
    {
        return "IniGrammar.SectionHead";
    }

    static TParseTree Setting(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.wrapAround!(Spacing, Spacing, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing)), pegged.peg.wrapAround!(Spacing, Spacing, Spacing), pegged.peg.wrapAround!(Spacing, Value, Spacing), pegged.peg.wrapAround!(Spacing, EOL, Spacing)), "IniGrammar.Setting")(p);
        }
        else
        {
            if(auto m = tuple(`Setting`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.wrapAround!(Spacing, Spacing, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing)), pegged.peg.wrapAround!(Spacing, Spacing, Spacing), pegged.peg.wrapAround!(Spacing, Value, Spacing), pegged.peg.wrapAround!(Spacing, EOL, Spacing)), "IniGrammar.Setting"), "Setting")(p);
                memo[tuple(`Setting`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Setting(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.wrapAround!(Spacing, Spacing, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing)), pegged.peg.wrapAround!(Spacing, Spacing, Spacing), pegged.peg.wrapAround!(Spacing, Value, Spacing), pegged.peg.wrapAround!(Spacing, EOL, Spacing)), "IniGrammar.Setting")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.and!(pegged.peg.wrapAround!(Spacing, Identifier, Spacing), pegged.peg.wrapAround!(Spacing, Spacing, Spacing), pegged.peg.discard!(pegged.peg.wrapAround!(Spacing, pegged.peg.literal!("="), Spacing)), pegged.peg.wrapAround!(Spacing, Spacing, Spacing), pegged.peg.wrapAround!(Spacing, Value, Spacing), pegged.peg.wrapAround!(Spacing, EOL, Spacing)), "IniGrammar.Setting"), "Setting")(TParseTree("", false,[], s));
        }
    }
    static string Setting(GetName g)
    {
        return "IniGrammar.Setting";
    }

    static TParseTree Identifier(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(identifier), "IniGrammar.Identifier")(p);
        }
        else
        {
            if(auto m = tuple(`Identifier`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(identifier), "IniGrammar.Identifier"), "Identifier")(p);
                memo[tuple(`Identifier`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Identifier(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(identifier), "IniGrammar.Identifier")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(identifier), "IniGrammar.Identifier"), "Identifier")(TParseTree("", false,[], s));
        }
    }
    static string Identifier(GetName g)
    {
        return "IniGrammar.Identifier";
    }

    static TParseTree Value(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(String, Float, Integer, Bool), "IniGrammar.Value")(p);
        }
        else
        {
            if(auto m = tuple(`Value`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(String, Float, Integer, Bool), "IniGrammar.Value"), "Value")(p);
                memo[tuple(`Value`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Value(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(String, Float, Integer, Bool), "IniGrammar.Value")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.or!(String, Float, Integer, Bool), "IniGrammar.Value"), "Value")(TParseTree("", false,[], s));
        }
    }
    static string Value(GetName g)
    {
        return "IniGrammar.Value";
    }

    static TParseTree String(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(DoubleStr), "IniGrammar.String")(p);
        }
        else
        {
            if(auto m = tuple(`String`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(DoubleStr), "IniGrammar.String"), "String")(p);
                memo[tuple(`String`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree String(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(DoubleStr), "IniGrammar.String")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(DoubleStr), "IniGrammar.String"), "String")(TParseTree("", false,[], s));
        }
    }
    static string String(GetName g)
    {
        return "IniGrammar.String";
    }

    static TParseTree DoubleStr(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!(`"`), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.or!(Newline, pegged.peg.literal!(`"`))), pegged.peg.any)), pegged.peg.literal!(`"`))), "IniGrammar.DoubleStr")(p);
        }
        else
        {
            if(auto m = tuple(`DoubleStr`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!(`"`), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.or!(Newline, pegged.peg.literal!(`"`))), pegged.peg.any)), pegged.peg.literal!(`"`))), "IniGrammar.DoubleStr"), "DoubleStr")(p);
                memo[tuple(`DoubleStr`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree DoubleStr(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!(`"`), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.or!(Newline, pegged.peg.literal!(`"`))), pegged.peg.any)), pegged.peg.literal!(`"`))), "IniGrammar.DoubleStr")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.literal!(`"`), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(pegged.peg.or!(Newline, pegged.peg.literal!(`"`))), pegged.peg.any)), pegged.peg.literal!(`"`))), "IniGrammar.DoubleStr"), "DoubleStr")(TParseTree("", false,[], s));
        }
    }
    static string DoubleStr(GetName g)
    {
        return "IniGrammar.DoubleStr";
    }

    static TParseTree Float(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9')), pegged.peg.literal!("."), pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9')))), "IniGrammar.Float")(p);
        }
        else
        {
            if(auto m = tuple(`Float`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9')), pegged.peg.literal!("."), pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9')))), "IniGrammar.Float"), "Float")(p);
                memo[tuple(`Float`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Float(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9')), pegged.peg.literal!("."), pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9')))), "IniGrammar.Float")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9')), pegged.peg.literal!("."), pegged.peg.zeroOrMore!(pegged.peg.charRange!('0', '9')))), "IniGrammar.Float"), "Float")(TParseTree("", false,[], s));
        }
    }
    static string Float(GetName g)
    {
        return "IniGrammar.Float";
    }

    static TParseTree Integer(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9')))), "IniGrammar.Integer")(p);
        }
        else
        {
            if(auto m = tuple(`Integer`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9')))), "IniGrammar.Integer"), "Integer")(p);
                memo[tuple(`Integer`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Integer(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9')))), "IniGrammar.Integer")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("-")), pegged.peg.oneOrMore!(pegged.peg.charRange!('0', '9')))), "IniGrammar.Integer"), "Integer")(TParseTree("", false,[], s));
        }
    }
    static string Integer(GetName g)
    {
        return "IniGrammar.Integer";
    }

    static TParseTree Bool(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.drop!(pegged.peg.literal!("true")), pegged.peg.drop!(pegged.peg.literal!("false"))), "IniGrammar.Bool")(p);
        }
        else
        {
            if(auto m = tuple(`Bool`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.drop!(pegged.peg.literal!("true")), pegged.peg.drop!(pegged.peg.literal!("false"))), "IniGrammar.Bool"), "Bool")(p);
                memo[tuple(`Bool`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Bool(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.or!(pegged.peg.drop!(pegged.peg.literal!("true")), pegged.peg.drop!(pegged.peg.literal!("false"))), "IniGrammar.Bool")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.or!(pegged.peg.drop!(pegged.peg.literal!("true")), pegged.peg.drop!(pegged.peg.literal!("false"))), "IniGrammar.Bool"), "Bool")(TParseTree("", false,[], s));
        }
    }
    static string Bool(GetName g)
    {
        return "IniGrammar.Bool";
    }

    static TParseTree Spacing(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.discard!(pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.literal!(" "), pegged.peg.literal!("\t")))), "IniGrammar.Spacing")(p);
        }
        else
        {
            if(auto m = tuple(`Spacing`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.discard!(pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.literal!(" "), pegged.peg.literal!("\t")))), "IniGrammar.Spacing"), "Spacing")(p);
                memo[tuple(`Spacing`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Spacing(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.discard!(pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.literal!(" "), pegged.peg.literal!("\t")))), "IniGrammar.Spacing")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.discard!(pegged.peg.zeroOrMore!(pegged.peg.or!(pegged.peg.literal!(" "), pegged.peg.literal!("\t")))), "IniGrammar.Spacing"), "Spacing")(TParseTree("", false,[], s));
        }
    }
    static string Spacing(GetName g)
    {
        return "IniGrammar.Spacing";
    }

    static TParseTree EOL(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.discard!(pegged.peg.and!(pegged.peg.zeroOrMore!(Spacing), pegged.peg.or!(Comment, Newline, EOF))), "IniGrammar.EOL")(p);
        }
        else
        {
            if(auto m = tuple(`EOL`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.discard!(pegged.peg.and!(pegged.peg.zeroOrMore!(Spacing), pegged.peg.or!(Comment, Newline, EOF))), "IniGrammar.EOL"), "EOL")(p);
                memo[tuple(`EOL`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree EOL(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.discard!(pegged.peg.and!(pegged.peg.zeroOrMore!(Spacing), pegged.peg.or!(Comment, Newline, EOF))), "IniGrammar.EOL")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.discard!(pegged.peg.and!(pegged.peg.zeroOrMore!(Spacing), pegged.peg.or!(Comment, Newline, EOF))), "IniGrammar.EOL"), "EOL")(TParseTree("", false,[], s));
        }
    }
    static string EOL(GetName g)
    {
        return "IniGrammar.EOL";
    }

    static TParseTree Newline(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.discard!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("\r")), pegged.peg.literal!("\n"))), "IniGrammar.Newline")(p);
        }
        else
        {
            if(auto m = tuple(`Newline`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.discard!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("\r")), pegged.peg.literal!("\n"))), "IniGrammar.Newline"), "Newline")(p);
                memo[tuple(`Newline`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Newline(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.discard!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("\r")), pegged.peg.literal!("\n"))), "IniGrammar.Newline")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.discard!(pegged.peg.and!(pegged.peg.option!(pegged.peg.literal!("\r")), pegged.peg.literal!("\n"))), "IniGrammar.Newline"), "Newline")(TParseTree("", false,[], s));
        }
    }
    static string Newline(GetName g)
    {
        return "IniGrammar.Newline";
    }

    static TParseTree Comment(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.or!(pegged.peg.literal!(";"), pegged.peg.literal!("#")), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(Newline), pegged.peg.any)), Newline)), "IniGrammar.Comment")(p);
        }
        else
        {
            if(auto m = tuple(`Comment`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.or!(pegged.peg.literal!(";"), pegged.peg.literal!("#")), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(Newline), pegged.peg.any)), Newline)), "IniGrammar.Comment"), "Comment")(p);
                memo[tuple(`Comment`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree Comment(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.or!(pegged.peg.literal!(";"), pegged.peg.literal!("#")), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(Newline), pegged.peg.any)), Newline)), "IniGrammar.Comment")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.fuse!(pegged.peg.and!(pegged.peg.or!(pegged.peg.literal!(";"), pegged.peg.literal!("#")), pegged.peg.zeroOrMore!(pegged.peg.and!(pegged.peg.negLookahead!(Newline), pegged.peg.any)), Newline)), "IniGrammar.Comment"), "Comment")(TParseTree("", false,[], s));
        }
    }
    static string Comment(GetName g)
    {
        return "IniGrammar.Comment";
    }

    static TParseTree EOF(TParseTree p)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.discard!(pegged.peg.negLookahead!(pegged.peg.any)), "IniGrammar.EOF")(p);
        }
        else
        {
            if(auto m = tuple(`EOF`,p.end) in memo)
                return *m;
            else
            {
                TParseTree result = hooked!(pegged.peg.defined!(pegged.peg.discard!(pegged.peg.negLookahead!(pegged.peg.any)), "IniGrammar.EOF"), "EOF")(p);
                memo[tuple(`EOF`,p.end)] = result;
                return result;
            }
        }
    }

    static TParseTree EOF(string s)
    {
        if(__ctfe)
        {
            return         pegged.peg.defined!(pegged.peg.discard!(pegged.peg.negLookahead!(pegged.peg.any)), "IniGrammar.EOF")(TParseTree("", false,[], s));
        }
        else
        {
            memo = null;
            return hooked!(pegged.peg.defined!(pegged.peg.discard!(pegged.peg.negLookahead!(pegged.peg.any)), "IniGrammar.EOF"), "EOF")(TParseTree("", false,[], s));
        }
    }
    static string EOF(GetName g)
    {
        return "IniGrammar.EOF";
    }

    static TParseTree opCall(TParseTree p)
    {
        TParseTree result = decimateTree(Config(p));
        result.children = [result];
        result.name = "IniGrammar";
        return result;
    }

    static TParseTree opCall(string input)
    {
        if(__ctfe)
        {
            return IniGrammar(TParseTree(``, false, [], input, 0, 0));
        }
        else
        {
            memo = null;
            return IniGrammar(TParseTree(``, false, [], input, 0, 0));
        }
    }
    static string opCall(GetName g)
    {
        return "IniGrammar";
    }

    }
}

alias GenericIniGrammar!(ParseTree).IniGrammar IniGrammar;

