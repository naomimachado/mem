defmodule MemoryWeb.MemoryChannel do
  use MemoryWeb, :channel

  alias Memory.Game

  def join("memory:" <> name, payload, socket) do
    game = Memory.GameBackup.load(name) || Game.new

    socket = socket
    |> assign(:game, game)
    |> assign(:name, name)

    if authorized?(payload) do
      {:ok,  %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("clicked", %{"card" => c}, socket) do
    game = Game.clicked(socket.assigns[:game], c)
    socket = assign(socket, :game, game)
    Memory.GameBackup.save(socket.assigns[:name], socket.assigns[:game])
    socket = assign(socket, :game, game)
    if game.flipped == 2 do
      {:reply, {:flip, %{ "game" => Game.client_view(game) }}, socket}
    else
      {:reply, {:ok, %{ "game" => Game.client_view(game) }}, socket}
    end
  end

  def handle_in("flip", %{}, socket) do
    game = Game.resetBoard(socket.assigns[:game])
    socket = assign(socket, :game, game)
    Memory.GameBackup.save(socket.assigns[:name], socket.assigns[:game])
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  # Sends a reset request
  def handle_in("reset", %{}, socket) do
    game = Game.new()
    socket = assign(socket, :game, game)
    Memory.GameBackup.save(socket.assigns[:name], socket.assigns[:game])
    {:reply, {:ok, %{ "game" => Game.client_view(game) }}, socket}
  end


  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (memory:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
