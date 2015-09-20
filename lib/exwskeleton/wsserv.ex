defmodule Wsserv do
  use GenServer
  require Logger
  require Record

  @tag Atom.to_string(__MODULE__)

  @websocket_prefix        "HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: upgrade\r\nSec-Websocket-Accept: "
  @websocket_append_to_key "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"

  @fin_on  0x1
  @fin_off 0x0

  @rsv_on  0x1
  @rsv_off 0x0

  @opcode_continue 0x0
  @opcode_text     0x1
  @opcode_bin      0x2
  @opcode_close    0x8
  @opcode_ping     0x9
  @opcode_pong     0xA

  @mask_on  0x1
  @mask_off 0x0

  @payload_length_normal    125
  @payload_length_extend_16 126
  @payload_length_extend_64 127
  @max_unsigned_integer_16  65532
  @max_unsigned_integer_64  9223372036854775807

  Record.defrecord :dataframe,
    fin: @fin_off,
    rsv1: @rsv_off, rsv2: @rsv_off, rsv3: @rsv_off,
    opcode: @opcode_text,
    mask: @mask_off,
    pllen: 0x0,
    maskkey: 0x0,
    data: nil,
    msg: nil

  Record.defrecord :servstat,
    lsock: nil,
    csock: nil,
    puid: nil,
    dataframe: nil,
    handlers: nil

  #################
  # API Functions #
  #################

  def start_link(lsock, handlers) do
    GenServer.start_link(__MODULE__, [lsock, handlers])
  end

  #######################
  # GenServer Callbacks #
  #######################

  @doc """
  """
  def init([lsock, handlers]) do
    Logger.metadata tag: @tag
    Logger.debug "init in"
    Process.flag :trap_exit, true
    GenServer.cast self, :accept
    {:ok, servstat(lsock: lsock, handlers: handlers)}
  end

  @doc """
  """
  def handle_info({:tcp, _, _msg}, state) do
    {:noreply, servstat(state, dataframe: nil)}
  end

  @doc """
  """
  def handle_info({:tcp_closed, _}, state) do
    Logger.error "tcp connection closed"
    {:stop, :normal, state}
  end

  @doc """
    メッセージ受け取りのエントリーポイント
  """
  def handle_info({:tcp_error, _, _}, state) do
    Logger.error "an error on tcp connection"
    {:stop, :normal, state}
  end

  @doc """
  """
  def handle_info(_, state) do
    Logger.error "unknown error on tcp connection"
    {:noreply, state}
  end

  @doc """
  """
  def handle_cast(:accept, state) do
    Logger.debug "waiting for connection"
    {:ok, csock} = :gen_tcp.accept(servstat(state, :lsock))
    case do_handshake(csock, HashDict.new) do
      {:ok, _} ->
        Logger.info "handshake passed"
        :inet.setopts(csock, [packet: :raw, active: :once])
        {:noreply, servstat(state, csock: csock)}
      {:stop, reason, _} -> {:stop, reason, state}
      _ -> {:stop, "failed handshake with unknown reason", state}
    end
  end

  ####################
  # Module functions #
  ####################

  defp do_handshake(csock, headers) do
    case :gen_tcp.recv(csock, 0) do
      {:ok, {:http_request, _method, {:abs_path, path}, _version}} -> do_handshake(csock, Dict.put(headers, :path, path))
      {:ok, {:http_header, _, httpField, _, value}} ->
        hkey = {:http_field, httpField}
        do_handshake(csock, Dict.put(headers, hkey, value))
      {:error, "\r\n"} -> do_handshake(csock, headers)
      {:error, "\n"} -> do_handshake(csock, headers)
      {:ok, :http_eoh} ->
        verify_handshake(csock, headers)
        {:ok, [{:headers, headers}]}
      others ->
        Logger.info "unknown msg"
        {:stop, :unknown_header, [headers: headers, msg: others]}
    end
  end

  defp verify_handshake(csock, headers) do
    try do
      "websocoket" = Dict.get(headers, {:http_field, :'Upgrade'}, "") |> String.downcase()
      "upgrade" = Dict.get(headers, {:http_field, :'Connection'}, "") |> String.downcase()
      "13" = Dict.get(headers, {:http_field, :'Sec-Websocket-Version'}, "") |> String.downcase()
      true = Dict.has_key?(headers, {:http_field, :'Sec-Websocket-Key'})
      send_handshake(csock, headers)
    catch
      _ -> Logger.error "an error during verification handshake"
    end
  end

  defp send_handshake(csock, headers) do
    swkey = Dict.get(headers, {:http_field, :'Sec-Websocket-Key'}, "")
    acceptHeader = swkey |> make_accept_header_value
                         |> (fn(acceptHeaderValue) -> @websocket_prefix <> acceptHeaderValue <> "\r\n\r\n" end).()
    :gen_tcp.send(csock, acceptHeader)
  end

  defp make_accept_header_value(swkey) do
    swkey <> @websocket_append_to_key |> (fn(k) -> :crypto.hash(:sha, k) end).() |> :base64.encode_to_string()
  end

  defp extract_mask_key(rawmsg) do

  end

end
