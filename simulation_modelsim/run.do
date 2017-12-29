# neues Spiel, neues Glueck (new game, new chance)
# (re)start complete simulation
proc nsng {} {
    restart -f
    set NumericStdNoWarnings  1
    run 0 ps

    set NumericStdNoWarnings  0
    run -all
}


proc r {} {
    nsng
}
                                                                                                                                   
                                                                                                                                   
proc my_debug {} {                                                                                                                 
    global env                                                                                                                     
    foreach key [array names env] {                                                                                                
        puts "$key=$env($key)"                                                                                                     
    }                                                                                                                              
}                                                                                                                                  


proc x {} {                                                                                                                        
    exit -force                                                                                                                    
}                                                                                                                                  



# get env variables
global env
quietly set top $env(top)

if {[file exists wave_$top.do]} {
    puts "INFO: load wave_$top.do"
    do wave_$top.do
} else {
    puts "WARNING: no wave_$top.do found."
    if {[file exists wave.do]} {
        puts "INFO: load wave.do"
        do wave.do
    } else {
        puts "WARNING: no wave.do found."
    }
}

nsng
