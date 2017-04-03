ruleset manage_fleet {
  meta {
    use module io.picolabs.pico alias wrangler
    use module Subscriptions
    shares __testing, get_vehicle_subs, get_vehicles, get_trips, trip_test, get_reports
  }
  global {

    get_vehicle_subs = function() {
        Subscriptions:getSubscriptions().klog("Subscriptions:")
    }

    get_vehicles = function() {
      wrangler:children().klog("Vehicles:")
    }

    get_trips = function() {
      cloud_url = "http://localhost:8080/sky/cloud/";
      wrangler:children().map(function(v){
         response = http:get("http://localhost:8080/sky/cloud/"+v.eci+"/trip_store/trips");
         response.content.klog()
      })
    }

    get_reports = function() {
       ent:report.klog("Reports from the fleet:")
    }

    trip_test = function(eci) {
      response = http:get("http://localhost:8080/sky/cloud/"+eci+"/trip_store/trips");
      response.klog("result:")
    }

    __testing = { "queries": [ { "name": "__testing" },
                                { "name": "get_vehicle_subs" },
                                { "name": "get_vehicles" },
                                { "name": "get_trips"},
                                { "name": "trip_test", "args": [ "eci" ]},
                                { "name": "get_reports"}
                                ],
                  "events": [ ] }
  }

  rule create_vehicle {
    select when car new_vehicle
      fired {
        raise pico event "new_child_request"
          attributes { "dname": "new_vehicle", "color": "#FF69B4", "attrs": event:attrs()}
      }
  }

  rule delete_test {
    select when car delete_test 
    fired {
      raise pico event "delete_child_request"
          attributes {
    "id": "cj0yc6kwl001c2wgamsxbefj6",
    "eci": "cj0yc6kwn001d2wgapurscrh9"
          }
    }
  }

  rule delete_vehicle {
    select when car unneeded_vehicle eci re#(.*)# setting(m);
      pre {
        id = wrangler:children().filter(function(v){v.eci == m})[0].id
        eci = wrangler:children().filter(function(v){v.eci == m})[0].eci
      }
      send_directive("say") with
        something = id
      fired {
        raise pico event "delete_child_request"
          attributes {"id":id, "eci": eci}
      }
  }

  rule delete_subscription {
    select when pico delete_child_request
      pre {
        eci = event:attr("eci")
      }
      fired {
        raise wrangler event "subscription_cancellation"
          with subscription_name = "new_vehicle"+eci
      }
  }

  rule autoAccept {
    select when wrangler inbound_pending_subscription_added
     pre{
       attributes = event:attrs().klog("subcription :")
     }
     always {
       raise wrangler event pending_subscription_approval
          attributes attributes  
     }
  }

  rule generate_report {
    select when car generate_report
      pre {
        attrs = {
          "correlation_id" : "crlid"
        }
        counter = 0
      }
      fired {
        raise car event "scatter_gather" attributes attrs
      }
  }
 
  rule scatter_gather {
    select when car scatter_gather
      foreach wrangler:children().map(function(v){v.eci}) setting(x)
        pre {
          attributes = {
            "correlation_id" : event:attr("correlation_id"),
            "parent_eci" : wrangler:myself().eci,
            "current_eci" : x
          }
        }
        if x then
          event:send(
      { "eci": x, "eid": 1556, 
        "domain": "fleet", "type": "get_report",
        "attrs": attributes } )
        
  }

  rule collect_reports {
    select when car collect_reports 
      pre {
        attrs = {
          "trips" : event:attr("trips"),
          "eci": event:attr("eci"),
          "correlation_id" : event:attr("correlation_id")
        }
      }
      fired {
        ent:report := ent:report.union([attrs]);
        ent:counter := ent:counter + 1
      }
  }

  rule test_subscription {
    select when test subscription 
      fired {
        event:send(
          { "eci": wrangler:myself().eci, "eid": "subscription",
            "domain": "wrangler", "type": "subscription",
            "attrs": { "name": "new_vehicle",
                      "name_space": "fleet",
                      "my_role": "fleet",
                      "subscriber_role": "vehicle",
                      "channel_type": "subscription",
                      "subscriber_eci": "cj0x4ijf5001va4gawyu8ay80" } } )
      }
  }

  rule test_subscription_2 {
    select when test subscription2 
      fired {
        raise wrangler event "subscription"
          with name = "new_vehicleasdf"
              name_space = "fleet"
              my_role = "fleet"
              subscriber_role = "vehicle"
              channel_type = "subscription"
              subscriber_eci = "cj0x4ijf5001va4gawyu8ay80"
      }
    
  }

   rule clear_trips {
        select when car trip_reset
        always {
            ent:fleet := []
        }
    }
}