-- 05_disconnect_recovery_stress.lua
-- Stress test: connect/disconnect many times rapidly.
-- Difficulty: Hard

function main()
    log:Step("Stress test: 5 rapid connect/disconnect cycles")

    local cycles = 5
    for i = 1, cycles do
        log:Step("Cycle " .. i .. " of " .. cycles)
        session:Connect()
        assert:IsTrue(session.IsConnected, "Should be connected (cycle " .. i .. ")")

        session:Handshake(10000)

        session:Disconnect()
        assert:IsFalse(session.IsConnected, "Should be disconnected (cycle " .. i .. ")")
        log:Info("Cycle " .. i .. " OK")
    end

    log:Info("Stress test passed: " .. cycles .. " cycles without failure")
end
