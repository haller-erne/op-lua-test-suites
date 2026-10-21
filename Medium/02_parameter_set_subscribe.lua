-- 02_parameter_set_subscribe.lua
-- Subscribes to parameter set changes and reads the data.
-- Difficulty: Medium

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to parameter sets (MID 0010)")
    session:SendMid(10)
    local ack = session:WaitForMid(5, 5000)
    assert:Equals(5, ack.mid, "Expected acceptance (MID 0005)")

    log:Step("Wait for parameter set data (MID 0012)")
    local data = session:WaitForMid(12, 10000)
    assert:NotNil(data, "Expected MID 0012")
    log:Info("Parameter set body: " .. data.body)

    log:Step("Unsubscribe (MID 0011)")
    session:SendMid(11)

    log:Step("Disconnect")
    session:Disconnect()
end
