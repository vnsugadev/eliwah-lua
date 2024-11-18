local tasks = { }
getTasks = function()
  return tasks
end
local finish = { }
taskFinished = function(task, ...)
  local subscribers = finish[task]
  if not (subscribers) then
    return 
  end
  finish[task] = nil
  for callback, _ in pairs(subscribers) do
    callback(task, ...)
  end
  return nil
end
after = function(task, callback)
  if not (finish[task]) then
    finish[task] = { }
  end
  finish[task][callback] = true
end
onError = function(task, err)
  return print("Task " .. tostring(task) .. " failed with " .. tostring(err))
end
onFinish = function(task, ...)
  return taskFinished(task, ...)
end
invoke = function(task, ...)
  tasks[task] = nil
  local result = {
    coroutine.resume(task, ...)
  }
  local success = table.remove(result, 1)
  if not (success) then
    onError(task, result[1])
    return 
  end
  if coroutine.status(task) == 'dead' then
    onFinish(task, table.unpack(result))
    return 
  end
  local filter = result[1]
  if filter then
    tasks[task] = filter
  else
    tasks[task] = true
  end
end
start = function(func, ...)
  return invoke(coroutine.create(func), ...)
end
local running = true
stop = function()
  running = false
end
run = function()
  running = true
  while running do
    local event = table.pack(os.pullEventRaw())
    for task, filter in pairs(tasks) do
      if filter == true or event[1] == filter or event[1] == 'terminate' then
        invoke(task, table.unpack(event, 1, event.n))
      end
    end
  end
end
