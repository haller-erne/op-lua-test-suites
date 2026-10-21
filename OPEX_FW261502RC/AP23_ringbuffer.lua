-- AP23_ringbuffer.lua
-- FW261502RC delta: New config CFG_COMMUNICATION_OP_RINGBUFFER_BEHAVIOUR.
-- Change: Menu entry 4/11 to delete OP Result Buffer; "Stop tool if buffer full" locks tool until buffer cleared.
-- Acceptance: Menu entry exists and buffer-full behavior matches description.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Manual menu verification")
    log:Break("On tool display: navigate to Setup/Extras menu and confirm entry 4/11 'Delete OP Result Buffer' exists. Press Continue.")

    log:Step("Verify buffer-full lock behavior")
    log:Break("Enable 'Stop tool if buffer full', fill the OP result buffer without reading, and confirm the tool shows 'Open Protocol result buffer full' on NoInit screen and is locked. Press Continue.")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
