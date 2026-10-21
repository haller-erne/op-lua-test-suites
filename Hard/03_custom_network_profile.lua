-- 03_custom_network_profile.lua
-- Creates a custom network simulation profile with explicit parameters.
-- Demonstrates SetNetworkProfileCustom with fine-grained impairment control.
-- Difficulty: Hard

function main()
    log:Step("Set custom network simulation profile")
    session:SetNetworkProfileCustom({
        sendDelayMs = 100,
        receiveDelayMs = 200,
        jitterMs = 50,
        packetLossPercent = 0,
        disconnectAfterMessages = 0
    })
    log:Info("Custom profile applied: 100ms send, 200ms receive, 50ms jitter")

    log:Step("Connect with custom simulation")
    session:Connect()
    session:Handshake(15000)
    log:Info("Connected through custom simulated link")

    log:Step("Disconnect")
    session:Disconnect()
end
