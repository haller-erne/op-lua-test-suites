-- 04_repeated_tightening_loop.lua
-- Runs multiple tightenings and validates each result.
-- Difficulty: Hard

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Select job and subscribe")
    session:SelectJob(1)
    session:StartTightening()

    local iterations = 3
    for i = 1, iterations do
        log:Step("Tightening " .. i .. " of " .. iterations)

        local result = session:WaitForResult(30000)
        assert:TorqueWithin(result, 5.0, 50.0)
        assert:AngleWithin(result, 10.0, 360.0)
        assert:NoAlarm(result)

        local torque = tonumber(result.fields.Torque) or 0
        local angle = tonumber(result.fields.Angle) or 0
        log:Info(string.format("#%d  Torque=%.2f  Angle=%.1f", i, torque, angle))
    end

    log:Step("Unsubscribe and disconnect")
    session:StopTightening()
    session:Disconnect()
    log:Info("All " .. iterations .. " tightenings validated")
end
