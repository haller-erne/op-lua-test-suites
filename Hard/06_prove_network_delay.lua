-- 06_prove_network_delay.lua
-- Proves network simulation actually adds delays by measuring elapsed time.
-- Requires: Unrestricted Lua mode (uses os.clock)
-- Difficulty: Hard

function main()
    -- Test 1: Measure baseline (normal, no impairment)
    log:Step("Baseline: connect with no simulation")
    session:SetNetworkProfile("normal")
    local t0 = os.clock()
    session:Connect()
    session:Handshake(10000)
    local baseline_ms = (os.clock() - t0) * 1000
    log:Info(string.format("Baseline handshake: %.0f ms", baseline_ms))
    session:Disconnect()

    -- Test 2: Connect with poor_radio (200ms send + 300ms receive + 150ms jitter)
    -- Expected: at least ~400ms slower than baseline
    log:Step("Apply 'poor_radio' profile and measure delay")
    session:SetNetworkProfile("poor_radio")
    t0 = os.clock()
    session:Connect()
    session:Handshake(15000)
    local delayed_ms = (os.clock() - t0) * 1000
    log:Info(string.format("Poor radio handshake: %.0f ms", delayed_ms))
    session:Disconnect()

    -- Test 3: Verify the delay is meaningful
    log:Step("Verify simulation added delay")
    local overhead = delayed_ms - baseline_ms
    log:Info(string.format("Overhead from simulation: %.0f ms", overhead))
    assert:IsTrue(overhead > 200,
        string.format("Expected >200ms overhead, got %.0f ms. Simulation may not be working.", overhead))

    log:Info("Network simulation confirmed working!")
end
