defmodule Wsserv.Util do

  def get_lsock(port) do
    :gen_tcp.listen(port, [:binary, active: false, packet: :http])
  end

  def get_echo_handler() do
    %{handle_text: fn(_wsservpid, _data) -> "### TEXT" end,
      handle_bin: fn(_, _) -> IO.puts "### BIN" end,
      handle_close: fn() -> IO.puts "### CLOSE" end}
  end


end
