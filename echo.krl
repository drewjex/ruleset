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

    rule message {
        select when echo message input
        send_directive("say") with  
            something = input
    }   
}