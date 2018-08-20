(ns client.config)

(def debug?
  ^boolean goog.DEBUG)

(def server-url
     (if goog.DEBUG
        "http://localhost:4000/"
        "https://elixir-battleship-guesser.herokuapp.com/new/"))
