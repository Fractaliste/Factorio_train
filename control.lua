

function on_train_changed_state_Raphiki(event)
	log(serpent.block(defines.train_state.wait_station .. " => " .. case[event.train.state]))
	if trainNeedRefuel(event.train) then
		goToRefuel(event.train)
	end
end

script.on_event(defines.events.on_train_changed_state, on_train_changed_state_Raphiki)


case = {	[defines.train_state.on_the_path]	= "Normal state -- following the path.",
	[defines.train_state.path_lost] = "Had path and lost it -- must stop.",
	[defines.train_state.no_schedule] = "Doesn't have anywhere to go.",
	[defines.train_state.no_path] = "Has no path and is stopped.",
	[defines.train_state.arrive_signal] = "Braking before a rail signal.",
	[defines.train_state.wait_signal] = "Waiting at a signal.",
	[defines.train_state.arrive_station] = "Braking before a station.",
	[defines.train_state.wait_station] = "Waiting at a station.",
	[defines.train_state.manual_control_stop] = "Switched to manual control and has to stop.",
	[defines.train_state.manual_control] = "Can move if user explicitly sits in and rides the train."
	}
	
fuelBase = { ["nuclear-fuel"] = 50, ["coal"] = 1, ["solid-fuel"] = 1 }

function trainNeedRefuel(train)
	for k, l in pairs(train.locomotives.front_movers) do
		if locomotiveNeedRefuel(l) then
			return true
		end
	end
	return false
end

function locomotiveNeedRefuel(locomotive)
	local fuelCount = 0
	local fuel = locomotive.get_fuel_inventory()
	for k, v in pairs(fuel.get_contents()) do
		fuelCount = fuelCount + fuelBase[k] * v
    end
	if fuelCount < 60 then
		return true
	else
		return false
	end
end


function goToRefuel(train)
	log(serpent.block(train.schedule))

end