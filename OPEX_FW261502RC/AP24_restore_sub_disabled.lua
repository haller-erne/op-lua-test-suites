-- AP24_restore_sub_disabled.lua
-- FW261502RC delta: New config CFG_COMMUNICATION_OP_RESTORE_RES_SUBSCRIPTION.
-- This scenario: "Restore Result Subscr." set to No.
-- Expected: After non-regular disconnect, active MID 0060/0061 subscription is NOT restored.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)
--
-- Prerequisite: On the tool, set Service Routine 128 -> Open Protocol settings ->
-- "Restore Result Subscr." to No.

local function drain()
    while session:TryWaitForRawResponse(300) ~= nil do end
end

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Remove any stale subscription")
    session:SendMid(63)
    session:TryWaitForRawResponse(2000)
    drain()

    log:Step("Subscribe to tightening results")
    session:SendMid(60)
    session:WaitForMid(5, 5000)

    log:Step("Hard disconnect without MID 0003")
    session:HardDisconnect()

    log:Step("Wait 20s before reconnecting")
    session:Sleep(20000)

    log:Step("Reconnect")
    session:Connect()
    session:Handshake(10000)
    drain()

    log:Step("Check that subscription was NOT restored")
    session:SendMid(60)
    local resp = session:TryWaitForRawResponse(5000)
    if resp ~= nil then
        local mid = resp.mid or (resp.header and resp.header.Mid) or 0
        if mid == 5 then
            log:Info("Subscription NOT restored - MID 0060 accepted again (MID 0005)")
        elseif mid == 4 then
            error("Subscription was restored unexpectedly - MID 0060 rejected with MID 0004 (AlreadyExists)")
        else
            error("Unexpected response after MID 0060: MID " .. tostring(mid))
        end
    else
        error("No response after MID 0060 subscribe")
    end

    log:Step("Unsubscribe and disconnect cleanly")
    session:SendMid(63)
    session:SendMid(3)
    session:Disconnect()
end
