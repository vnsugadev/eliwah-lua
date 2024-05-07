os.loadAPI("bundleAPI")
function getCurrentFloor()
	local floor
	if bundleAPI.getInput("right", "white") then
    	floor = 1
	elseif bundleAPI.getInput("right", "orange") then
    	floor = 2
	elseif bundleAPI.getInput("right", "magenta") then
    	floor = 3
	elseif bundleAPI.getInput("right", "lightBlue") then
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
	elseif bundleAPI.getInput("right", "lightBlue") then
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
    	colour = "lightBlue"
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
	doorCycleRun = true
	local doorOpen = "lightBlue"
	local doorClose = "magenta"
	local isAnyDoorOpen = "lime"
	for cycles = 0, 2 do
    	bundleAPI.on("back", doorOpen)
    	sleep(0.25)
    	bundleAPI.off("back", doorOpen)
    	sleep(0.25)
	end
	sleep(5) -- wait with door open
	while bundleAPI.getInput("right", isAnyDoorOpen) do
    	bundleAPI.on("back", doorClose)
    	sleep(0.25)
    	bundleAPI.off("back", doorClose)
    	sleep(0.25)
	end
	-- after door close, update doorCycleRun as false so the other function can accordingly use this data
	doorCycleRun = false
end

-- will update again geez

function CheckForPosIfNotTryCalib()
	BusyFlashBulb=true
	local floor
	if bundleAPI.getInput("right", "white") then
    	floor = 1
	elseif bundleAPI.getInput("right", "orange") then
    	floor = 2
	elseif bundleAPI.getInput("right", "magenta") then
    	floor = 3
	elseif bundleAPI.getInput("right", "lightBlue") then
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
        	sleep(0.1)
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
            	BusyFlashBulb=false
            	break
        	end
    	end
	else
    	print("Calibration not needed")
    	BusyFlashBulb = false
	end
end
function SafetyCheck()
	print("Checking Safety ")
	if bundleAPI.getInput("right", "lime") then
    	print("Uh-oh! Seems like we have no safety. Perhaps a door is open? I will try to close it!")
    	for i = 1, 3 do
        	bundleAPI.pulse("back", "magenta", 0.5)
        	os.sleep(0.5)
    	end
    	if bundleAPI.getInput("right", "lime") then
        	print("Seems like safety hasn't connected yet, please call bkj support for further assistance.")
        	error("noSafety")
    	else
        	print("Safety has been connected now!")
    	end
	end
end

function AcceptCabCallsWhileDoor()
	local cabCall
	-- we need to check if the door cycle thingy is done, if its done, then we need to finalize the call by returning the value back, if no button is pressed, we return nil
	sleep(0.1)
	print("Accepting Cab Calls Mode on")
	while true do
    	sleep(0.1)
    	if doorCycleRun == false then
        	break
    	end
    	if bundleAPI.getInput("right", "pink") then
        	cabCall = 1
    	elseif bundleAPI.getInput("right", "gray") then
        	cabCall = 2
    	elseif bundleAPI.getInput("right", "lightGray") then
        	cabCall = 3
    	elseif bundleAPI.getInput("right", "cyan") then
        	cabCall = 4
    	elseif bundleAPI.getInput("right", "purple") then
        	cabCall = 5
    	end
	end
	if cabCall == nil then
    	return nil
	else
    	return cabCall
	end
end

function AcceptLandCalls()
	sleep(0.1)
	if bundleAPI.getInput("right", "blue") then
    	landCall = 1
	elseif bundleAPI.getInput("right", "brown") then
    	landCall = 2
	elseif bundleAPI.getInput("right", "green") then
    	landCall = 3
	elseif bundleAPI.getInput("right", "red") then
    	landCall = 4
	elseif bundleAPI.getInput("right", "black") then
    	landCall = 5
	end
	return landCall
end

function Busy(n)
	sleep(0.1)
	if n == true then
    	bundleAPI.on("back", "yellow")
	else
    	bundleAPI.off("back", "yellow")
	end
end

function BusyFlash()
	sleep(0.1)
	while BusyFlashBulb do
    	bundleAPI.on("back", "yellow")
    	sleep(1)
    	bundleAPI.off("back", "yellow")
	end
end



function JustArrivedLandCall()
	doorCycle()
	Busy()
	return
end

-- open below here means basically when the lift is doing nothing, and someone invokes a call while being inside the lift, so we need a function that can respond to calls then. or if the user came in, the doors closed and then he may choose a floor, then this is neccacry

function AcceptCabCallsOpen()
	local cabCallA
    	sleep(0.1)
    	if bundleAPI.getInput("right", "pink") then
        	cabCallA = 1
    	elseif bundleAPI.getInput("right", "gray") then
        	cabCallA = 2
    	elseif bundleAPI.getInput("right", "lightGray") then
        	cabCallA = 3
    	elseif bundleAPI.getInput("right", "cyan") then
        	cabCallA = 4
    	elseif bundleAPI.getInput("right", "purple") then
        	cabCallA = 5
    	end
	if cabCallA == nil then
    	return nil
	else
    	return cabCallA
	end
end


