ExWebsocketSkeleton
===================

# なにこれ
ElixirによるWebsocketプロトコルのサーバーサイド実装です。
まだ完全にWebsocketの仕様を完全に満たせていませんが、今後実装する予定です。

# 使い方

## iexを立ち上げる
```sh
$ cd (クローンしたリポジトリ)
$ iex -S mix
```

## Websocketサーバーを立ち上げる
```elixir
body = %{
  handle_text: fn(wsservpid, text) -> IO.inspect {:'text', text}; ExWebsocketSkeleton.send_text(wsservpid, text) end,
  handle_bin: fn(_, _) -> IO.puts "not implemented" end,
  handle_close: fn() -> IO.puts "connection closed" end
}
ExWebsocketSkeleton.start_link body
```

## http://www.websocket.org/echo.html からつなぐ
`ws://localhost:8081`へ接続し、適当に文字を投げてください。エコーが返ってきます。

# 未実装な項目
- OPCODEが0x0(continuation)の場合におけるdataframeのエンコード/デコード
- OPCODEが0x2(binary frame)の場合におけるdataframeのエンコード/デコード
