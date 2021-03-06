defmodule ExWebsocketSkeleton do
  alias ExWebsocketSkeleton.Wsserv
  alias ExWebsocketSkeleton.Wsserv.Supervisor

  def start_link(body) do
    Supervisor.start_link(body)
  end

  def send_text(wsservpid, text) do
    Wsserv.send_text(wsservpid, text)
  end


end
