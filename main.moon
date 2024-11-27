-- Configuration:
-- input bundle side
rs_input = 'right'
-- sequence of colors corresponding to the floors in order
floors = {
	colors.white,
	colors.orange,
	colors.magenta,
	colors.lightBlue,
	colors.yellow,
}
-- sequence of sequences of colors corresponding to the call buttons in floor order
calls_in = {
	{colors.pink, colors.blue},
	{colors.gray, colors.brown},
	{colors.lightGray, colors.green},
	{colors.cyan, colors.red},
	{colors.purple, colors.black},
}
-- safety connector that must be false when moving
safety = colors.lime

-- output bundle side
rs_output = 'back'
-- output configuration
output =
	up: colors.orange
	down: colors.white
	close: colors.magenta
	open: colors.lightBlue
	call: colors.lime
-- timing data for motors
pulse_width =
	on: 0.25
	off: 0.25
door_width = 3
linger_time = 8  -- seconds on a given floor

-- Program code here:
export rs  -- built-in redstone API
export bit  -- bit manipulation library
os.loadAPI 'scheduler'
export scheduler

rs_on = (side, values) ->
	rs.setBundledOutput side, bit.bor(rs.getBundledOutput(side), values)
rs_off = (side, values) ->
	rs.setBundledOutput side, bit.band(rs.getBundledOutput(side), bit.bnot(values))

last_floor = nil
getCurrentFloor = ->
	for floor, color in ipairs floors
		if rs.testBundledInput rs_input, color
			last_floor = floor
			return floor
	nil  -- between/not on a floor

do
	if cf = getCurrentFloor!
		print "init: on floor #{cf}"
	else
		print 'init: not on a floor, will have to level assuming the bottom'
		last_floor = 1

pulse = (dir) ->
	rs_on rs_output, output[dir]
	sleep pulse_width.on
	rs_off rs_output, output[dir]
	sleep pulse_width.off

unsafe = -> rs.testBundledInput rs_input, safety

goToFloor = (floor) ->
	print "goToFloor #{floor}"
	sense = assert floors[floor], "attempt to go to unknown floor #{floor}"
	dir = if floor > last_floor then 'up' else 'down'
	while getCurrentFloor! ~= floor
		return false, 'ABORTED_UNSAFE' if unsafe!
		pulse dir
		-- just in case we made a bad guess about alignment, continuously rectify
		-- our guess as to the direction of travel
		dir = if floor > last_floor then 'up' else 'down'
	true, floor

setDoor = (open) ->
	print "setDoor #{open}"
	line = if open then 'open' else 'close'
	for i = 1, door_width
		pulse line
	print "setDoor: unsafe = #{unsafe!}"
	print 'setDoor: WARN: still unsafe!' if (not open) and unsafe!

setCallLamp = (on) ->
	print "setCallLamp #{on}"
	func = if on then rs_on else rs_off
	func rs_output, output.call

calls = {}
preference = nil

readCalls = ->
	while true
		os.pullEvent 'redstone'
		for floor, colors in ipairs calls_in
			for _, color in ipairs colors
				if rs.testBundledInput rs_input, color
					calls[floor] = true
					print "readCalls: set call on #{floor} given #{colors[color]}"
					os.queueEvent 'elevator_called'
					setCallLamp true

resetCalls = ->
	print 'resetCalls'
	while next calls
		calls[next calls] = nil

bestFloor = ->
	seq = {}
	table.insert seq, floor for floor, _ in pairs calls
	table.sort seq
	return nil unless next seq  -- no calls

	if preference  -- prefer to keep moving in a direction
		predicate = if preference == 'up' then (floor) -> floor > last_floor else (floor) -> floor < last_floor
		filtered = [floor for floor in *seq when predicate(floor)]
		if next filtered  -- if there's a call in that direction
			seq = filtered  -- consider it exclusively
		else  -- otherwise
			preference = nil  -- relax our assumptions for next time
	
	best = nil  -- closest of all candidates
	for floor in *seq
		if best == nil or math.abs(floor - last_floor) < math.abs(best - last_floor)
			best = floor

	preference = if best > last_floor then 'up' else 'down'
	best


logic = ->
	while true
		print 'logic: initial state'
		-- Initially, open the door and wait for a call
		preference = nil
		setDoor true
		setCallLamp false
		os.pullEvent 'elevator_called'
		print 'logic: called'

		while next calls  -- inner loop to hold on to preference while multiple calls are outstanding
			print 'logic: movement'
			setDoor false
			floor = assert bestFloor!, 'could not generate a floor to go to?'
			print "logic: bestFloor! == #{floor}"
			success, problem = goToFloor floor
			setDoor true
			unless success
				print "A movement error occurred: #{problem}; resetting all calls."
				resetCalls!
				break
			unless next calls
				-- eagerly clear the call lamp now; it can still be set by readCalls during the linger
				setCallLamp false
			print 'logic: wait'
			sleep linger_time -- linger here for a bit
			-- repeat inner loop while calls remain
		-- fall to outer loop when no calls remain, clearing preference and idling

scheduler.setName scheduler.start(readCalls), 'readCalls'
scheduler.setName scheduler.start(logic), 'logic'

print 'Elevator ready for service'
scheduler.run!
