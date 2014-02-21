# CtIni

## Usage

### Compile-time

Simply import `ctini.ctini`, instantiate `IniConfig` with the file name of an INI file,
and assign it to a variable.

Don't forget to set the include path with th -J option for DMD, or the stringImportPaths setting for dub

See the example below for how to access the settings.

### Run-time

Import `ctini.rtini`, and call `iniConfig()` with the filename of an INI file, or `iniConfigFromString()` with
a string containing the INI configuration.

If you attempt to access a setting or section that doesn't exist, or that has the wrong type, an Exception will be thrown.

## Example

INI file:

    [Section]
    ;A comment
    intValue = 3        #Also a comment
    stringValue = "string"
    floatvalue	=123.45 ; <-- flexible whitespace
    [Section.Subsection]
    boolValue = false

D file (compile-time):

    import ctini.ctini;

    enum config = IniConfig!"config.ini";

    void main() {
        //Four data types
        //Everything available at compile time
        static assert(config.Section.intValue == 3);
        static assert(config.Section.stringValue == "string");
        static assert(config.Section.floatValue == 123.45f);
        static assert(config.Section.Subsection.boolValue == false);
    }

D file (run-time):

    import ctini.rtini;

    void main() {
        auto config = iniConfig("config.ini");

        static assert(config.Section.get!int("intValue") == 3);
        static assert(config.Section.get!string("stringValue") == "string");
        static assert(config.Section.get!float("floatValue") == 123.45f);
        static assert(config.Section.Subsection.get!bool("boolValue") == false);
    }
        
## Advanced

If you want more advanced or custom behaviour, import `ctini.common`, and use the `parseSections()`
function, which returns an AA of sections mapped to their id (which is just the fully qualified section
name with `.`s replaced with `_`s).

## Notes

 - Variable and section names should follow D identifier rules, and cannot be D keywords.

 - Every variable must be in a section (there must be a section heading before any variables are set).

 - A section cannot have two variables with the same name, but two different sections can have
   variables with the same name.

 - The final object is a `std.typecons.Tuple`, and can be used accordingly (for compile-time).

 - Running `dub --config=regen` will allow you to regenerate the INI grammar, but this should only be 
   necessary if you decide to edit `include/INI.peg`.

## TODO

 - Settings without sections
 - Validating against user-defined types (with default values)
 - Single quote strings
 - Nicer errors (nb: the errors are somewhat nicer when parsing at runtime)
