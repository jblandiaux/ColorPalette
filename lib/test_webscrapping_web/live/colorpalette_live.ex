defmodule TestWebscrappingWeb.ColorpaletteLive do
  use TestWebscrappingWeb, :live_view


  # mount

  def mount(_params, _session, socket) do
    socket = assign(socket, brightness: 10)
    {:ok, socket}
  end

  # render
  def render(assigns) do
    ~H"""
    <h1> Color Palette finder </h1>
    """
  end

  #handle_event


end
