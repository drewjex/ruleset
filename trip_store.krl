ruleset trip_store {
    meta {
        name "Track Trips"
        author "Drew Jex"
        provides trips, long_trips, short_trips
        shares trips, long_trips, short_trips, __testing
    }

    global {
        trips = function() {
            ent:processed_trips.klog("Processed Trips:")
        }

        long_trips = function() {
            ent:long_trips.klog("Long Trips:")
        }

        short_trips = function() {
            c = ent:processed_trips.filter(function(x){x.mileage<4});
            c.klog("Short Trips:")
        }

        __testing = { "queries": [ { "name": "trips"},
                                   { "name": "long_trips"},
                                   { "name": "short_trips"},
                                   { "name": "__testing" } ]
         }
    }

    rule gather_report {
        select when fleet get_report
            pre {
                parent_eci = event:attr("parent_eci")
                attributes = {
                    "trips" : trips(),
                    "eci" : event:attr("current_eci"),
                    "correlation_id" : event:attr("correlation_id")
                }
            }
            if parent_eci then
            event:send(
              { "eci": parent_eci, "eid": 1556, 
                "domain": "car", "type": "collect_reports",
                 "attrs": attributes } )
            
    }

    rule collect_trips {
        select when explicit trip_processed
        pre {
            attrs = {
                "mileage" : event:attr("attrs").mileage,
                "timestamp" : time:now()
            }
        }
        fired {
            ent:processed_trips := ent:processed_trips.union([attrs])
        }
    }

    rule collect_long_trips {
        select when explicit found_long_trip
        pre {
            attrs = {
                "mileage" : event:attr("mileage"),
                "timestamp" : time:now()
            }
        }
        fired {
            ent:long_trips := ent:long_trips.union([attrs])
        }
    }

    rule clear_trips {
        select when car trip_reset
        always {
            ent:processed_trips := [];
            ent:long_trips := []
        }
    }
}