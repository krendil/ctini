module ctini.rtini;

import std.array;
import std.algorithm;
import std.conv;
import std.exception;
import std.file;
import std.traits;
import std.typetuple;

import ctini.common;


IniSection iniConfig(string iniFile) {
    return iniConfigFromString(readText(iniFile));
}

IniSection iniConfigFromString(string iniText) {
    return parseSections(iniText).makeVariants();
}

struct IniSection {
    IniSetting[string] children;

    @property
    public IniSection opDispatch(string name)()
    {
        auto subsec = name in children;
        enforce( subsec !is null, "This section has no subsection called "~name);
        enforce( subsec.currentType == IniSetting.SettingType.section, name~" is not a subsection");
        
        return subsec.get!IniSection();
    }

    public T get(T)(string name) 
        if( IniSetting.allowed!T )
    {
        auto set = name in children;
        enforce( set !is null, "This section has no setting called "~name);

        return set.get!T();   
    }
}

/**
 * Quick and dirty limited tagged union, because std.variant can't do recursive definitions
 *
 * Retrieving the correct type is enforced by in contracts, so AssertErrors are thrown
 * if the wrong type is attempted, and who knows what you'll get if you compile in release mode.
 */
struct IniSetting {

    enum SettingType { string_, int_, float_, bool_, section, void_ };

    union SettingValue {
        string string_;
        int int_;
        float float_;
        bool bool_;
        IniSection section;
    };

    SettingType currentType = SettingType.void_;
    SettingValue values;

    static template allowed(T) {
        enum bool allowed = isOneOf!(T, string, int, float, bool, IniSection);
    }

    this(string type, string value) {
        
        switch(type) {
            case "string":
                values.string_ = value[1..$-1]; //Strip off the quote marks
                currentType = SettingType.string_;
                break;

            case "int":
                values.int_ = value.to!int;
                currentType = SettingType.int_;
                break;

            case "float":
                values.float_ = value.to!float;
                currentType = SettingType.float_;
                break;

            case "bool":
                values.bool_ = value.to!bool;
                currentType = SettingType.bool_;
                break;

            default:
                assert(0, "Cannot store type "~type);
        }

    }

    this(IniSection value)
    {
        values.section = value;
        currentType = SettingType.section;
    }

    T get(T : string)()
    in {
        assert(currentType == SettingType.string_,
                "Attempted to access a string, when really there was a "~currentType.to!string);
    } body {
        return values.string_;
    }

    T get(T : int)()
    in {
        assert(currentType == SettingType.int_,
                "Attempted to access an int, when really there was a "~currentType.to!string);
    } body {
        return values.int_;
    }

    T get(T : float)()
    in {
        assert(currentType == SettingType.float_,
                "Attempted to access a float, when really there was a "~currentType.to!string);
    } body {
        return values.float_;
    }

    T get(T : bool)()
    in {
        assert(currentType == SettingType.bool_,
                "Attempted to access a bool, when really there was a "~currentType.to!string);
    } body {
        return values.bool_;
    }

    T get(T : IniSection)()
    in {
        assert(currentType == SettingType.section,
                "Attempted to access an IniSection, when really there was a "~currentType.to!string);
    } body {
        return values.section;
    }

}

private:

IniSection makeVariants(Section[string] sections) {

    IniSection root;

    //Convert and add the top level sections
    sections.values
        .filter!( sec => sec.parent is null )
        .apply!( (sec) => (
                root.children[sec.name] = IniSetting(makeIniSection(sec))
                ));

    return root;
}

IniSection makeIniSection(Section section) {
    IniSection isec;
    
    //Convert and add all the settings into the hashmap
    foreach( set; section.settings ) {

        isec.children[set.name] = IniSetting(set.type, set.value);

    }

    //Now, recursively add all the subsections
    foreach( subsec; section.subsections ) {

        IniSection isubsec = makeIniSection(subsec);

        isec.children[subsec.name] = IniSetting(isubsec);

    }

    return isec;
}

template isOneOf(T, U...) {
    enum bool isOneOf = staticIndexOf!(T, U) >= 0;
}
