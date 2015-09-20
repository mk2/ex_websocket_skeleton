defmodule WsservTest do
  use ExUnit.Case, async: false
  require Logger

  test "start wsserv" do
    port = 8081
    {:ok, lsock} = Wsserv.Util.get_lsock(port)
    {:ok, _} = Wsserv.start_link(lsock, fn(_) -> Logger.debug "handler called" end)
    {:ok, csock} = :gen_tcp.connect(:localhost, port, [])
    :gen_tcp.send csock, "ok my first message"
    :timer.sleep 3000
    assert pid != nil
  end

end
