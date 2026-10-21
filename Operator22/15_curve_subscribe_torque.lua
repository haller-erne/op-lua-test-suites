-- 15_curve_subscribe_torque.lua
-- Subscribe to torque curve via MID 0008 (Application Data).
-- Target: OPERATOR 22 GWK
-- Note: Uses generic data subscribe with MID 0900, data type 1002 = torque.

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to torque curve (MID 0008)")
    -- Last 4 digits: 1002 = torque curve
    -- Note: Some OPERATOR 22 firmware versions may not support curve subscription
    session:SendRaw("00640008001         09000013500000000000000000000000000000001002")
    local resp = session:WaitForRawResponse(5000)
    if resp.mid == 4 then
        log:Warn("Torque curve subscription rejected — not supported on this firmware")
        log:Info("Error code: " .. (resp.fields.ErrorCode or resp.body or "?"))
        session:Disconnect()
        return
    end
    assert:IsTrue(resp.mid == 5, "Torque curve subscribe accepted")
    log:Info("Torque curve subscription active")

    log:Step("Wait for curve data (MID 0900 — trigger tightening)")
    local ok, curve = pcall(function()
        return session:WaitForMid(900, 120000)
    end)

    if ok and curve then
        log:Step("Parse torque curve data")
        log:Info("Curve MID 0900 received, length: " .. tostring(curve.length))
        if curve.fields then
            for name, value in pairs(curve.fields) do
                log:Info(string.format("  %s = %s", name, tostring(value)))
            end
        end
        session:SendMid(5)
    else
        log:Warn("No curve data within timeout")
    end

    log:Step("Unsubscribe (MID 0009)")
    session:SendRaw("00380009001         090000108010011002")

    log:Step("Disconnect")
    session:Disconnect()
end
