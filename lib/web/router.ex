defmodule Web.Router do
  use Web, :router

  # pipeline :browser do
  #   plug :accepts, ["html"]
  #   plug :fetch_session
  #   plug :fetch_flash
  #   plug :protect_from_forgery
  #   plug :put_secure_browser_headers
  # end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :api_game do
    plug(:accepts, ["json"])
    plug(:needs_game_token)
  end

  defp needs_game_token(conn, params) do
    case get_req_header(conn, "game-token") do
      [] ->
        conn
        |> send_resp(401, "You must provide a `game-token` header")
        |> halt

      [token] ->
        case Battleship.Registry.lookup(token) do
          {:ok, pid} ->
            assign(conn, :game, pid)

          _ ->
            conn
            |> send_resp(401, "Cannot find the game for that token")
            |> halt
        end
    end
  end

  # scope "/", Web do
  #   pipe_through :browser # Use the default browser stack

  #   get "/", PageController, :index
  # end

  # Other scopes may use custom stacks.
  scope "/", Web do
    pipe_through(:api)

    get("/", ApiController, :index)

    post("/new", ApiController, :new)
  end

  scope "/", Web do
    pipe_through(:api_game)

    put("/start/", ApiController, :start)

    put("/miss/", ApiController, :miss)

    put("/hit/", ApiController, :hit)

    put("/sunk/", ApiController, :sunk)

    delete("/leave/", ApiController, :leave)
  end
end
