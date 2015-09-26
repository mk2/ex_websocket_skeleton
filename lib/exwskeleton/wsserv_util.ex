defmodule ExWebsocketSkeleton.Wsserv.Util do

  def get_lsock(port) do
    :gen_tcp.listen(port, [:binary, active: false, packet: :http])
  end

end
