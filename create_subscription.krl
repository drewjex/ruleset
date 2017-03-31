ruleset create_subscription {
  meta {
    use module io.picolabs.pico alias wrangler
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ ] }
  }

  rule create_subscription {
    select when pico new_child_request
      pre {
        eci = wrangler:children().map(function(v){v.eci})[wrangler:children().length()-1]
      }
      fired {
        raise wrangler event "subscription"
          with name = "new_vehicle"+eci
              name_space = "fleet"
              my_role = "fleet"
              subscriber_role = "vehicle"
              channel_type = "subscription"
              subscriber_eci = eci
      }
  }

  rule insert_rulesets {
    select when wrangler subscription 
    pre {
      eci = wrangler:children().map(function(v){v.eci})[wrangler:children().length()-1]
    }
    if eci then
      event:send(
      { "eci": eci, "eid": "install-ruleset",
        "domain": "pico", "type": "new_ruleset",
        "attrs": { "rid": "trip_store" } } )
      event:send(
      { "eci": eci, "eid": "install-ruleset",
        "domain": "pico", "type": "new_ruleset",
        "attrs": { "rid": "Subscriptions" } } )
      event:send(
      { "eci": eci, "eid": "install-ruleset",
        "domain": "pico", "type": "new_ruleset",
        "attrs": { "rid": "track_trips" } } )
    
  }
  
}