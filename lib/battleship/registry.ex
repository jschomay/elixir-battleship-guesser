defmodule Battleship.Registry do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(name) do
    GenServer.call(__MODULE__, {:lookup, name})
  end

  def create(name, {cols, rows} = size) do
    GenServer.cast(__MODULE__, {:create, name, size})
  end

  ## 

  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  def handle_call({:lookup, name}, _from, {names, _} = state) do
    {:reply, Map.fetch(names, name), state}
  end

  def handle_cast({:create, name, size}, {names, refs}) do
    # TODO change to call and generate name to return
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      {:ok, pid} =
        DynamicSupervisor.start_child(
          Battleship.GameSupervisor,
          Supervisor.child_spec({Game, size}, restart: :temporary)
        )

      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, pid)
      {:noreply, {names, refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
