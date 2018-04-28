script.on_event(defines.events.on_train_changed_state, updateSchedule)

function updateSchedule(train, state)
  log train
  log state
end
