# Battleship Guesser (demonstrating the [Elixir Behavior Tree AI](https://hexdocs.pm/behavior_tree/api-reference.html) library)

A demo using my [Elixir Behavior Tree AI Library](https://hexdocs.pm/behavior_tree/api-reference.html) to make an AI that plays [Battleship](https://en.wikipedia.org/wiki/Battleship_(game)).

## Front end

A clojurescript client that provides a UI for defining the game board size, placing your ships, and playing out the AI's guesses.

It uses CSS grid to map the server data into a view, with a lot of help from the re-frame library for the interactivity.

**You can [play it live](https://jschomay.github.io/elixir-battleship-guesser/).**

(Note that it takes a few minutes for the heroku server to spin up sometimes.)


## back end

The backend is written in Elixir as an OTP app with a Phoenix RESTful api.

You use it in 2 ways:

1) Via the command line script (see Releases)
2) Via a RESTful web server (hosted on Heroku, instructions below):

### Create a new game

You need to supply the board dimensions.

    curl -X POST -H "Content-Type: application/json" -d '{"cols": 3, "rows": 4}' https://elixir-battleship-guesser.herokuapp.com/new/

Responds with an id and empty game object (`plays` will be an empty array, and `guess` will be nil).

    {"id": "YOUR_TOKEN", "game": GAME_OBJECT}

Example game object:

    {"size": {"cols": 8, "rows": 8},
     "plays": [{"col": 3, "row": 4, "status": "hit"}],
     "guess": {"col": 3, "row": 5}
    }

Where `status` will be either `"hit"` or `"miss"`.


### Start the game

This will tell the AI will make the initial guess.  Responds with a "game object" as above.  

    curl -X PUT -H "Content-Type: application/json" -H "game-token: YOUR_TOKEN" https://elixir-battleship-guesser.herokuapp.com/start/

Only use this when ready for the first guess.  After that use the `miss`, `hit`, and `sunk` endpoints, which will update the board and trigger a new guess.

### Miss/Hit/Sunk

Same usage as `/start/` endpoint (just replace the final path segment with `miss`, `hit`, or `sunk`.

Note, for `sunk`, you must also supply a body of `-d "{size: SHIP_SIZE}"` to denote the size of the ship that was sunk.


### Leave/delete game

    curl -X DELETE -H "Content-Type: application/json" -H "game-token: YOUR_TOKEN" https://elixir-battleship-guesser.herokuapp.com/leave/

Responds with status code `204`.
