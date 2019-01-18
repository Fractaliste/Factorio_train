function debug(o)
    log(serpent.block(o))
end

function getCurrentRecord(train)
    --log(debug.traceback())
    return train.schedule.records[train.schedule.current]
end

function init_cache()
    -- Station de refueling
    cache["refueling_station_name"] = settings.global["raphikitrain_refueling_station_name"].value
    refuelingStationScheduleRecord.station = cache["refueling_station_name"]

    -- Seuil de refueling
    cache["refueling_cutoff"] = settings.global["raphikitrain_refueling_cutoff"].value

    -- Coeff de refueling
    cache["refueling_coeff"] = {}
    cache["refueling_coeff"]["wood"] = settings.global["raphikitrain_refueling_wood_coeff"].value
    cache["refueling_coeff"]["raw-wood"] = settings.global["raphikitrain_refueling_raw-wood_coeff"].value
    cache["refueling_coeff"]["small-electric-pole"] =
        settings.global["raphikitrain_refueling_small-electric-pole_coeff"].value
    cache["refueling_coeff"]["wooden-chest"] = settings.global["raphikitrain_refueling_wooden-chest_coeff"].value
    cache["refueling_coeff"]["coal"] = settings.global["raphikitrain_refueling_coal_coeff"].value
    cache["refueling_coeff"]["solid-fuel"] = settings.global["raphikitrain_refueling_solid-fuel_coeff"].value
    cache["refueling_coeff"]["rocket-fuel"] = settings.global["raphikitrain_refueling_rocket-fuel_coeff"].value
    cache["refueling_coeff"]["nuclear-fuel"] = settings.global["raphikitrain_refueling_nuclear-fuel_coeff"].value

    -- Autoschedule
    cache["autoschedule_enabled"] = settings.global["raphikitrain_autoschedule_enabled"].value
    cache["autoschedule_parking_name"] = settings.global["raphikitrain_autoschedule_parking_name"].value

    -- Helper
    debug(cache)
end
