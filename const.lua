cache = {}

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
	station = nil,
	wait_conditions = {
		{type = "inactivity", compare_type = "and", ticks = 60 * 5}
	}
}