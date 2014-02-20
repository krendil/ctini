module ctini.ctini;

import std.algorithm;
import std.array;
import std.range;
import std.string;

import ctini.common;

debug import std.stdio;

public import std.typecons : Tuple;

public template IniConfig(string iniFile) {
    enum IniConfig = mixin(parseSections(import(iniFile)).makeTuples());
}


private:


/**
 * Return the Tuple!()() declaration as a string that,
 * when mixed-in, will return a Tuple of this section
 */
string getDeclaration(const Section section) {
    auto sb = appender!string();

    sb ~= section.getTypeName();

    sb ~= "(";
    //Add functin args, list of values
    sb ~= chain(
            section.settings.map!(
                s => s.value
                ),
            section.subsections.map!(
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
string getTypeName(const Section section) {
    auto sb = appender!string();
    sb ~= ("Tuple!(");

    //Add template args, type followed by name
    sb ~= chain(
            section.settings.map!(
                s => format("%s, \"%s\"", s.type, s.name )
                ),
            section.subsections.map!(
                ss => format("%s, \"%s\"", ss.getTypeName(), ss.name)
                )
            ).join(", ");
    sb ~= ")";

    return sb.data();
}


string makeTuples(const Section[string] sections) {
    //Create the Tuple!()() declaraction
    auto sb = appender!string();

    /+
    debug {
        foreach( section; sections.values ) {
            writeln(section);
        }
    }+/

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
