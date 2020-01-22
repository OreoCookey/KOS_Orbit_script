//FUNCTION BLOCK

// function to ask for permission to use time warp
function get_warp_perm{
    CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
    CLEARSCREEN.


    set allow_timewarp to True.
    set mode_selected to False.

    function change_perm{

        if allow_timewarp = True{
            return False.
        }

        if allow_timewarp = False{
            return True.
        }


    }

    until mode_selected = True{
        CLEARSCREEN.
        print "Use the arrow keys to allow".
        print "The script to use timewarp".
        print "Press the 'Enter' key to submit".
        print " ".
        if allow_timewarp = True{
            set state to "Allowed".
        }

        if allow_timewarp = False{
            set state to "Disabled".
        }

        print "Current settings timewarp: " + state.


        set ch to terminal:input:getchar().

        if ch = terminal:input:DOWNCURSORONE {
            set allow_timewarp to change_perm().
            CLEARSCREEN.
        
        }
        else if ch = terminal:input:UPCURSORONE {
            set allow_timewarp to change_perm().
            CLEARSCREEN.

        }

        else if ch = terminal:input:ENTER {
            CLEARSCREEN.
            print "Sucssessfully recorded your settings".
            print " ".
            print "Please wait 1 seconds".
            wait 1.
            CLEARSCREEN.
            set mode_selected to True.

        }   
    }

    return allow_timewarp.
}

//changes thrust depending on the altitude
function Assend_thrust_control {

    if ship:altitude > 10000 and ship:altitude < 15000{
        set thrust to 0.7.
    }

    if ship:altitude > 15000 and ship:altitude < 30000{
        set thrust to 0.6.
    }
}

//This function enables us to stage multiple times in a row without adding time delays
Function safe_stage{
    wait until stage:ready.
    stage.
}

//some pre-launch set up code
function prelaunch_setup{
    //open the terminal window
    CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
    CLEARSCREEN.
    set warp_allowed to get_warp_perm().
    print "Warp variable is " + warp_allowed.
    
    set thrust to 1.0.

}

//count down
function count_down{
    FROM {local countdown is 10.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1. 
    }

}

//the lift-off function
function liftoff{
    
    lock throttle to thrust.
    safe_stage().
    safe_stage().

    //waiting to clear the launch tower
    wait until SHIP:altitude > 300.
}

//setting the parameters of the flight path
function set_flight_var{
    lock targetPitch to 88.963 - 0.73287 * alt:radar^0.409511.
    set targetDirection to 90.
    lock steering to heading(targetDirection, targetPitch).

    set old_thrust to ship:avaiLablethrUST.
}

//Checking if staging is needed 
function auto_stage{

    //if the old thrust is not set then set it
    if not(defined old_thrust) {
        set old_thrust to ship:avaiLablethrUST.
    }

    //if the ships thrust drops we need to stage
    if ship:availablethrust < (old_thrust - 10) {
        safe_stage().
        wait 1.
        set old_thrust to ship:availablethrust.
    }

}

//actions during a gravity turn
function gravity_turn {

    //untill apoapsis reaches 100km gravity turn is not complete
    until apoapsis > 100000  {

        //checking if staging is needed
        auto_stage(). 

        //changing throttle depending on the altitude
        Assend_thrust_control().

       
    }
}


function AddManeuver {
    ///
}

function creating_maneuver{
    parameter utime, radial, normal, prograde_d.
    global mvn is node(utime, radial, normal, prograde_d).
    AddManeuver(mvn).
    return mvn.
    
}

function get_start_time{
    ///
}

function get_m_thrust{
    ///
}

function is_maneuver_complete{
    ///
}



function excecute_maneuver{
    parameter utime, radial, normal, prograde_d.
    local maneuver is creating_maneuver(utime, radial, normal, prograde_d).
    local start_time is get_start_time(maneuver).
    wait start_time-10.
    lock steering to node:burnvector.
    wait until start_time.
    set thrust to get_m_thrust(maneuver).
    wait until is_maneuver_complete(maneuver).




}

//CODE BLOCK

//excecuting the code
prelaunch_setup().
liftoff().
set_flight_var().
gravity_turn().