-- AP20_all_modes.lua
-- FW261502RC delta: Tightening values now output for all modes, not just torque+rotation angle.
-- Change: Values match tool display; L/A exception for re-tightening peak angle.
-- Acceptance: Result fields populated correctly for non-torque/angle modes.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Select parameter set and enable tool")
    session:SendMid(18, { ParameterSetId = "001" })
    session:WaitForMid(5, 5000)
    session:SendMid(43, { ToolEnable = "1" })
    session:WaitForMid(5, 5000)

    log:Step("Subscribe to results")
    session:SendMid(60)
    session:WaitForMid(5, 5000)

    log:Step("Mode A: torque + rotation angle")
    log:Break("Run a torque+angle tightening. Press Continue.")
    local r_a = session:WaitForResult(120000)
    assert:NotNil(r_a, "Should receive result")
    log:Info("Torque: " .. (r_a.fields.Torque or "N/A") .. ", Angle: " .. (r_a.fields.Angle or "N/A"))
    session:SendMid(62)

    log:Step("Mode B: non-torque/angle mode")
    log:Break("Switch to a different tightening mode (e.g. torque only or pulse) and run. Press Continue.")
    local r_b = session:WaitForResult(120000)
    assert:NotNil(r_b, "Should receive result")
    log:Info("Torque: " .. (r_b.fields.Torque or "N/A") .. ", Angle: " .. (r_b.fields.Angle or "N/A"))
    log:Info("Strategy: " .. (r_b.fields.Strategy or "N/A"))
    session:SendMid(62)

    log:Step("Unsubscribe and disconnect")
    session:SendMid(63)
    session:SendMid(3)
    session:Disconnect()
end
