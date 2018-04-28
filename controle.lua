
function updateSchedule(train, state)
  game.write_file("mod.log", "Event - Hello world!", true)
end

game.write_file("mod.log", "Hello world!", true)

script.on_event(defines.events.on_train_changed_state, updateSchedule)
