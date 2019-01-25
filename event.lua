require "refueling"
require "autoscheduling"

init_cache()

script.on_init(
    function()
        global.s = {nextInt = 0, fifo = Fifo.new(), index = {}}
        global.t = {idle = {}}
    end
)
script.on_load(
    function()
        if cache["autoschedule_enabled"] then
            Autoscheduling.onLoad()
            -- debug( global)
        end
    end
)

script.on_event(
    defines.events.on_train_changed_state,
    function(event)
        Refueling.refuelIfNeeded(event)
        if cache["autoschedule_enabled"] then
            Autoscheduling.onTrainChangedState(event)
        end
    end
)
script.on_nth_tick(60 * 5, Refueling.cleanTrains)
script.on_event(defines.events.on_runtime_mod_setting_changed, init_cache)

if cache["autoschedule_enabled"] then
    script.on_nth_tick(60 * 10, Autoscheduling.onTraiterListeAttente)
    script.on_event(defines.events.on_entity_renamed, Autoscheduling.onRename)
    script.on_event(defines.events.on_built_entity, Autoscheduling.onBuilt)
    script.on_event(defines.events.on_robot_built_entity, Autoscheduling.onBuilt)
    script.on_event(defines.events.on_player_mined_entity, Autoscheduling.onRemoved)
    script.on_event(defines.events.on_robot_mined_entity, Autoscheduling.onRemoved)
    script.on_event(defines.events.on_entity_died, Autoscheduling.onRemoved)
end
