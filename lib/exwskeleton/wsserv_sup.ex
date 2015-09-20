defmodule Wsserv.Supervisor do
  use Supervisor
  require Logger

  @tag Atom.to_string(__MODULE__)

  #################
  # API functions #
  #################

  def start_link(handlers) do
    Supervisor.start_link(__MODULE__, handlers)
  end

  def start_wsserv() do
    Supervisor.start_child(__MODULE__, [])
  end


  ########################
  # Superviser callbacks #
  ########################

  def init(handlers) do
    Logger.metadata tag: @tag
    Logger.debug "init in"
    port = Application.get_env(:ex_websocket_skeleton, :port, 8081)
    {:ok, lsock} = Wsserv.Util.get_lsock(port)
    spawn_link &empty_wsservs/0
    [worker(Wsserv, [lsock, handlers], restart: :temporary)] |> supervise(strategy: :simple_one_for_one)
  end

  ####################
  # Module functions #
  ####################

  defp empty_wsservs do
    Logger.debug "empty_wsservs in"
    for _ <- 1..20, do: start_wsserv()
  end

end
