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

  def start_link(wsservpid, body = %{handle_text: _, handle_bin: _, handle_close: _}) do
    {:ok, hdlpid} = GenEvent.start_link
    GenEvent.add_handler(hdlpid, __MODULE__, [wsservpid, hdlpid, body])
    {:ok, hdlpid}
  end

  def start_link(_, _) do
    raise "not enough arguments"
  end

  def notify_text(hdlpid, data) do
    GenEvent.ack_notify(hdlpid, {:text, data})
  end

  def notify_bin(hdlpid, data) do
    GenEvent.ack_notify(hdlpid, {:bin, data})
  end

  def notify_close(hdlpid) do
    GenEvent.ack_notify(hdlpid, :close)
  end

  ######################
  # GenEvent callbacks #
  ######################

  def init([wsservpid, hdlpid, body]) do
    Logger.metadata tag: @tag
    Logger.debug "Wsserv.Handler start"
    {:ok, hdlstat(wsservpid: wsservpid, hdlpid: hdlpid, body: body)}
  end

  def handle_event({:text, data}, state = hdlstat(wsservpid: wsservpid, body: body)) do
    body[:handle_text].(wsservpid, data)
    {:ok, state}
  end

  def handle_event({:bin, data}, state = hdlstat(wsservpid: wsservpid, body: body)) do
    body[:handle_bin].(wsservpid, data)
    {:ok, state}
  end

  def handle_event(:close, hdlstat(body: body)) do
    body[:handle_close].()
    :remove_handler
  end

  ####################
  # Module functions #
  ####################

end
