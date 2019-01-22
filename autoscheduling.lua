do
    local stations
    local trains

    local isElligibleName
    local createName
    local goAndStayToParking
    local indexStation
    local getIndexedEntityByName

    local copingStationsBuffer = {}
    i = 0
    local managedStationColor = {g = 1, a = 0.5}
    local unManagedStationColor = {b = 1, a = 0.5}
    Autoscheduling = {
        onLoad = function()
            stations = global.s
            trains = global.t
        end,
        onRename = function(event)
            local old_name = nil
            local station_entity = nil
            if (event.name == defines.events.on_pre_entity_settings_pasted) then
                if (event.destination.name ~= "train-stop") then
                    -- On ne s'occupe que des stations
                    return
                end -- Nécessaire pour avoir accès à l'ancien nom en cas de copier/coller
                if (copingStationsBuffer[event.destination.backer_name] == nil) then
                    copingStationsBuffer[event.destination.backer_name] = {}
                end
                table.insert(copingStationsBuffer[event.destination.backer_name], event.destination)
                return
            elseif (event.name == defines.events.on_entity_settings_pasted) then
                -- En cas de copier/coller de stations
                if (event.destination.name ~= "train-stop") then
                    -- On ne s'occupe que des stations
                    return
                end
                for k, v in pairs(copingStationsBuffer) do
                    for _, vv in pairs(copingStationsBuffer) do
                        if vv == event.destination then
                            copingStationsBuffer[k][_] = nil
                            station_entity = event.destination
                            old_name = k
                            break
                        end
                    end
                end
            elseif (event.name == defines.events.on_entity_renamed) then
                -- En cas de renommage explicite
                if (event.entity.name ~= "train-stop") then
                    -- On ne s'occupe que des stations
                    return
                end
                station_entity = event.entity
                old_name = event.old_name
            end

            if (station_entity == nil or old_name == nil) then
                debug("Erreur d'event ne gérant pas correctement le rename")
                debug(event)
                return
            end
            if (i > 1) then
                return
            end

            -- Est-ce que la station appartient au réseau ?
            if isElligibleName(station_entity.backer_name) then
                -- Si la station est déjà managée c'est qu'on vient sûrement de la renommer, il faut donc couper cours pour éviter une récursion infinie de renommage
                if isSamePosition(getIndexedEntityByName(station_entity.backer_name), station_entity) then
                    return
                end
                i = i + 1
                newName = createName(station_entity.backer_name)
                indexStation(station, newName)
                station_entity.backer_name = newName

                station_entity.color = managedStationColor
            else
                station_entity.color = unManagedStationColor
            end

            -- Est-ce que la station appartenait au réseau ?
            if isElligibleName(old_name) then
                indexStation(nil, old_name)
            end
        end,
        onBuilt = function(event)
            local created_entity = event.created_entity

            -- Si le nom existe déjà il faudrait en recréer un, mais c'est pas avant la 0.17 normallement
            if created_entity.name == "train-stop" then
                if isElligibleName(created_entity.backer_name) then
                    destEntity.color = managedStationColor
                else
                    created_entity.color = unManagedStationColor
                end
            end
        end,
        onRemoved = function(event)
            debug("removed")
            -- debug(stations)
        end,
        onTrainChangedState = function(event)
            local train = event.train
            -- Les trains en mode manuel ou sans planif ne sont pas éligible
            if train.manual_mode then
                return
            end

            if train.schedule == nil then
                goAndStayToParking(train)
                return
            end

            -- Seuls les trains en route pour le parking sont réassignable
            debug(case[train.state] .. "train" .. getCurrentRecord(train).station)
            if getCurrentRecord(train).station == cache["autoschedule_parking_name"] then
                debug("Idle train")
                debug(stations)
                -- Vérifier s'il faut recommencer leur mission
                -- Sinon vérifier s'il faut leur attribuer une nouvelle mission
                -- for _, s in pairs(stations.liste) do
                --     debug(s.get_train_stop_trains())
                -- end

                -- Si on est arrivé au parking
                if train.state == defines.train_state.wait_station then
                    goAndStayToParking(train)
                end
            end
        end,
        onStationStateUpdate = function(event)
            -- Pour chaque station gérée faire
            -- -- Si aucun train sur la route (entity.get_train_stop_trains()) se mettre sur la liste d'attente
        end,
        onTraiterListeAttente = function()
            for _, s in pairs(trains.idle) do
                debug(s.valid)
            end
        end
    }

    goAndStayToParking = function(train)
        debug("goAndStayToParking")
        -- Vider le planning
        train.schedule = {current = 1, records = {{station = cache["autoschedule_parking_name"]}}}
        -- Ajouter à la liste des idlsTrains
        table.insert(trains.idle, train)
    end

    -- Retourne true si l'entité possède un nom correspondant au pattern de l'autoscheduling
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
        local i = stations.nextInt
        stations.nextInt = i + 1
        -- S'il y a déjà deux dièses
        if string.find(baseName, "#.*#") then
            return string.gsub(baseName, "(#.-#).*", "%1" .. i)
        else
            -- Sinon on est dans le cas classique où on se contente d'une concaténation pour rajouter le second fameux dièse
            return baseName .. "#" .. i
        end
    end

    indexStation = function(station, name)
        debug("indexing " .. name)
        local debut, fin = name:find("#.*#")
        local id = name:sub(debut + 2, fin - 1)
        if stations.index[id] == nil then
            stations.index[id] = {i = {}, o = {}}
        end
        stations.index[id][name:sub(debut + 1, debut + 1)][name] = station
        if (station ~= nil) then
            Fifo.push(stations.fifo, station)
        end
    end

    getIndexedEntityByName = function(name)
        local debut, fin = name:find("#.*#")
        if debut == nil then
            debut, fin = name:find("#.*")
        end
        local id = name:sub(debut + 2, fin - 1)
        if stations.index[id] == nil then
            return nil
        else
            a = stations.index[id][name:sub(debut + 1, debut + 1)][name]
            return a
        end
    end
end
