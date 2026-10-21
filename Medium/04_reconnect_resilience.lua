-- 04_reconnect_resilience.lua
-- Connects, disconnects, then reconnects and handshakes again.
-- Demonstrates reconnection handling.
-- Difficulty: Medium

function main()
    log:Step("First connection")
    session:Connect()
    session:Handshake(10000)
    log:Info("First handshake OK")

    log:Step("Disconnect")
    session:Disconnect()
    assert:IsFalse(session.IsConnected, "Should be disconnected")
    log:Info("Disconnected successfully")

    log:Step("Reconnect")
    session:Connect()
    assert:IsTrue(session.IsConnected, "Should be connected again")

    log:Step("Handshake again")
    session:Handshake(10000)
    log:Info("Reconnection and second handshake successful")

    log:Step("Cleanup")
    session:Disconnect()
end
