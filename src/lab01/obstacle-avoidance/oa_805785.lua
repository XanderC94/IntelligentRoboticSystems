-- Put your global variables here

MOVE_STEPS = 3
n_steps = 0
-- min_v_radial = 2*math.pi/10.0 -- rad/sec
-- radial_distance = 1.0 -- cm
v = {left = 0.0, right = 0.0}
d = {left = -1.0, right = 1.0}
--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	lv, rv, a = 0.0, 0.0, 0.0
	move(lv, rv, rotate(a))
	n_steps = 0
	robot.leds.set_all_colors("red")
end

function rotate(angle) 
	if angle < 0.0  then
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
	prox_left = 0.0
	prox_right = 0.0
	lv, rv, a = 5.0, 5.0, 0.0

	if n_steps % MOVE_STEPS == 0 then
		
		for i= 1, 6 do
			prox_left = prox_left + robot.proximity[i].value
		end

		prox_left = prox_left / 6.0

		for i= 19, 24 do
			prox_right = prox_right + robot.proximity[i].value
		end

		prox_right = prox_right / 6.0
		
		if prox_left > 0.05 or prox_right > 0.05 then  
			if prox_right > prox_left then --turn left
				a = math.pi * 0.5
			elseif prox_left > prox_right then --turn right
				a = -math.pi * 0.5
			else -- turn behind
				a = d[robot.random.uniform_int(1,2)]*math.pi*0.5
			end
		end
	end
	
	move(lv, rv, rotate(a))
	
end


--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	move(0.0, 0.0, rotate(0.0))
	n_steps = 0
	robot.leds.set_all_colors("green")
end

--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
