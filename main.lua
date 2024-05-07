-- main runner clip
os.loadAPI("bkjapi")

print("Welcome to BKJ Lift Controller v0.1")
print("Made with Piss & Love and shit")
print("Checking Safety....")
bkjapi.SafetyCheck()
print("Checking for Floor position...")
bkjapi.CheckForPosIfNotTryCalib()
print("Running main loop...")
while true do
    local function AWAITAcceptCabCallsWhileDoor()
   	 xyz = bkjapi.AcceptCabCallsWhileDoor()
   	 return
    end
    -- below function is when everything is idling, and we accept a landing call provoked from the outside, so we make sure we forward this and do something else, so we make justarrived at landing one
    local returnVal = bkjapi.AcceptLandCalls()
    if returnVal then
   	 sleep(0.75)
   	 bkjapi.Busy(true)
   	 bkjapi.GoToFloor(returnVal)
   	 parallel.waitForAll(bkjapi.doorCycle, AWAITAcceptCabCallsWhileDoor)
   	 if xyz then
   		 bkjapi.Busy(true)
   		 bkjapi.GoToFloor(xyz)
   		 bkjapi.doorCycle()
   		 bkjapi.Busy()
   	 end
    end
    -- below function is when everything is idling, and we get a call from inside the cab
    local returnValA = bkjapi.AcceptCabCallsOpen()
    if returnValA then
   	 sleep(0.75)
   	 print("Recieved Cab Call Input!")
   	 bkjapi.Busy(true)
   	 print("In Busy")
   	 print("Going to floor", returnvalA)
   	 bkjapi.GoToFloor(returnValA)
   	 print("Cycling door")
   	 bkjapi.doorCycle()
   	 print("Making it unbusy")
   	 bkjapi.Busy()
    end
    -- see somewhere above, but when just arrived landing is one, itmeans a user from outside called, so we open the doors, and we also accept input at the same time. in case the user isnt input anything or needs more time or didnt enter the lift, the lift is unbusy at this time and goes back to its normal running loop.
end




