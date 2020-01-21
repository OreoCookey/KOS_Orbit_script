//FUNCTION BLOCK

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
    set thrust to 1.0.
    LOCK t to round((SHIP:SENSORS:TEMP - 273.15), 2) .
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
    lock targetPitch to 88.963 - 1.03287 * alt:radar^0.409511.
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

        //degreasing thrust if going fast to not overheat

        PRINT "The temperature is " + t + "C" AT (0,1).
    }
}


//CODE BLOCK

//excecuting the code
prelaunch_setup().
liftoff().
set_flight_var().
gravity_turn().