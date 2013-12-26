import std.stdio;
import ctini.ctini;

import pegged.grammar;


void main()
{
    writeln("Regenerate grammar module? (y/n)");
    auto answer = getchar();
    if(answer == 'y') {
        writeln("Regenerating grammar");
        asModule("ctini.inigrammar", "source/ctini/inigrammar", import("INI.peg"));
    } else {
        writeln("Not regenereating grammar");
    }

}
unittest {
    import std.string;

    enum config = IniConfig!"test/testconfig.ini";

    enum s = config.Section.stringValue;

    with(config.Section) {
        assert(stringValue == "string",
                "Expected stringValue = \"string\", got \"%s\"".format(stringValue));
        assert(intValue == 3,
                "Expected intValue = 3, got %s".format(intValue));
        assert(floatValue == 123.45f,
                "Expected floatValue = 123.45, got %s".format(floatValue));
        with(Subsection) {
            assert(boolValue == false,
                "Expected boolValue = false, got %s".format(boolValue));
            assert(boolValue2 == true,
                "Expected boolValue2 = true, got %s".format(boolValue2));
        }
    }

}
