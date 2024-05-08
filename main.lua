-- main runner clip
os.loadAPI("bkjapi")

print("Welcome to BKJ Lift Controller v0.1")
print("Made with Piss & Love and shit")
print("Checking Safety....")
bkjapi.SafetyCheck()
print("Checking for Floor position...")
parallel.waitForAll(bkjapi.CheckForPosIfNotTryCalib, bkjapi.BusyFlash)
print("Running main loop...")
while true do
    local function AWAITAcceptCabCallsWhileDoor()
        xyz = bkjapi.AcceptCabCallsWhileDoor()
        return
    end
    -- below function is when everything is idling, and we accept a landing call provoked from the outside, so we make sure we forward this and do something else, so we make justarrived at landing one
    local returnVal = bkjapi.AcceptLandCalls()
    if returnVal then
        print("This is value of returnVal", returnVal)
        print("This is the func output of acceptlandcals", bkjapi.AcceptLandCalls())
        sleep(0.75)
        bkjapi.Busy(true)
        print("Next func is here")
        local suc, res = pcall(bkjapi.GoToFloor, returnVal)
        if not suc then
            parallel.waitForAll(bkjapi.CheckForPosIfNotTryCalib, bkjapi.BusyFlash)
            bkjapi.GoToFloor(returnVal)
        end
        parallel.waitForAll(bkjapi.doorCycle, AWAITAcceptCabCallsWhileDoor)
        if xyz then
            print("xyz 123 is executed")
            bkjapi.Busy(true)
            local suc, res = pcall(bkjapi.GoToFloor, xyz)
            if string.find(res, "NotCalibrated") then
                parallel.waitForAll(bkjapi.CheckForPosIfNotTryCalib, bkjapi.BusyFlash)
                suc, res = pcall(bkjapi.GoToFloor, xyz)
            end
            if string.find(res, "NotCalibrated") then
                error("Couldn't Calibrate")
            elseif string.find(res, "123") then
                print("Safety broken in middle whoops")
                bkjapi.Busy()
            else
                bkjapi.doorCycle()
                bkjapi.Busy()
            end
        end
    end

    -- below function is when everything is idling, and we get a call from inside the cab
    local returnValA = bkjapi.AcceptCabCallsOpen()
    if returnValA then
        print("THIS IS RETURNVAL A ", returnValA)
        sleep(0.75)
        print("Recieved Cab Call Input!")
        bkjapi.Busy(true)
        print("In Busy")
        print("Going to floor", returnValA)
        local suc, res = pcall(bkjapi.GoToFloor, returnValA)
        if string.find(res, "NotCalibrated") then
            parallel.waitForAll(bkjapi.CheckForPosIfNotTryCalib, bkjapi.BusyFlash)
            suc, res = pcall(bkjapi.GoToFloor, returnValA)
        end
        print(res)
        print(type(res))
        if string.find(res, "NotCalibrated") then
            error("Couldn't calibrate!")
        elseif string.find(res, "123") then
            print("Safety broken in middle, whoops")
            bkjapi.Busy()
        else
            print("Why is this still executing")
            print("Cycling door")
            bkjapi.doorCycle()
            print("Making it unbusy")
            bkjapi.Busy()
        end
    end
    -- see somewhere above, but when just arrived landing is one, itmeans a user from outside called, so we open the doors, and we also accept input at the same time. in case the user isnt input anything or needs more time or didnt enter the lift, the lift is unbusy at this time and goes back to its normal running loop.
end
