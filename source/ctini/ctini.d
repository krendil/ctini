module ctini.ctini;

import std.algorithm;
import std.array;
import std.conv;
import std.format;
import std.range;
import std.string;
import std.traits;
import std.typetuple;

import ctini.inigrammar;

debug import std.stdio;

public import std.typecons : Tuple;

public template IniConfig(string iniFile) {
    enum IniConfig = mixin(IniConfigImpl(import(iniFile)));
}

private:

struct Section {
    string name;
    string id;
    Section* parent;
    Section[] subsections;
    Setting[] settings;

    /**
     * Return a human-readable representation of the section,
     * that looks similar to the ini file, but with types
     * and _ instead of . in the section name
     */
    public string toString() const{
        auto sb = appender!string();

        sb ~= "[%s]\n".format(id);
        sb ~= settings
            .map!( s => s.toString() )
            .join("\n");

        return sb.data;
    }

    /**
     * Return the Tuple!()() declaration as a string that,
     * when mixed-in, will return a Tuple of this section
     */
    string getDeclaration() const {
        auto sb = appender!string();

        sb ~= getTypeName();

        sb ~= "(";
        //Add functin args, list of values
        sb ~= chain(
                settings.map!(
                    s => s.value
                ),
                subsections.map!(
                    ss => ss.getDeclaration()
                )
            ).join(", ");
        sb ~= ")";

        return sb.data();
    }

    /**
     * Returns the D type name of the section,
     * This is an instantiation of Tuple!()
     */
    string getTypeName() const {
        auto sb = appender!string();
        sb ~= ("Tuple!(");

        //Add template args, type followed by name
        sb ~= chain(
                settings.map!(
                    s => format("%s, \"%s\"", s.type, s.name )
                ),
                subsections.map!(
                    ss => format("%s, \"%s\"", ss.getTypeName(), ss.name)
                )
            ).join(", ");
        sb ~= ")";

        return sb.data();
    }
}

/**
 * Represents a key-value pair from the ini
 */
struct Setting {
    string name;
    string type;
    string value;

    public string toString() const {
        return format("%s %s = %s", type, name, value);
    }
}

/**
 * The CTFE function that actually parses the ini file and returns
 * a string,that when mixed-in, will produce a config tuple
 */
string IniConfigImpl(string iniText) {

    auto parsed = IniGrammar.Config(iniText);

    parsed = IniGrammar.decimateTree(parsed);
    if(!parsed.successful) {
        assert(false, "Syntax Error");
    }

    Section[string] sections;

    parsed.children
        .map!( pt =>
                Section(
                    pt.children[0].matches[$-1],
                    pt.children[0].getSectionId,
                    pt.children[0].getSectionParentName in sections,
                    [],
                    getSettings(pt)
                )
             )
        .apply( (Section sec) {
                sections[sec.id] = sec;
                if(sec.parent) {
                sec.parent.subsections ~= sec;
            }
        });

    //Create the Tuple!()() decalaraction
    auto sb = appender!string();

    sb ~= "Tuple!(";
    //Template args -- type, "name" pairs
    sb ~= sections.values
        .filter!( sec => sec.parent is null )
        .map!( sec => format("%s, \"%s\"", sec.getTypeName(), sec.name) )
        .join(", ");

    sb ~= ")(";
    //Constructor args -- values (Tuple!()() declarations themselves)
    sb ~= sections.values
        .filter!( sec => sec.parent is null )
        .map!( sec => sec.getDeclaration() )
        .join(", ");
    sb ~= ")";

    return sb.data();

}


/**
  * Examines a IniGrammar.Section ParseTree, and creates an array of
  * Settings based off the child nodes.
  */
Setting[] getSettings(PT)(PT pt)
in {
    assert( pt.name == "IniGrammar.Section", "Expected Section parsetree, got %s".format(pt.name) );
} body {
    return pt.children
        .filter!( t => t.name == "IniGrammar.Setting" )
        .map!( t => 
                Setting(
                    t.matches[0],
                    t.children[1].getSettingType,
                    t.children[1].matches[0]
                    ))
        .array();
}

/**
  * Returns the internal section id of a given IniGrammar.Section ParseTree
  */
string getSectionId(PT)(PT pt) {
    return pt.matches.join("_").to!string;
}

/**
 * Returns the internal section id of the parent section of a given
 * IniGrammar.Section ParseTree.
 */
string getSectionParentName(PT)(PT pt) {
    return pt.matches[0..$-1].join("_").to!string;
}

/**
 * Returns the D type (as a string) of the setting, given the corresponding
 * IniGrammar.Setting ParseTree
 */
string getSettingType(PT)(PT pt) {
    switch(pt.children[0].name) {
        case "IniGrammar.String":
            return "string";
        case "IniGrammar.Integer":
            return "int";
        case "IniGrammar.Float":
            return "float";
        case "IniGrammar.Bool":
            return "bool";
        default:
            return "auto";
    }
}

/**
 * Eagerly calls the given function for every element of the range
 */
auto apply(R, F)(R range, F fun)
    if(isIterable!R && isCallable!(F) && is(TypeTuple!(ForeachType!R) : ParameterTypeTuple!F) )
{
    foreach( e; range ) {
        fun(e);
    }
}

