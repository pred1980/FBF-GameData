library FieldOfView
//*********************************************************************
//*  =================================
//*  FieldOfView 1.0.3   (by MoCo)  
//*  =================================
//*
//*  This library provides 2 functions:
//*
//*    - IsUnitInSightOfUnit(unit observer, unit target, real fieldOfView)
//*        Checks if unit 'target' is within the field of view cone of unit 'observer'
//*      
//*    - IsUnitBehindUnit(unit unitToCheck, unit target, real fieldOfView)
//*        Checks if unit 'unitToCheck' is behind unit 'target' within fieldOfView
//*
//* 
//*  Setup:
//*  ======
//*  Copy this library to your map.
//*
//*
//*  Usage:
//*  ======
//*  Use the parameter fieldOfView to set the field of view (FoV) that should be used for the detection function.
//*  The parameter needs to be set to half of the total field of view you want the unit to use.
//*  For example, if you want a unit to have a total field of view cone of 180°, you need to use a parameter value of 90
//*  
//*  Note that the natural human field of view is about 135°, so you could use a value of 67.5 here.
//*  
//*  See the FovTester script for practical examples on how to use the functions.
//*
//*  
//*  Change log:
//*  ===========
//*  2015-04-25: The fieldOfView parameter usage has made more intuitive
//*  2015-01-21: The external Math library is no longer needed
//*  2015-01-10: The fieldOfView parameter now is an argument and now longer a global constant
//*   
//********************************************************************

function IsUnitInSightOfUnit takes unit observer, unit target, real fov returns boolean
    local real face = GetUnitFacing(observer)
    local real angle = bj_RADTODEG*Atan2(GetUnitY(target)-GetUnitY(observer), GetUnitX(target)-GetUnitX(observer))
    return not(RAbsBJ(face-angle) > fov and RAbsBJ(face-angle-360) > fov)
endfunction

function IsUnitBehindUnit takes unit attacker, unit target, real fov returns boolean
    local real face = GetUnitFacing(target)
    local real angle = bj_RADTODEG*Atan2(GetUnitY(target)-GetUnitY(attacker),GetUnitX(target)-GetUnitX(attacker))
    return not(RAbsBJ(face-angle) > fov and RAbsBJ(face-angle-360) > fov)
endfunction

endlibrary
