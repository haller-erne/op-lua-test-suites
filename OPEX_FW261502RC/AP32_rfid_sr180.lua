-- AP32_rfid_sr180.lua
-- FW261502RC delta: RFID + SR 180 starts correct EasyWin parameter set; torque quick adjustment CCW bug fixed.
-- Change: Requires RFID-enabled tool with valid RFID-coded insertion tool.
-- Acceptance: SR 180 starts correct parameter set; CCW torque quick adjustment works.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("RFID + SR 180 setup")
    log:Break("Ensure RFID is enabled and a valid RFID-coded insertion tool is present. Press Continue.")

    log:Step("Trigger Service Routine 180")
    log:Break("Start SR 180 (cali mode) on the tool. Verify the appropriate EasyWin parameter set starts automatically. Press Continue.")

    log:Step("Verify CCW torque quick adjustment")
    log:Break("Use torque quick adjustment in CCW direction and confirm the value changes correctly. Press Continue.")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
