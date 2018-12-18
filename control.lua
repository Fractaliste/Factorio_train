require "util"

function on_train_changed_state_Raphiki(event)
	log("old state = " .. case[event.old_state] .. " => new state = " .. case[event.train.state] .. " => current record => " .. getCurrentRecord(event.train).station)

	-- On ne repath que si l'on quitte une station
	if event.old_state ~= defines.train_state.wait_station then
		return
	end

	if trainNeedRefuel(event.train) then
		goToRefuel(event.train)
	elseif isGoingToRefuelStation(event.train) then
		goToNextStation(event.train)
	end
end

script.on_event(defines.events.on_train_changed_state, on_train_changed_state_Raphiki)


case = {
	[defines.train_state.on_the_path]	= "Normal state -- following the path.",
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

function getCurrentRecord(train)
	--log(debug.traceback())
	return train.schedule.records[train.schedule.current]
end

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
		local coeff = fuelBase[k];
		if coeff == nill then  coeff = 1; end;
		fuelCount = fuelCount + coeff * v
    end
	if fuelCount < 60 then
		return true
	else
		return false
	end
end


function goToRefuel(train)
	--log(serpent.block(train.schedule))
	if isGoingToRefuelStation(train) then
		return
	end
	local newSchedule = util.table.deepcopy(train.schedule)
	for k, v in pairs(train.schedule.records) do
			if(v.station == "Plein") then
				log("Change scheduled stop from " .. serpent.block(getCurrentRecord(train).station) .. " to " .. train.schedule.records[k].station)
				newSchedule.current = k
				train.schedule = newSchedule
				train.recalculate_path(true)
				return
			end
	end
end

function isGoingToRefuelStation(train)
	--log("isGoingToRefuelStation")
	return getCurrentRecord(train).station == "Plein"
end

function goToNextStation(train)
	local newSchedule = util.table.deepcopy(train.schedule)
	newSchedule.current = train.schedule.current + 1
	if newSchedule.records[newSchedule.current] == nil then
		newSchedule.current = 1
	end
	log("Arrêt " .. getCurrentRecord(train).station .. " annulé et remplacé par " .. newSchedule.records[newSchedule.current].station)
	train.schedule = newSchedule
	train.recalculate_path(true)
end
