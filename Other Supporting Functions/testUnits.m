clc;
clear all;

% This file is capable of testing the units on all .m functions in this
% folder. It will test all of the ones that it is given and alert the user
% if any of the .m files in this folder are not set up to be tested.

global allTests 
allTests = [];
testingExclude = ["testUnits", "getMaterialProperties"];

% Testing Body
% -------------------------------------------------------------------------
inp = { "mDot"       "kg/s"
        "C_d"        "cd/cd"
        "rho"        "kg/m^3"
        "deltaP"     "Pa"
        "N_orifices" "cd/cd"
        };
crit = {"A"          "m^2"
        "d"          "m"
        "Q"          "m^3/s"
        "v"          "m/s"
        };
evaluateUnits('getFlow', inp, crit)

inp = { "A"          "m^2"
        "C_d"        "cd/cd"
        "rho"        "kg/m^3"
        "deltaP"     "Pa"
        "N_orifices" "cd/cd"
        };
crit = {"mDot"       "kg/s"
        "Q"          "m^3/s"
        "v"          "m/s"
        };
evaluateUnits("getFlow", inp, crit);

inp = { "d"          "m"
        "t"          "m"
        "F"          "N"
        "n"          "cd/cd"
        };
crit = {"bearingStress" "Pa"
        "shearStress"   "Pa"
        };
evaluateUnits("getBoltShearStress", inp, crit);

inp = {"dragCoefficient" "cd/cd"
        "diameter"        "m"
        "startAltitude"   "m"
        "isp"             "s"
        "ispDecay"        "s/s"
        "flightAngle"     "deg"
        "railLength"      "m"
        "railButtonDist"  "m"
        "m_leftover"      "kg"
        "dt"              "s"
        "thrust"          "N"
        "massFraction"    "cd/cd"
        "propMass"        "kg"
        "thrustDecay"     "N/s"
        "minTWR"          "cd/cd"
        };
crit = {"delta_h"         "m"
        "t_burn"          "s"
        "v_max"           "m/s"
        "v_rail"          "m/s"
        "a_max"           "m/s^2"
        "de_max"          "m/s^2"
        "D_max"           "N"
        "h_max"           "m"
        "l"               "m"
        "t_apogee"        "s"
        "initialTWR"      "cd/cd"
        };
evaluateUnits("getAltitude", inp, crit);



% Test to ensure all files were checked
% -------------------------------------------------------------------------
files = split(ls);

for index = 1:length(files)
    [a,b] = strtok(files{index},'.');

    if b == ".m"
        if any(allTests == a)
            fprintf('Test for %s passed.\n', files{index});
        elseif all(testingExclude ~= a)
            warning('off', 'backtrace');
            warning('No test found for %s.\n', files{index});
        end
    end
end

% Local functions
% -------------------------------------------------------------------------

function evaluateUnits(func, inp, crit)
    global allTests;
    allTests = horzcat(allTests, func);

    for x = transpose(inp)
        condInp.(x{1}) = str2symunit(x{2})*.1;
    end
    
    outp = feval(func, condInp);

    for x = transpose(crit)
        c = checkUnits(outp.(x{1}) == str2symunit(x{2}), "Compatible");
        if ~c
            disp(func);
            disp(outp.(x{1}));
            disp(x{2});
            error('Units are not compatible')
        end
    end
end