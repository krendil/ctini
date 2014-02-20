module ctini.common;

import std.algorithm;
import std.array;
import std.conv;
import std.format;
import std.range;
import std.string;
import std.traits;
import std.typetuple;

import ctini.inigrammar;

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
 * a dictionary containing the parsed sections
 */
Section[string] parseSections(string iniText) {

    auto parsed = IniGrammar.Config(iniText);

    parsed = IniGrammar.decimateTree(parsed);
    if(!parsed.successful) {
        //debug writeln(parsed);
        assert(false, "Syntax Error");
    }

    Section[string] sections;

    parsed.children
        .map!( (pt) =>
                Section(
                    pt.children[0].matches[$-1],
                    pt.children[0].getSectionId(),
                    findParent(sections, pt.children[0].matches),
                    [],
                    getSettings(pt)
                )
             )
        .apply( (Section sec) {
                auto placeholder = sec.id in sections;
                if(placeholder !is null) {
                    //The only field we need to copy is subsections,
                    //because the name and id are identical by definition,
                    //placeholders have no fields,
                    //and the placeholder's parent should have been looked up normally
                    sec.subsections = placeholder.subsections;
                }
                sections[sec.id] = sec;
                if(sec.parent) {
                    sec.parent.subsections ~= sec;
            }
        });

    return sections;
}

/**
  * Returns the section's parent section, creating it if necessary,
  * based on the 'lineage', that is, the fully qualified name of the original section.
  *
  * e.g., given ["A","B","C"], findParent will return a pointer to the Section called A.B
  *
  * If no such section exists, it is created.
  * If lineage.length == 1 (there is no parent section), null is returned
  */
Section* findParent(Section[string] sections, string[] lineage)
in {
    assert( lineage.length >= 1 );
} body {

    if(lineage.length == 1) {
        return null;
    }

    Section* parent;

    string parName = lineage[0..$-1].join("_").to!string();
    parent = parName in sections;

    //No existing parent, we'll have to make one
    if(parent is null) {
        auto newParent = Section(
                lineage[$-2],
                parName,
                findParent(sections, lineage[0..$-1]),
                [], //No descendents yet
                []  //No settings
                );
        sections[parName] = newParent;
        parent = parName in sections;
    }

    return parent;
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

