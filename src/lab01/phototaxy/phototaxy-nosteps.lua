-- Put your global variables here

MOVE_STEPS = 5
n_steps = 0
-- min_v_radial = 2*math.pi/10.0 -- rad/sec
-- radial_distance = 1.0 -- cm
v = {left = 0.0, right = 0.0}
--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	move(0.0, 0.0, rotate(0.0))
	n_steps = 0
	robot.leds.set_all_colors("black")
end

function rotate(angle) 
	if angle < 0  then
		return 1.0, -1.0
	elseif angle > 0 then
		return -1.0, 1.0
	else
		return 1.0, 1.0
	end 
end

function move(lv, rv, ld, rd)
	v.left, v.right = lv*ld, rv*rd
	robot.wheels.set_velocity(lv*ld, rv*rd)
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()

	n_steps = n_steps + 1

	lumus_index = 0	
	lumus_value = 0.0

	for i=1,24 do
		if lumus_value < robot.light[i].value then
			lumus_value = robot.light[i].value
			lumus_index = i
		end
	end

	-- log("MAX @ " .. lumus_index)

	if lumus_index == 1 or lumus_index == 24 then
		move(5.0, 5.0, rotate(0.0))
	else 	
		move(5.0, 5.0, rotate(robot.light[lumus_index].angle))
	end
	
	--[[ Check if close to light 
	(note that the light threshold depends on both sensor and actuator characteristics) ]]
	light = false
	sum = 0
	for i=1,24 do
		sum = sum + robot.light[i].value
	end
	if sum > 2.0 then
		light = true
	end

	if light == true then
		robot.leds.set_all_colors("yellow")
	else
		robot.leds.set_all_colors("black")
	end
end


--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	move(0.0, 0.0, rotate(0.0))
	n_steps = 0
	robot.leds.set_all_colors("black")
end

--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
