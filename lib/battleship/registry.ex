defmodule Battleship.Registry do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(name) do
    GenServer.call(__MODULE__, {:lookup, name})
  end

  def new({cols, rows} = size) do
    GenServer.call(__MODULE__, {:new, size})
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

  def handle_call({:new, size}, _from, {names, refs}) do
    name = UUID.uuid1()

    {:ok, pid} =
      DynamicSupervisor.start_child(
        Battleship.GameSupervisor,
        Supervisor.child_spec({Game, size}, restart: :temporary)
      )

    ref = Process.monitor(pid)
    refs = Map.put(refs, ref, name)
    names = Map.put(names, name, pid)
    {:reply, name, {names, refs}}
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
