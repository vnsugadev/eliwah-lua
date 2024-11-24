local rs_input = 'right'
local floors = {
  colors.white,
  colors.orange,
  colors.magenta,
  colors.lightBlue,
  colors.yellow
}
local calls_in = {
  {
    colors.pink,
    colors.blue
  },
  {
    colors.gray,
    colors.brown
  },
  {
    colors.lightGray,
    colors.green
  },
  {
    colors.cyan,
    colors.red
  },
  {
    colors.purple,
    colors.black
  }
}
local safety = colors.lime
local rs_output = 'back'
local output = {
  up = colors.orange,
  down = colors.white,
  close = colors.magenta,
  open = colors.lightBlue,
  call = colors.lime
}
local pulse_width = {
  on = 0.25,
  off = 0.25
}
local door_width = 3
local linger_time = 8
os.loadAPI('scheduler')
local rs_on
rs_on = function(side, values)
  return rs.setBundledOutput(side, bit.bor(rs.getBundledOutput(side), values))
end
local rs_off
rs_off = function(side, values)
  return rs.setBundledOutput(side, bit.band(rs.getBundledOutput(side), bit.bnot(values)))
end
local last_floor = nil
local getCurrentFloor
getCurrentFloor = function()
  for floor, color in ipairs(floors) do
    if rs.testBundledInput(rs_input, color) then
      last_floor = floor
      return floor
    end
  end
  return nil
end
do
  do
    local cf = getCurrentFloor()
    if cf then
      print("init: on floor " .. tostring(cf))
    else
      print('init: not on a floor, will have to level assuming the bottom')
      last_floor = 1
    end
  end
end
local pulse
pulse = function(dir)
  rs_on(rs_output, output[dir])
  sleep(pulse_width.on)
  rs_off(rs_output, output[dir])
  return sleep(pulse_width.off)
end
local unsafe
unsafe = function()
  return rs.getBundledInput(rs_input, safety)
end
local goToFloor
goToFloor = function(floor)
  print("goToFloor " .. tostring(floor))
  local sense = assert(floors[floor], "attempt to go to unknown floor " .. tostring(floor))
  local dir
  if floor > last_floor then
    dir = 'up'
  else
    dir = 'down'
  end
  while getCurrentFloor() ~= floor do
    if unsafe() then
      return false, 'ABORTED'
    end
    pulse(dir)
    if floor > last_floor then
      dir = 'up'
    else
      dir = 'down'
    end
  end
  return true, floor
end
local setDoor
setDoor = function(open)
  print("setDoor " .. tostring(open))
  local line
  if open then
    line = 'open'
  else
    line = 'close'
  end
  for i = 1, door_width do
    pulse(line)
  end
end
local setCallLamp
setCallLamp = function(on)
  print("setCallLamp " .. tostring(on))
  local func
  if on then
    func = rs_on
  else
    func = rs_off
  end
  return func(rs_output, output.call)
end
local calls = { }
local preference = nil
local readCalls
readCalls = function()
  while true do
    os.pullEvent('redstone')
    print('readCalls: event')
    for floor, colors in ipairs(calls_in) do
      for _, color in ipairs(colors) do
        if rs.testBundledInput(rs_input, color) then
          calls[floor] = true
          print("readCalls: set call on " .. tostring(floor) .. " given " .. tostring(colors[color]))
          os.queueEvent('elevator_called')
          setCallLamp(true)
        end
      end
    end
  end
end
local resetCalls
resetCalls = function()
  print('resetCalls')
  while next(calls) do
    calls[next(calls)] = nil
  end
end
local bestFloor
bestFloor = function()
  local seq = { }
  for floor, _ in pairs(calls) do
    table.insert(seq, floor)
  end
  table.sort(seq)
  if not (next(seq)) then
    return nil
  end
  if preference then
    local predicate
    if preference == 'up' then
      predicate = function(floor)
        return floor > last_floor
      end
    else
      predicate = function(floor)
        return floor < last_floor
      end
    end
    local filtered
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #seq do
        local floor = seq[_index_0]
        if predicate(floor) then
          _accum_0[_len_0] = floor
          _len_0 = _len_0 + 1
        end
      end
      filtered = _accum_0
    end
    if next(filtered) then
      seq = filtered
    else
      preference = nil
    end
  end
  local best = nil
  for _index_0 = 1, #seq do
    local floor = seq[_index_0]
    if best == nil or math.abs(floor - last_floor) < math.abs(best - last_floor) then
      best = floor
    end
  end
  if best > last_floor then
    preference = 'up'
  else
    preference = 'down'
  end
  return best
end
local logic
logic = function()
  while true do
    print('logic: initial state')
    preference = nil
    setDoor(true)
    setCallLamp(false)
    os.pullEvent('elevator_called')
    print('logic: called')
    while next(calls) do
      print('logic: movement')
      setDoor(false)
      local floor = assert(bestFloor(), 'could not generate a floor to go to?')
      print("logic: bestFloor! == " .. tostring(floor))
      local success, problem = goToFloor(floor)
      setDoor(true)
      if not (success) then
        print("A movement error occurred: " .. tostring(problem) .. "; resetting all calls.")
        resetCalls()
        break
      end
      if not (next(calls)) then
        setCallLamp(false)
      end
      print('logic: wait')
      sleep(linger_time)
    end
  end
end
scheduler.start(readCalls)
scheduler.start(logic)
print('Elevator ready for service')
return scheduler.run()
