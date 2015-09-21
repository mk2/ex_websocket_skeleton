defmodule Wsserv.Handler do
  use GenEvent
  require Logger
  require Record

  @tag Atom.to_string(__MODULE__)

  Record.defrecord :hdlstat,
    wsservpid: nil,
    hdlpid:    nil,
    body:      nil

  #################
  # API functions #
  #################

  def start_link(wsservpid, body) do
    {:ok, hdlpid} = GenEvent.start_link
    GenEvent.add_handler(hdlpid, __MODULE__, [wsservpid, hdlpid, body])
    {:ok, hdlpid}
  end

  def notify_to_body do

  end

  def notify_to_wsserv do

  end


  ######################
  # GenEvent callbacks #
  ######################

  def init([wsservpid, hdlpid, body]) do
    Logger.metadata tag: @tag
    Logger.debug "Wsserv.Handler start"
    {:ok, hdlstat(wsservpid: wsservpid, hdlpid: hdlpid, body: body)}
  end

  ####################
  # Module functions #
  ####################

end
