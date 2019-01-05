require "refueling"

script.on_event(defines.events.on_train_changed_state, Refueling.refuelIfNeeded)
script.on_nth_tick(60 * 5, Refueling.cleanTrains)
script.on_load(init_cache)
script.on_event(defines.events.on_runtime_mod_setting_changed, init_cache)
