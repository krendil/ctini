import std.stdio;
import ctini.ctini;
import ctini.rtini;

import pegged.grammar;


void main()
{
    writeln("Regenerate grammar module? (y/n)");
    auto answer = getchar();
    if(answer == 'y') {
        writeln("Regenerating grammar");
        asModule("ctini.inigrammar", "source/ctini/inigrammar", import("INI.peg"));
    } else {
        writeln("Not regenerating grammar");
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

    auto config2 = IniConfig!"test/blog.ini";

    auto config3 = iniConfig("include/test/testconfig.ini");

    auto sec = config3.opDispatch!"Section"();

    with(config3.Section) {
        auto stringValue = get!string("stringValue");
        assert(stringValue == "string",
                "Expected stringValue = \"string\", got \"%s\"".format(stringValue));
        auto intValue = get!int("intValue");
        assert(intValue == 3,
                "Expected intValue = 3, got %s".format(intValue));
        auto floatValue = get!float("floatValue");
        assert(floatValue == 123.45f,
                "Expected floatValue = 123.45, got %s".format(floatValue));
        with(config3.Section.Subsection) {
            auto boolValue = get!bool("boolValue");
            assert(boolValue == false,
                    "Expected boolValue = false, got %s".format(boolValue));
            auto boolValue2 = get!bool("boolValue2");
            assert(boolValue2 == true,
                    "Expected boolValue2 = true, got %s".format(boolValue2));
        }
    }

    //Magic syntax
    auto stringValue = config3.Section.stringValue!string;
    assert(stringValue == "string",
            "Expected stringValue = \"string\", got \"%s\"".format(stringValue));
    auto intValue = config3.Section.intValue!int;
    assert(intValue == 3,
            "Expected intValue = 3, got %s".format(intValue));
    auto floatValue = config3.Section.floatValue!float;
    assert(floatValue == 123.45f,
            "Expected floatValue = 123.45, got %s".format(floatValue));
    with(config3.Section.Subsection) {
        auto boolValue = config3.Section.Subsection.boolValue!bool;
        assert(boolValue == false,
                "Expected boolValue = false, got %s".format(boolValue));
        auto boolValue2 = config3.Section.Subsection.boolValue2!bool;
        assert(boolValue2 == true,
                "Expected boolValue2 = true, got %s".format(boolValue2));
    }
}
