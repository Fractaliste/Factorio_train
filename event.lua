require "refueling"
require "autoscheduling"

init_cache()

script.on_event(defines.events.on_train_changed_state, Refueling.refuelIfNeeded)
script.on_nth_tick(60 * 5, Refueling.cleanTrains)
script.on_event(defines.events.on_runtime_mod_setting_changed, init_cache)

if cache["autoschedule_enabled"] then
    script.on_event(defines.events.on_entity_renamed, Autoscheduling.onRename)
    script.on_event(defines.events.on_built_entity, Autoscheduling.onBuilt)
    script.on_event(defines.events.on_robot_built_entity, Autoscheduling.onBuilt)
end
