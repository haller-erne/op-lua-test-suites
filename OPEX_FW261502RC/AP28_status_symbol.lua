-- AP28_status_symbol.lua
-- FW261502RC delta: Status bar shows open chain symbol when OP tightening problems occur.
-- Change: New status indicator for OP problems.
-- Acceptance: Manual verification on tool display.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Simulate OP problem")
    log:Break("Start a tightening on the tool. While the tightening is active, disconnect the Open Protocol TCP connection, then reconnect. Verify the status bar shows an open chain symbol. Press Continue when verified.")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
