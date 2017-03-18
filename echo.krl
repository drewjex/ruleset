ruleset echo {
    meta {
        name "Echo"
        author "Drew Jex"
    }

    rule hello {
        select when echo hello
        send_directive("say") with
            something = "Hello World"
    }

    rule message is active {
        select when echo message input re#(.*)# setting(m);
        send_directive("say") with  
            something = m
    }   
}