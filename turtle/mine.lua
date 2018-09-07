initialZ = 64
minZ = 6

-- true if dig is ok, false else
function digDown()
	if turtle.detect() then
		if  not turtle.dig() then
			return false
		end
	end
	if turtle.detectDown() then
		if not turtle.digDown then
			return false
		end
	end
	return true
end

function digUp()
	if turtle.detect() then
		if  not turtle.dig() then
			return false
		end
	end
	if turtle.detectUp() then
		if not turtle.digUp() then
			return false
		end
	end
	return true
end

-- positive for forward, negative for backward
function forward(n)
	if n > 0 then
		fn = turtle.forward
		s = 1
	elseif n < 0 then
		fn = turtle.back
		s = -1
	else
		return true
	end

	for i = 1,n do
		if not fn() then
			return false
		else
			if orientation == 0 then
				xIndex = xIndex + s
			elseif orientation == 1 then
				yIndex = yIndex + s
			elseif orientation == 2 then
				xIndex = xIndex - s
			elseif orientation == 3 then
				yIndex = yIndex - s
			else
				return false
			end
		end
	end
	return true
end

function back(n)
	return forward(-n)
end

-- negative n for down, positive for up
function up(n)
	if n > 0 then
		fn = turtle.up
		s = 1
	elseif n < 0 then
		fn = turtle.down
		s = -1
	else
		return true
	end

	for i = 1,n do
		if not fn() then
			return false
		else
			zIndex = zIndex + s
		end
	end
	return true
end

function down(n)
	return up(-n)
end

-- turn sens trigo of n.
function turn(n)
	n = n%4
	if n == 1 then
		turtle.turnLeft()
	elseif n == 2 then
		turtle.turnLeft()
		turtle.turnLeft()
	elseif n == 3 then
		turtle.turnRight()
	end
	orientation = (orientation + n) % 4
end

-- look at specified orientation
function lookAt(n)
	turn(n-orientation)
end

function goto(x,y,z)
	if x-xIndex > 0 then
		-- travel on x axis first
		lookAt(0)
		if not forward(z-zIndex) then return false end
		if not forward(x-xIndex) then return false end
		lookAt(1)
		if not forward(y-yIndex) then return false end
	else
		--travel on y axis first
		lookAt(1)
		if not forward(y-yIndex) then return false end
		lookAt(0)
		if not forward(x-xIndex) then return false end
		if not forward(z-zIndex) then return false end
	end
	return true
end

function home()
	return goto(0,0,0)
end

function empty(fn)
	for i = 2,16 do
		turtle.select(i)
		fn()
	end
end


function lowFuel()
	return math.abs(lastX) + math.abs(lastX) + 300
end

function needSlots()
	emptySlots = 0
	for i = 1,16 do
		c = turtle.getItemCount(i)
		if 0 == c then emptySlots = emptySlots + 1 end
	end
	return emptyslots < 2
end

function needHome()
	return needSlots() and lowFuel()
end

function refuel(n, fn)
	while turtle.getFuelLevel() < n do
		turtle.select(16)
		assert(0 == turtle.getItemCount(16))
		fn(1)
		turtle.refuel()
		print(turtle.getFuelLevel())
	end
end

function standStop()
	lastX = xIndex
	lastY = yIndex
	lastZ = zIndex
	print("Going to stands")
	assert(home())
	lookAt(2)
	empty(turtle.dropUp)

	refuel(1000, turtle.suck)

	goto(lastX, lastY, lastZ)
	if lastX % 2 == 0 then
		lookAt(0)
	else
		lookAt(2)
	end
end

xIndex = 0
yIndex = 0
zIndex = 0

orientation = 0 -- number between 0 and 3 representing 1/4 rotation sens trigo

lastX = 0
lastY = 0
lastZ = 0

width = 8
length = 8

print("Turtle Started.")

standStop()

for w = 1,width do
	for l = 1,length do
		--decent phase
		for i = 0,-inialZ+minZ,-1 do
			assert(digDown() and down(1))
			if needHome() then standStop() end
		end

		-- transition phase
		if turtle.detect() then
			assert(up(1) and forward(1))
		else
			assert(forward(1))
		end
		while turtle.detect() do
			assert(digUp())
		end
		assert(up(1))
		assert(turtle.dig() and forward(1))

		-- acent phase
		for i = zIndex, 0 do
			while turtle.detectUp() or turtle.detect() do
				assert(digUp())
			end
			assert(up(1))
			if needHome() then standStop() end
		end
		digDown()
		assert(forward())
	end
	digDown()
	assert(forward())
	lookAt(1)
	digDown()
	assert(forward())

	if lastX % 2 == 0 then
		lookAt(0)
	else
		lookAt(2)
	end
end

home()
