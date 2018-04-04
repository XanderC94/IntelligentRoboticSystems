-- Put your global variables here

MOVE_STEPS = 3
RESTART_STEP = 10

n_steps = 0
-- min_v_radial = 2*math.pi/10.0 -- rad/sec
-- radial_distance = 1.0 -- cm
v = {left = 0.0, right = 0.0}
d = {left = -1.0, right = 1.0}

stati = {searching_light = 0, reaching_light = 1, avoiding_obstacles = 2, light_reached = 3}

robot_status = stati.avoiding_obstacles

lv, rv, a = 0.0, 0.0, 0.0

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	--lv, rv, a = 0.0, 0.0, 0.0
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

function evaluateProximity(left, right)
	if prox_right > prox_left then --turn left
		return math.pi * 0.5
	elseif prox_left > prox_right then --turn right
		return -math.pi * 0.5
	else -- turn behind
		return d[robot.random.uniform_int(1,2)]*math.pi*0.5
	end
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()

	n_steps = n_steps + 1

	--[[When first deployed the robot must search for the light 
		and point towards such direction]]
	if robot_status == stati.searching_light then 
		photo_index = 0	
		photo_value = 0.0
		
		for i=1,24 do
			if photo_value < robot.light[i].value then
				photo_value = robot.light[i].value
				photo_index = i
			end
		end
		
		if photo_index > 1 and photo_index < 24 then
			-- Rotate until the front of the robot face the light sources
			lv, rv, a = 10, 10, robot.light[photo_index].angle
		else 
			--[[When the face of the robot is facing the light 
			then it can start to move toward it]]
			robot_status = stati.reaching_light
			log("Light pointed, now reaching...")
			lv, rv, a = 5.0, 5.0, 0.0
		end

	--[[When reaching the light the robot must actively search 
		and avoid for obstacles]]	
	elseif robot_status == stati.reaching_light then

		prox_left = 0.0
		prox_right = 0.0

		for i= 1, 6 do
			if prox_left < robot.proximity[i].value then
				prox_left = robot.proximity[i].value
			end

			if prox_right < robot.proximity[24-i+1].value then
				prox_right = robot.proximity[24-i+1].value
			end
		end

		log("Proximity on LEFT: ", prox_left, "\tProximity on RIGHT: ", prox_right)
		
		if prox_left > 0.01 or prox_right > 0.01 then
			--[[If near an obstacle then it must prioritize avoiding it 
				instead of reaching the light]]
				log("Obstacle Detected, now avoiding...")
				robot_status = stati.avoiding_obstacles
				a = evaluateProximity(prox_left, prox_right)
		else
			--[[Sometimes it may be necessary to search again for the light 
				if it hasn't been reached yet]]
			sum = 0.0
			for i=1,24 do
				sum = sum + robot.light[i].value
			end
			-- Check if light has been reached
			if sum > 2.0 then
				lv, rv, a = 0.0, 0.0, 0.0
				log("Light reached, WIIIIIIII!!!")
				robot_status = stati.light_reached
			elseif n_steps % RESTART_STEP == 0 then
				robot_status = stati.searching_light
			end
		end

	--[[When avoiding Obstacles then it should actively look for obstacles only]]
	elseif robot_status == stati.avoiding_obstacles then
		lv, rv, a = 5.0, 5.0, 0.0

		if n_steps % MOVE_STEPS == 0 then
			prox_left = 0.0
			prox_right = 0.0

			for i= 1, 5 do
				if prox_left < robot.proximity[i].value then
					prox_left = robot.proximity[i].value
				end

				if prox_right < robot.proximity[24-i+1].value then
					prox_right = robot.proximity[24-i+1].value
				end
			end

			log("Proximity on LEFT: ", prox_left, "\tProximity on RIGHT: ", prox_right)
	
			if prox_left > 0.01 or prox_right > 0.01 then

				log("Obstacle Detected, now avoiding...")
				robot_status = stati.avoiding_obstacles
				a = evaluateProximity(prox_left, prox_right)
			else
				robot_status = stati.searching_light
			end
		end
	elseif robot_status == stati.light_reached then
		-- Do Nothing @ All
		lv, rv, a = 0.0, 0.0, 0.0
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
