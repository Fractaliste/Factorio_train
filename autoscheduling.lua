local stations = {}
local trains = {}

local isManagedStation
local isElligibleName

local managedStationColor = {g = 1, a = 0.5}
local unManagedStationColor = {b = 1, a = 0.5}
Autoscheduling = {
    onRename = function(event) -- Est-ce que la station appartient ou appartenait au réseau ?
        debug(event.entity.get_train_stop_trains())
        if isManagedStation(event.entity) then
            event.entity.color = managedStationColor
        end
        -- Synchroniser la liste des stations qu'on gère

        -- Vérifier l'ancien nom s'il était managé
    end,
    onBuilt = function(event)
        -- Si le nom existe déjà, en recréer un
        debug(isManagedStation(event.created_entity))
    end,
    onRemoved = function(event)
        debug(event.entity.backer_name)
    end,
    onTrainChangedState = function(event)
        -- Un train faisant parti de l'autoscheduling est un train en mode automatique et qui a comme dernière station prévue le parking
        if
            event.train.manual_mode or event.train.schedule == nil or
                event.train.schedule.records[#event.train.schedule.records] ~= cache["autoschedule_parking_name"]
         then
            trains[event.train.id] = nil --Reset si jamais ce train avait précédemment fait partie de l'autoscheduling
            return
        end

        -- Si le train va vers le parking, vérifier pour lui attribuer un nouveau boulot

        -- Sinon le laisser faire son boulot
    end,
    onStationStateUpdate = function(event)
        -- Pour chaque station gérée faire
        -- -- Si aucun train sur la route (entity.get_train_stop_trains()) se mettre sur la liste d'attente
    end,
    onTraiterListeAttente = function()
    end
}

-- Retourne true si l'entité est une station, et est dans le scope de l'autoscheduling
isManagedStation = function(entity)
    if (entity.name == "train-stop") then
        return isElligibleName(entity.backer_name)
    else
        return false
    end
end

isElligibleName = function(name)
    return string.find(name, ".+#[io].+") ~= nil
end
