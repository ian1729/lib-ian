# No public handle layer

`TcpSocket`, `TcpListener`, and `UdpSocket` own their file descriptors directly. A two-layer design (typed fd handles -> protocol types) was considered, but the handle types had no independent use in the public API, so fd management lives privately inside each socket type instead. Worth revisiting if a third protocol type (e.g. TLS) needs to share fd ownership with TCP.
