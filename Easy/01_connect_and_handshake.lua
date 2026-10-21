-- 01_connect_and_handshake.lua
-- Connects to a controller and performs the Open Protocol handshake.
-- Difficulty: Easy

function main()
    log:Step("Connect to controller")
    session:Connect()
    assert:IsTrue(session.IsConnected, "Connection failed")

    log:Step("Perform handshake")
    session:Handshake(10000)
    log:Info("Handshake complete")

    log:Step("Disconnect")
    session:Disconnect()
end
