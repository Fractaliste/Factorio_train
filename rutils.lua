function debug(o)
    log(serpent.block(o))
end

function init_cache()
    -- Station de refueling
    cache["refueling_station_name"] = settings.global["raphikitrain_refueling_station_name"].value
    refuelingStationScheduleRecord.station = cache["refueling_station_name"]

    -- Helper
    debug(cache)
end
