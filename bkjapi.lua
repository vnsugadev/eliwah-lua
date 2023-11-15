os.loadAPI("bundleAPI")

local input = "right"
local output = "back"

function getCurrentFloor()
    local floor
    if bundleAPI.getInput(input, "white") then
        floor = 1
    elseif bundleAPI.getInput(input, "orange") then
        floor = 2
    elseif bundleAPI.getInput(input, "magenta") then
        floor = 3
    elseif bundleAPI.getInput(input, "lightblue") then
        floor = 4
    elseif bundleAPI.getInput(input, "yellow") then
        floor = 5
    else
        floor = nil
    end
    return floor
end
function pulseUP()
    bundleAPI.on(output, "orange")
    os.sleep(0.25)
    bundleAPI.off(output, "orange")
end
function pulseDN()
    bundleAPI.on(output, "white")
    os.sleep(0.25)
    bundleAPI.off(output, "white")
end
function GoToFloor(n)
    --explictly ask it to go to a floor, this wont do any b4hand checks!
    local floor
    local colour
    if bundleAPI.getInput(input, "white") then
        floor = 1
    elseif bundleAPI.getInput(input, "orange") then
        floor = 2
    elseif bundleAPI.getInput(input, "magenta") then
        floor = 3
    elseif bundleAPI.getInput(input, "lightblue") then
        floor = 4
    elseif bundleAPI.getInput(input, "yellow") then
        floor = 5
    else
        floor = nil
    end
    print(n)
    print(floor)
    if n > floor then
        IsHigher = true
    else
        IsHigher = false
    end
    --need to assignn number back to color
    if n == 1 then
        colour = "white"
    elseif n == 2 then
        colour = "orange"
    elseif n == 3 then
        colour = "magenta"
    elseif n == 4 then
        colour = "lightblue"
    elseif n == 5 then
        colour = "yellow"
    end
    --the following first checks if IsHigher is True, so if it is, it will --then run a while statement which then pushes the lift down, when it --is satisfied just see above for logic it should break
    print(IsHigher)
    if IsHigher == true then
        while not bundleAPI.getInput(input, colour) do
            bundleAPI.pulse(output, "orange", 0.5)
            os.sleep(0.5)
        end
    elseif IsHigher == false then
        while not bundleAPI.getInput(input, colour) do
            bundleAPI.pulse(output, "white", 1)
            os.sleep(0.5)
        end
    end
end

function doorCycle()
    local doorOpen = "lightblue"
    local doorClose = "magenta"
    local anyDoorOpen = "magenta"
    for cycles = 0, 2 do
        bundleAPI.on(output, doorOpen)
        os.sleep(0.25)
        bundleAPI.off(output, doorOpen)
        os.sleep(0.25)
    end
    os.sleep(5) -- wait with door open
    while bundleAPI.getInput(input, anyDoorOpen) do
        bundleAPI.on(output, doorClose)
        os.sleep(0.25)
        bundleAPI.off(output, doorClose)
        os.sleep(0.25)
    end
end

-- will update again geez

function CheckForPosIfNotTryCalib()
    local floor
    if bundleAPI.getInput(input, "white") then
        floor = 1
    elseif bundleAPI.getInput(input, "orange") then
        floor = 2
    elseif bundleAPI.getInput(input, "magenta") then
        floor = 3
    elseif bundleAPI.getInput(input, "lightblue") then
        floor = 4
    elseif bundleAPI.getInput(input, "yellow") then
        floor = 5
    else
        floor = nil
    end
    if floor == nil then
        print(floor)
        print("Attempting to calibrate! Please wait")
        local floora
        while true do
            print("Loop down")
            bundleAPI.pulse(output, "white", 0.5)
            os.sleep(1)
            if bundleAPI.getInput(input, "white") then
                floora = 1
            elseif bundleAPI.getInput(input, "orange") then
                floora = 2
            elseif bundleAPI.getInput(input, "magenta") then
                floora = 3
            elseif bundleAPI.getInput(input, "lightblue") then
                floora = 4
            elseif bundleAPI.getInput(input, "yellow") then
                floora = 5
            else
                floora = nil
            end
            print("This is floora ", floora)
            if floora == 5 or floora == 4 or floora == 3 or floora == 2 or floora == 1 then
                print("Break!")
                break
            end
        end
    else
        print("Calibration not needed")
    end
end
function SafetyCheck()
    print("Checking Safety ")
    if bundleAPI.getInput(input,"lime") then
        print("Uh-oh! Seems like we have no safety. Perhaps a door is open? I will try to close it!")
        for i = 1, 3 do
            bundleAPI.pulse(output,"magenta",0.5)
            os.sleep(0.5) 
        end
        if bundleAPI.getInput(input,"lime") then
            print("Seems like safety hasn't connected yet, please call bkj support for further assistance.")
            error("noSafety")
        else
            print("Safety has been connected now!")
        end
    end
end
