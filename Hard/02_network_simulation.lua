-- 02_network_simulation.lua
-- Applies network impairment profiles before connecting.
-- Demonstrates SetNetworkProfile and SetNetworkProfileCustom usage.
-- Profiles simulate poor radio, slow stations, or forced disconnects.
-- Difficulty: Hard

function main()
    -- Test 1: Connect with poor radio simulation (200ms send delay, 300ms receive delay, 150ms jitter)
    log:Step("Apply 'poor_radio' network profile")
    session:SetNetworkProfile("poor_radio")

    log:Step("Connect through simulated poor radio link")
    session:Connect()
    session:Handshake(15000) -- longer timeout to account for delays
    log:Info("Connected despite poor radio conditions")

    log:Step("Disconnect from poor radio session")
    session:Disconnect()

    -- Test 2: Connect with slow station simulation (2000ms receive delay, 500ms jitter)
    log:Step("Apply 'slow_station' network profile")
    session:SetNetworkProfile("slow_station")

    log:Step("Connect through simulated slow station")
    session:Connect()
    session:Handshake(15000)
    log:Info("Connected despite slow station response")

    log:Step("Disconnect from slow station session")
    session:Disconnect()

    -- Test 3: Custom profile with packet loss
    log:Step("Apply custom network profile with 10% packet loss")
    session:SetNetworkProfileCustom({
        sendDelayMs = 50,
        receiveDelayMs = 100,
        jitterMs = 30,
        packetLossPercent = 10
    })

    log:Step("Connect through lossy link")
    session:Connect()
    session:Handshake(15000)
    log:Info("Connected through lossy network")

    log:Step("Disconnect from lossy session")
    session:Disconnect()

    -- Test 4: Reset to normal (no impairment)
    log:Step("Reset to 'normal' profile (no impairment)")
    session:SetNetworkProfile("normal")

    log:Step("Connect with clean link")
    session:Connect()
    session:Handshake(10000)
    log:Info("Connected with normal network")

    log:Step("Final disconnect")
    session:Disconnect()
end
