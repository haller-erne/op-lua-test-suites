-- 14_curve_subscribe_angle.lua
-- Subscribe to rotation angle curve via MID 0008 (Application Data).
-- Target: OPERATOR 22 GWK
-- Note: Uses generic data subscribe with MID 0900 for curve data.

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to rotation angle curve (MID 0008)")
    -- Format from manual: body contains requested MID and parameters
    -- Note: Some OPERATOR 22 firmware versions may not support curve subscription
    session:SendRaw("00640008001         09000013500000000000000000000000000000001001")
    local resp = session:WaitForRawResponse(5000)
    if resp.mid == 4 then
        log:Warn("Curve subscription rejected (MID 0004) — not supported on this firmware")
        log:Info("Error code: " .. (resp.fields.ErrorCode or resp.body or "?"))
        session:Disconnect()
        return
    end
    assert:IsTrue(resp.mid == 5, "Curve subscribe accepted")
    log:Info("Angle curve subscription active")

    log:Step("Wait for curve data (MID 0900 — trigger tightening)")
    local ok, curve = pcall(function()
        return session:WaitForMid(900, 120000)
    end)

    if ok and curve then
        log:Step("Parse curve data")
        log:Info("Curve MID 0900 received, length: " .. tostring(curve.length))
        log:Info("Body length: " .. tostring(#(curve.body or "")))
        if curve.fields then
            for name, value in pairs(curve.fields) do
                log:Info(string.format("  %s = %s", name, tostring(value)))
            end
        end
        -- Acknowledge curve
        session:SendMid(5)
    else
        log:Warn("No curve data within timeout (trigger a tightening)")
    end

    log:Step("Unsubscribe curves (MID 0009)")
    session:SendRaw("00380009001         090000108010011002")

    log:Step("Disconnect")
    session:Disconnect()
end
