-- AP16_mid0001_rev5.lua
-- FW261502RC delta: Handshake now supports revision 005.
-- Change: MID 0001 Rev 005 accepted by controller.
-- Acceptance: MID 0002 received without error for Rev 005.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect")
    session:Connect()

    log:Step("Send MID 0001 with revision 005")
    session:SendMid(1, nil, { Revision = "005" })

    log:Step("Wait for MID 0002")
    local r2 = session:WaitForMid(2, 10000)
    assert:NotNil(r2, "Should receive MID 0002 for Rev 005 handshake")
    log:Info("MID 0002 received - Rev 005 handshake accepted")
    if r2.fields then
        log:Info("CellId: " .. (r2.fields.CellId or "N/A"))
        log:Info("ChannelId: " .. (r2.fields.ChannelId or "N/A"))
    end

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
