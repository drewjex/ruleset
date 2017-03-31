ruleset manage_fleet {
  meta {
    use module io.picolabs.pico alias wrangler
    use module Subscriptions
    shares __testing, get_vehicle_subs, get_vehicles, childFromECI
  }
  global {

    get_vehicle_subs = function() {
        Subscriptions:getSubscriptions().klog("Subscriptions:")
    }

    get_vehicles = function() {
      wrangler:children().klog("Vehicles:")
    }

    __testing = { "queries": [ { "name": "__testing" },
                                { "name": "get_vehicle_subs" },
                                { "name": "get_vehicles" }
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