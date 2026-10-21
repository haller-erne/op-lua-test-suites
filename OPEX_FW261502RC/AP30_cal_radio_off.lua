-- AP30_cal_radio_off.lua
-- FW261502RC delta: In Angle Calibration Mode, radio module is deactivated to prevent conflicts.
-- Change: Radio disabled during cal mode, re-enabled after exit.
-- Acceptance: radioModuleEnabled == 0 during cal mode, 1 after exit.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Read radio status before calibration")
    session:SendMid(40)
    local r41_before = session:WaitForMid(41, 5000)
    assert:NotNil(r41_before, "Should receive MID 0041")
    local before = r41_before.fields.RadioModuleEnabled or r41_before.fields.radioModuleEnabled or ""
    log:Info("RadioModuleEnabled before cal: " .. before)

    log:Step("Enter Angle Calibration Mode (SR 180)")
    log:Break("Enter Angle Calibration Mode on the tool (SR 180 or Setup menu). Press Continue when in cal mode.")

    log:Step("Read radio status during calibration")
    session:SendMid(40)
    local r41_during = session:WaitForMid(41, 5000)
    assert:NotNil(r41_during, "Should receive MID 0041")
    local during = r41_during.fields.RadioModuleEnabled or r41_during.fields.radioModuleEnabled or ""
    log:Info("RadioModuleEnabled during cal: " .. during)
    assert:Equals("0", during, "Radio module should be disabled during calibration mode")

    log:Step("Exit Angle Calibration Mode")
    log:Break("Exit Angle Calibration Mode on the tool. Press Continue when back to normal mode.")

    log:Step("Read radio status after calibration")
    session:SendMid(40)
    local r41_after = session:WaitForMid(41, 5000)
    assert:NotNil(r41_after, "Should receive MID 0041")
    local after = r41_after.fields.RadioModuleEnabled or r41_after.fields.radioModuleEnabled or ""
    log:Info("RadioModuleEnabled after cal: " .. after)
    assert:Equals("1", after, "Radio module should be re-enabled after calibration mode")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
