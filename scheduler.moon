-- Scheduler: a parallel-like interface that permits dynamism--one can add
-- tasks to the main loop at any time.

-- Knowing how this code works requires understanding The Big Secret of
-- ComputerCraft's event loop: os.pullEventRaw is just coroutine.yield,
-- including the optional argument. That is, in particular, why spinning the VM
-- without a pullEvent produces an error "too long without yielding".

tasks = {}  -- global task table
export getTasks = -> tasks

finish = {}  -- subscribers to a task ending
export taskFinished = (task, ...) ->
	subscribers = finish[task]
	return unless subscribers
	finish[task] = nil  -- don't leak subscribers if we error
	callback(task, ...) for callback, _ in pairs subscribers
	nil  -- don't return a random function result

-- Run a callback after a task finishes; args will be the task itself, then all the return values
export after = (task, callback) ->
	finish[task] = {} unless finish[task]
	finish[task][callback] = true

-- Configurable callbacks for scheduling events
export onError = (task, err) -> print "Task #{task} failed with #{err}"
export onFinish = (task, ...) -> taskFinished(task, ...)

-- run one round of a task, resuming with ...
export invoke = (task, ...) ->
	tasks[task] = nil  -- only explicitly reschedule below
	result = {coroutine.resume task, ...}
	success = table.remove result, 1
	unless success
		onError task, result[1]
		return
	if coroutine.status(task) == 'dead'
		onFinish task, table.unpack(result)
		return
	-- non-terminal state, keep going
	filter = result[1]  -- optional as per CC ABI
	if filter
		tasks[task] = filter
	else
		tasks[task] = true

-- start a task asynchronously; the task code runs immediately up to its first yield
export start = (func, ...) -> invoke coroutine.create(func), ...

running = true

-- stop any running scheduler
export stop = -> running = false

-- run the scheduler; this doesn't return until stop() is called
export run = ->
	running = true
	while running
		event = table.pack(os.pullEventRaw())
		for task, filter in pairs tasks
			if filter == true or event[1] == filter or event[1] == 'terminate'
				invoke task, table.unpack(event, 1, event.n)