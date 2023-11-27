# Shimakaze - Discord Websocket Gateway/Proxy

Handles connecting to Discord WS and staying connected

## Notes
alpha quality software

oh yeah the libraries that this depends on are also alpha quality software

btw the programming language used is also alpha quality (zig master)

also this doesnt build at all

## Dependencies
 - websocket.zig - websocket client
 - libxev - timers and event loop

## Outgoing Payloads Handled
 - Identify
 - Resume
 - Heartbeat
 - Update Presence - depends on config

## Outgoing Payloads Read from Queue
 - Request Guild Member - depends on caching strategy
 - Update Voice State - or handled by voice sender

## Incoming Payloads Handled
 - Hello
 - Ready
 - Resumed
 - Reconnect
 - Invalid Session

## Incoming Payloads Dumped to Cache - depends on config
 - Events with Message prefix
 - Events with Guild prefix

## Incoming Payloads Dumped to Queue - depends on config
 - Everything else