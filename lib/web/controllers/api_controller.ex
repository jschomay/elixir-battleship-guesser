defmodule Web.ApiController do
  use Web, :controller

  def index(conn, _params) do
    text conn, "This is the api server, start a new game with /new"
  end

  def new(conn, %{"cols" => cols, "rows" => rows}) do
    name = Battleship.Registry.new {cols, rows}
    json conn, %{id: name}
  end

  def new(conn, _params) do
    new conn, %{"cols" => 8, "rows" => 8}
  end

end
