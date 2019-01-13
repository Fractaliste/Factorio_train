local stations = {}
local trains = {}

local isElligibleStation
local isElligibleName
local createName

local managedStationColor = {g = 1, a = 0.5}
local unManagedStationColor = {b = 1, a = 0.5}
Autoscheduling = {
    onRename = function(event)
        if (event.name == defines.events.on_entity_renamed) then
            destEntity = event.entity
            oldName = event.old_name
        else
        end

        -- Est-ce que la station appartient au réseau ?
        if isElligibleStation(event.entity) then
            -- Si la station est déjà managée c'est qu'on vient sûrement de la renommer, il faut donc couper cours pour éviter une récursion infinie de renommage
            if isSamePosition(stations[event.entity.backer_name], event.entity) then
                return
            end

            newName = createName(event.entity.backer_name)
            stations[newName] = event.entity
            event.entity.backer_name = newName

            event.entity.color = managedStationColor
        else
            event.entity.color = unManagedStationColor
        end

        -- Est-ce que la station appartenait au réseau ?
        if isElligibleName(event.old_name) then
            stations[event.old_name] = nil
        end
    end,
    onBuilt = function(event)
        -- Si le nom existe déjà il faudrait en recréer un, mais c'est pas avant la 0.17 normallement
        if isElligibleStation(destEntity) then
            destEntity.color = managedStationColor
        else
            event.created_entity.color = unManagedStationColor
        end
    end,
    onRemoved = function(event)
        debug(event)
    end,
    onTrainChangedState = function(event)
        -- Les trains en mode manuel ne sont pas éligible
        if event.train.manual_mode then
            return
        end

        -- Seuls les trains en route pour le parking sont réassignable
        if event.train.schedule.records[event.train.schedule.current] == cache["autoschedule_parking_name"] then
        -- Vérifier s'il faut recommencer leur mission

        -- Sinon vérifier s'il faut leur attribuer une nouvelle mision
        end

        -- Si on est arrivé au parking
        if true then
        -- Vider le planning
        -- Ajouter à la liste des idlsTrains
        end
    end,
    onStationStateUpdate = function(event)
        -- Pour chaque station gérée faire
        -- -- Si aucun train sur la route (entity.get_train_stop_trains()) se mettre sur la liste d'attente
    end,
    onTraiterListeAttente = function()
        -- Pour chaque entrée
    end
}

-- Retourne true si l'entité est une station, et est dans le scope de l'autoscheduling
isElligibleStation = function(entity)
    if (entity.name == "train-stop") then
        return isElligibleName(entity.backer_name)
    else
        return false
    end
end

isElligibleName = function(name)
    return string.find(name, ".+#[io].+") ~= nil
end

isSamePosition = function(entity_1, entity_2)
    if entity_1 == nil or entity_2 == nil then
        return false
    else
        return entity_1.position.x == entity_2.position.x and entity_1.position.y == entity_2.position.y
    end
end

createName = function(baseName)
    -- S'il y a déjà deux dièses
    if string.find(baseName, "#.*#") then
        return string.gsub(baseName, "(#.-#).*", "%1" .. math.random(100000))
    else
        -- Sinon on est dans le cas classique où on se contente d'une concaténation pour rajouter le second fameux dièse
        return baseName .. "#" .. math.random(100000)
    end
end
