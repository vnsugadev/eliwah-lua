os.loadAPI("bundleAPI")
function getCurrentFloor()
    local floor
    if bundleAPI.getInput("right", "white") then
        floor = 1
    elseif bundleAPI.getInput("right", "orange") then
        floor = 2
    elseif bundleAPI.getInput("right", "magenta") then
        floor = 3
    elseif bundleAPI.getInput("right", "lightblue") then
        floor = 4
    elseif bundleAPI.getInput("right", "yellow") then
        floor = 5
    else
        floor = nil
    end
    return floor
end
function pulseUP()
    bundleAPI.on("back", "orange")
    os.sleep(0.25)
    bundleAPI.off("back", "orange")
end
function pulseDN()
    bundleAPI.on("back", "white")
    os.sleep(0.25)
    bundleAPI.off("back", "white")
end
function GoToFloor(n)
    --explictly ask it to go to a floor, this wont do any b4hand checks!
    local floor
    local colour
    if bundleAPI.getInput("right", "white") then
        floor = 1
    elseif bundleAPI.getInput("right", "orange") then
        floor = 2
    elseif bundleAPI.getInput("right", "magenta") then
        floor = 3
    elseif bundleAPI.getInput("right", "lightblue") then
        floor = 4
    elseif bundleAPI.getInput("right", "yellow") then
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
        while not bundleAPI.getInput("right", colour) do
            bundleAPI.pulse("back", "orange", 0.5)
            os.sleep(0.5)
        end
    elseif IsHigher == false then
        while not bundleAPI.getInput("right", colour) do
            bundleAPI.pulse("back", "white", 1)
            os.sleep(0.5)
        end
    end
end

function doorCycle()
    local doorOpen = "lightblue"
    local doorClose = "magenta"
    local anyDoorOpen = "magenta"
    for cycles = 0, 2 do
        bundleAPI.on("back", doorOpen)
        os.sleep(0.25)
        bundleAPI.off("back", doorOpen)
        os.sleep(0.25)
    end
    os.sleep(5) -- wait with door open
    while bundleAPI.getInput("right", anyDoorOpen) do
        bundleAPI.on("back", doorClose)
        os.sleep(0.25)
        bundleAPI.off("back", doorClose)
        os.sleep(0.25)
    end
end

-- will update again geez

function CheckForPosIfNotTryCalib()
    local floor
    if bundleAPI.getInput("right", "white") then
        floor = 1
    elseif bundleAPI.getInput("right", "orange") then
        floor = 2
    elseif bundleAPI.getInput("right", "magenta") then
        floor = 3
    elseif bundleAPI.getInput("right", "lightblue") then
        floor = 4
    elseif bundleAPI.getInput("right", "yellow") then
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
            bundleAPI.pulse("back", "white", 0.5)
            os.sleep(1)
            if bundleAPI.getInput("right", "white") then
                floora = 1
            elseif bundleAPI.getInput("right", "orange") then
                floora = 2
            elseif bundleAPI.getInput("right", "magenta") then
                floora = 3
            elseif bundleAPI.getInput("right", "lightblue") then
                floora = 4
            elseif bundleAPI.getInput("right", "yellow") then
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
