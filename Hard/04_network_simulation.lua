-- 04_network_simulation.lua
-- Verify that field parsing still works correctly under simulated delay.
-- Difficulty: Hard

function main()
    log:Step("Enable poor network simulation")
    session:SetNetworkProfile("poor_radio")

    session:Connect()
    session:Handshake(15000)  -- longer timeout for delayed network

    session:StartTightening()

    log:Step("Wait for tightening under simulated delay")
    local msg = session:WaitForResult(60000)

    assert:NotNil(msg.fields, "Fields should parse even with network delay")
    local torque = tonumber(msg.fields.Torque) or 0
    log:Info("Torque under poor network: " .. torque)
    assert:IsTrue(msg.fields.TighteningStatus == "1", "Tightening should still pass")

    log:Step("Reset to normal and disconnect")
    session:Disconnect()
end
