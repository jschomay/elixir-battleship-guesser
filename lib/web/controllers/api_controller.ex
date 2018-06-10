defmodule Web.ApiController do
  use Web, :controller

  def index(conn, _params) do
    text(conn, "This is the api server, start a new game with POST /new/:cols/:rows")
  end

  @doc """
  Create a new game (with the given cols/rows).

      curl -X POST -H "Content-Type: application/json" -d '{"cols": 3, "rows": 4}' localhost:4000/new

  Responds with an id and empty game object (`plays` will be an empty array, and `guess` will be nil).

      {"id": "YOUR_TOKEN", "game": YOUR_GAME}

  Example game object:

      {"size": {"cols": 8, "rows": 8},
       "plays": [{"col": 3, "row": 4, "status": "hit"}],
       "guess": {"col": 3, "row": 5}
      }

  Where `status` will be either `"hit"` or `"miss"`.
  """
  def new(conn, %{"cols" => cols, "rows" => rows}) do
    name = Battleship.Registry.new({cols, rows})
    {:ok, pid} = Battleship.Registry.lookup(name)

    json(conn, %{id: name, game: Battleship.Game.to_json(pid)})
  end

  def new(conn, _params) do
    new(conn, %{"cols" => 8, "rows" => 8})
  end

  @doc """
  Starts the game, meaning the AI will make an initial guess.  Responds with a "game object".  

      curl -X PUT -H "Content-Type: application/json" -H "game-token: MY_TOKEN" localhost:4000/start/

  Requires a `game-token` header.

  Only use this when ready for the first guess.  After that use the `miss`, `hit`, and `sunk` endpoints, which will update the board and trigger a new guess.
  """
  def start(conn, params) do
    conn.assigns[:game]
    |> Battleship.Game.make_guess()

    json(conn, Battleship.Game.to_json(conn.assigns[:game]))
  end

  @doc """
  Same as start, but marks a miss.
  """
  def miss(conn, params) do
    conn.assigns[:game]
    |> Battleship.Game.miss()

    conn.assigns[:game]
    |> Battleship.Game.make_guess()

    json(conn, Battleship.Game.to_json(conn.assigns[:game]))
  end

  @doc """
  Same as start, but marks a hit.
  """
  def hit(conn, params) do
    conn.assigns[:game]
    |> Battleship.Game.hit()

    conn.assigns[:game]
    |> Battleship.Game.make_guess()

    json(conn, Battleship.Game.to_json(conn.assigns[:game]))
  end

  @doc """
  Same as start, but marks a sunk AND requires a body of `"{size: 3}"` to denote the size of the ship that was sunk.
  """
  def sunk(conn, %{"size" => size}) do
    conn.assigns[:game]
    |> Battleship.Game.sunk(size)

    conn.assigns[:game]
    |> Battleship.Game.make_guess()

    json(conn, Battleship.Game.to_json(conn.assigns[:game]))
  end

  @doc """
  Deletes the game.  Requires a "game-token" header.
  """
  def leave(conn, params) do
    conn.assigns[:game]
    |> Battleship.Game.stop()

    send_resp(conn, 204, "")
  end
end
