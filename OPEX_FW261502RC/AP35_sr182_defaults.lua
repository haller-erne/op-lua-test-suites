-- AP35_sr182_defaults.lua
-- FW261502RC delta: SR 182 now initializes internal memory AND resets all config values to defaults.
-- Change: Preserves DMS and Gyro calibration data.
-- Acceptance: Config reset to defaults; DMS/Gyro data intact.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Read config values before SR 182")
    session:SendMid(40)
    local r41_before = session:WaitForMid(41, 5000)
    assert:NotNil(r41_before, "Should receive MID 0041")
    log:Info("Before SR 182:")
    log:Info("  ToolSerialNumber: " .. (r41_before.fields.ToolSerialNumber or "N/A"))
    log:Info("  SoftwareVersion: " .. (r41_before.fields.SoftwareVersion or "N/A"))

    log:Step("Read DMS/Gyro calibration data before SR 182")
    log:Break("Note current DMS and Gyro calibration values from the tool service menu. Press Continue.")

    log:Step("Execute Service Routine 182")
    log:Break("Execute SR 182 (factory defaults) on the tool. Wait for completion. Press Continue.")

    log:Step("Read config values after SR 182")
    session:SendMid(40)
    local r41_after = session:WaitForMid(41, 5000)
    assert:NotNil(r41_after, "Should receive MID 0041")
    log:Info("After SR 182:")
    log:Info("  ToolSerialNumber: " .. (r41_after.fields.ToolSerialNumber or "N/A"))
    log:Info("  SoftwareVersion: " .. (r41_after.fields.SoftwareVersion or "N/A"))

    log:Step("Verify DMS/Gyro data preserved")
    log:Break("Verify DMS and Gyro calibration data are unchanged after SR 182. Press Continue.")

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
