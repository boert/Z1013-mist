package init_message_pkg is

    constant core_name    : string := "Z1013.64";
    constant version      : string := "V2018_03";
    constant compile_time : string := "2018-03-08 21:54";
    constant init_message : string := " " & core_name & "  " & version & ", " & compile_time;

end package init_message_pkg;
