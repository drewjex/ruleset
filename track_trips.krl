ruleset track_trips {
    meta {
        name "Track Trips"
        author "Drew Jex"
        shares __testing
    }

    global {
        __testing = { "events": [ { "domain": "track_trips", "type": "process_trip" ,
                                "attrs": [ "mileage" ] } ] }
    }

    rule process_trip is active {
        select when echo message mileage re#(.*)# setting(m);
        send_directive("trip") with  
            trip_length = m
    }
}