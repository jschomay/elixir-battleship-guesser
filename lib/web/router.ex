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
    plug :accepts, ["json"]
  end

  # scope "/", Web do
  #   pipe_through :browser # Use the default browser stack

  #   get "/", PageController, :index
  # end

  # Other scopes may use custom stacks.
  scope "/", Web do
    pipe_through :api

    get "/", ApiController, :index

    get "/new", ApiController, :new

    get "/new/:cols/:rows", ApiController, :new
  end
end
