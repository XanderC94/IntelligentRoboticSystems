-- Put your global variables here

MOVE_STEPS = 15
n_steps = 0


--[[ This function is executed every time you press the 'execute'
     button ]]
--invocata quando parte il controllo del robot
function init()
	left_v = robot.random.uniform(0,15)
	right_v = robot.random.uniform(0,15)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end



--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	n_steps = n_steps + 1
	if n_steps % MOVE_STEPS == 0 then
		--left_v = robot.random.uniform(0,15)
		--right_v = robot.random.uniform(0,15)
	end

	-- Search for the reading with the highest value
	value = -1 -- highest value found so far
	idx = -1   -- index of the highest value
	for i=1,24 do
		if value < robot.proximity[i].value then
			idx = i
			value = robot.proximity[i].value
		end
	end
	log("robot max proximity sensor: " .. idx .. "," .. value)

-- extreme case: 
	if value == 1 then -- an obstacle has been touched
		left_v = 0
		right_v = 0
	elseif value == 0 then -- no obstacle
		robot.leds.set_all_colors("green")
	end
	
	--[[if value > 0 then
		if idx <= 6 or idx >= 19 then
			robot.leds.set_all_colors("yellow")
			left_v = -7
			right_v = -7
		end	
	end]]--

	if value > 0 then
		robot.leds.set_all_colors("yellow")
		if idx <= 6 then		-- obstacle on the left side	
			-- check if there are any obstacles on the other side
			secvalue = -1
			for i=19,24 do
				if secvalue < robot.proximity[i].value then
					secvalue = robot.proximity[i].value
				end
			end
			if secvalue>0 then
				left_v = 7 
				right_v = 0 --turn right
			else
				left_v = -7 -- go straight on
				right_v = -7	
			end
		elseif idx>=19 then		-- obstacle on the right side
			-- check if there are any obstacles on the other side
			secvalue = -1
			for i=1,6 do
				if secvalue < robot.proximity[i].value then
					secvalue = robot.proximity[i].value
				end
			end
			if secvalue>0 then
				left_v = 0 --turn left
				right_v = 7 
			else
				left_v = -7 -- go straight on
				right_v = -7	
			end
		elseif idx >=7 and idx <=18 then --obstacle on the back
			left_v = 7 -- go straight on
			right_v = 7	
		end
	else
		if n_steps % MOVE_STEPS == 0 then
			left_v = robot.random.uniform(0,15)
			right_v = robot.random.uniform(0,15)
		end
	end
	robot.wheels.set_velocity(left_v,right_v)
	
end



--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = robot.random.uniform(0,15)
	right_v = robot.random.uniform(0,15)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
