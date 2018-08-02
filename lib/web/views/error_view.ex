defmodule Web.ErrorView do

  def render("404.json", _assigns) do
    %{errors: %{message: "Not Found"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{message: "Server Error"}}
  end

  def render("404.html", _assigns) do
    "Not found"
  end

  def render("500.html", _assigns) do
    "Server error"
  end
end
