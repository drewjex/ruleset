# ruleset

  rule add_vehicle_to_list {
    select when pico new_child_request 
      ent:fleet := ent:fleet.union([attrs])
  }

  event:send(
          { "eci": parent_eci, "eid": "subscription",
            "domain": "wrangler", "type": "subscription",
            "attrs": { "name": "new_vehicle",
                      "name_space": "fleet",
                      "my_role": "fleet",
                      "subscriber_role": "vehicle",
                      "channel_type": "subscription",
                      "subscriber_eci": eci } } )

                      rule create_subscription {
    select when pico new_child_request
    pre {
      eci = wrangler:children().map(function(v){v.eci})[wrangler:children().length()-1];
    }
      send_directive("say") with
            something = eci
  }

  cj0wzn3iu0001a4ga6omoqu4d


  rule add_to_list {
    select when wrangler subscription 
      pre {
        eci = wrangler:children().map(function(v){v.eci})[wrangler:children().length()-1]
      }
      send_directive("say") with
        something = eci
      fired {
        ent:vehicles := ent:vehicles.union([{"child" : wrangler:children()[wrangler:children().length()-1], "eci":eci}])
      }
  } 