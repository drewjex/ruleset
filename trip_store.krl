ruleset trip_store {
    meta {
        name "Track Trips"
        author "Drew Jex"
        shares trips
    }

    global {
        trips = ent:processed_trips
    }

    rule collect_trips {
        select when explicit trip_processed
        pre {
            m = event:attr("attrs").mileage
        }
        fired {
            ent:processed_trips.defaultsTo([])
            ent:processed_trips := ent:processed_trips.union([{"mileage": m, "timestamp":timestamp}])
        }
    }

    rule collect_long_trips {
        select when explicit found_long_trip
        pre {
            m = event:attr("attrs").mileage
        }
        fired {
            ent:long_trips.defaultsTo([])
            ent:long_trips := ent:long_trips.union([{"mileage": m, "timestamp":timestamp}])
        }
    }

    rule clear_trips {
        select when car trip_reset
        always {
            ent:processed_trips := []
            ent:long_trips := []
        }
    }
}