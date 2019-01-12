
-- Fonctions locales
local checkForRefueling
local getCurrentRecord
local getRefuelingStationScheduleRecord
local goToRefuel
local isGoingToRefuelStation
local locomotiveNeedRefuel
local removeRefuelingStop
local trainNeedRefuel

-- Fonctions exportées
Refueling = {
    cleanTrains = function(event)
        for k, l in pairs(game.surfaces[1].find_entities_filtered({name = "locomotive"})) do
            if not isGoingToRefuelStation(l.train) and not trainNeedRefuel(l.train) then
                l.train.schedule = removeRefuelingStop(l.train.schedule)
            end
        end
    end,
    refuelIfNeeded = function(event)
        -- debug(event)
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
}

removeRefuelingStop = function(schedule)
    if (schedule == nil or #schedule.records == 0) then
        return
    end

    local newCurrent = schedule.current
    local removedItems = 0
    local newSchedule = util.table.deepcopy(schedule)
    for k, v in pairs(schedule.records) do
        if (v.station == cache["refueling_station_name"]) then
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

checkForRefueling = function(event)
    -- debug(
    --     "old state = " ..
    --         case[event.old_state] ..
    --             " => new state = " ..
    --                 case[event.train.state] .. " => current record => " .. getCurrentRecord(event.train).station
    -- )

    if trainNeedRefuel(event.train) then
        goToRefuel(event.train)
    end
end

getCurrentRecord = function(train)
    --log(debug.traceback())
    return train.schedule.records[train.schedule.current]
end

trainNeedRefuel = function(train)
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

locomotiveNeedRefuel = function(locomotive)
    local fuelCount = 0
    local fuel = locomotive.get_fuel_inventory()
    for k, v in pairs(fuel.get_contents()) do
        local coeff = cache["refueling_coeff"][k]
        if coeff == nill then
            coeff = 1
        end
        fuelCount = fuelCount + coeff * v
    end
    -- debug("Décision : " .. tostring(fuelCount .. "/" .. tostring(cache["refueling_cutoff"])))
    if fuelCount < cache["refueling_cutoff"] then
        return true
    else
        return false
    end
end

goToRefuel = function(train)
    -- log("Change scheduled stop from " .. serpent.block(getCurrentRecord(train).station) .. " to refueling station")

    newSchedule = removeRefuelingStop(train.schedule) -- Ne fonctionne pas ????
    table.insert(newSchedule.records, newSchedule.current, refuelingStationScheduleRecord)
    train.schedule = newSchedule
    train.recalculate_path(true)
end

isGoingToRefuelStation = function(train)
    --log("isGoingToRefuelStation")
    return train.schedule == nil or getCurrentRecord(train).station == cache["refueling_station_name"]
end
