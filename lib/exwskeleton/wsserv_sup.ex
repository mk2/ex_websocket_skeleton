defmodule ExWebsocketSkeleton.Wsserv.Supervisor do
  use Supervisor
  alias ExWebsocketSkeleton.Wsserv
  alias ExWebsocketSkeleton.Wsserv.Util
  require Logger

  @tag Atom.to_string(__MODULE__)

  #################
  # API functions #
  #################

  def start_link(body) do
    Supervisor.start_link(__MODULE__, [body], [name: __MODULE__])
  end

  def start_wsserv() do
    Logger.debug "start_wsserv in"
    Supervisor.start_child(__MODULE__, [])
    Logger.debug "start_wsserv out"
  end


  ########################
  # Superviser callbacks #
  ########################

  def init([body]) do
    Logger.metadata tag: @tag
    Logger.debug "init in"
    port = Application.get_env(:ex_websocket_skeleton, :port, 8081)
    {:ok, lsock} = Util.get_lsock(port)
    spawn_link &empty_wsservs/0
    children = [worker(Wsserv, [lsock, body], restart: :temporary)]
    supervise(children, strategy: :simple_one_for_one)
  end

  ####################
  # Module functions #
  ####################

  defp empty_wsservs do
    Logger.debug "empty_wsservs in"
    for _ <- 1..20, do: start_wsserv()
  end

end
