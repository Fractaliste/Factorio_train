require "util"

function on_nth_tick_Raphiki(event)
	for k, l in pairs(game.surfaces[1].find_entities_filtered({name = "locomotive"})) do
		if not isGoingToRefuelStation(l.train) and not trainNeedRefuel(l.train) then
			l.train.schedule = removeRefuelingStop(l.train.schedule)
		end
	end
end

function removeRefuelingStop(schedule)
	log(serpent.block(schedule))
	if (schedule == nil or #schedule.records == 0) then
		return
	end

	local newCurrent = schedule.current
	local removedItems = 0
	local newSchedule = util.table.deepcopy(schedule)
	for k, v in pairs(schedule.records) do
		if (v.station == "Plein") then
			if (k < schedule.current) then
				newCurrent = newCurrent - 1
			end
			table.remove(newSchedule.records, k - removedItems)
			removedItems = removedItems + 1
		end
	end
	newSchedule.current = newCurrent
	return newSchedule
end

function on_train_changed_state_Raphiki(event)
	if event.train.schedule == nil or event.train.manual_mode then
		-- Si pas de path ou mode manuel, pas de mods
		return
	elseif event.old_state == defines.train_state.wait_station then
		-- On repath au départ de la dernière station dans la majorité des cas
		checkForRefueling(event)
	elseif #event.train.schedule.records == 1 and not isGoingToRefuelStation(event.train) then
		-- Pour les trains n'ayant qu'une station de prévue pour l'instant on autorise le refueling quelque soit le state
		checkForRefueling(event)
	else
		-- log(serpent.block(case[event.old_state]))
		-- log(serpent.block(event))
	end
end

function checkForRefueling(event)
	log(
		"old state = " ..
			case[event.old_state] ..
				" => new state = " .. case[event.train.state] .. " => current record => " .. getCurrentRecord(event.train).station
	)

	if trainNeedRefuel(event.train) then
		goToRefuel(event.train)
	end
end

script.on_event(defines.events.on_train_changed_state, on_train_changed_state_Raphiki)
script.on_nth_tick(60 * 5, on_nth_tick_Raphiki)

case = {
	[defines.train_state.on_the_path] = "Normal state -- following the path.",
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

fuelBase = {["nuclear-fuel"] = 50, ["coal"] = 1, ["solid-fuel"] = 1}

refuelingStationScheduleRecord = {
	station = "Plein",
	wait_conditions = {
		{type = "inactivity", compare_type = "and", ticks = 60 * 5}
	}
}

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
	for k, l in pairs(train.locomotives.back_movers) do
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
		local coeff = fuelBase[k]
		if coeff == nill then
			coeff = 1
		end
		fuelCount = fuelCount + coeff * v
	end
	if fuelCount < 60 then
		return true
	else
		return false
	end
end

function goToRefuel(train)
	log("Change scheduled stop from " .. serpent.block(getCurrentRecord(train).station) .. " to refueling station")

	newSchedule = removeRefuelingStop(train.schedule)
	table.insert(newSchedule.records, newSchedule.current, refuelingStationScheduleRecord)
	train.schedule = newSchedule
	train.recalculate_path(true)
end

function isGoingToRefuelStation(train)
	--log("isGoingToRefuelStation")
	return train.schedule == nil or getCurrentRecord(train).station == "Plein"
end
