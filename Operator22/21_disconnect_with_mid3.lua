-- 21_disconnect_with_mid3.lua
-- Compare disconnect behavior with and without MID 0003 (Communication Stop).
-- Target: OPERATOR 22 GWK
-- Strategy:
--   1. Connect, handshake, select PSet, enable tool, subscribe
--   2. Disconnect WITHOUT MID 0003 -- observe LCD icon timeout
--   3. Reconnect, same setup
--   4. Disconnect WITH MID 0003 -- observe LCD icon clears immediately
--   5. Compare reconnection times

function main()
    -- ===== Test 1: HARD disconnect =====
    log:Step("Test 1: Connect and set up active session")
    session:Connect()
    session:Handshake(10000)
    session:SendMid(18, { ParameterSetId = "004" })
    session:WaitForMid(5, 5000)
    session:SendMid(43)
    session:WaitForMid(5, 5000)
    session:SendMid(60)
    session:WaitForMid(5, 5000)
    log:Info("Subscribed to tightenings -- session is active")

    log:Step("Test 1: Disconnect WITHOUT MID 0003 (hard close)")
    session:Disconnect()
    log:Info("TCP closed abruptly -- no protocol stop sent")
    log:Warn("Watch the OPERATOR LCD -- communication icon may take 10-20s to disappear")
    log:Break("Observe LCD: how long until communication icon disappears? Then click Resume")

    log:Step("Test 1: Wait 3s then reconnect")
    session:Sleep(3000)
    local t1_start = os.clock()
    session:Connect()
    session:Handshake(10000)
    local t1_elapsed = math.floor((os.clock() - t1_start) * 1000)
    log:Info("Reconnect after hard close: " .. t1_elapsed .. "ms")
    -- Quick check: request tool data to verify session is healthy
    session:SendMid(40)
    local tool1 = session:TryWaitForRawResponse(5000)
    if tool1 ~= nil then
        log:Info("Tool data received (MID " .. tostring(tool1.mid) .. ") -- session OK")
    else
        log:Warn("No tool data response -- session may be unhealthy")
    end

    -- ===== Test 2: CLEAN disconnect with MID 0003 =====
    log:Step("Test 2: Set up active session again")
    session:SendMid(18, { ParameterSetId = "004" })
    session:WaitForMid(5, 5000)
    session:SendMid(43)
    session:WaitForMid(5, 5000)
    session:SendMid(60)
    session:WaitForMid(5, 5000)
    log:Info("Subscribed again -- session active")

    log:Step("Test 2: Disconnect WITH MID 0003 (clean protocol stop)")
    session:DisconnectWithMid3()
    log:Info("Sent MID 0003 then closed TCP -- clean shutdown")
    log:Warn("Watch the OPERATOR LCD -- communication icon should disappear quickly")
    log:Break("Observe LCD: how long until communication icon disappears? Then click Resume")

    log:Step("Test 2: Wait 3s then reconnect")
    session:Sleep(3000)
    local t2_start = os.clock()
    session:Connect()
    session:Handshake(10000)
    local t2_elapsed = math.floor((os.clock() - t2_start) * 1000)
    log:Info("Reconnect after MID 0003: " .. t2_elapsed .. "ms")
    -- Quick check
    session:SendMid(40)
    local tool2 = session:TryWaitForRawResponse(5000)
    if tool2 ~= nil then
        log:Info("Tool data received (MID " .. tostring(tool2.mid) .. ") -- session OK")
    else
        log:Warn("No tool data response -- session may be unhealthy")
    end

    -- ===== Summary =====
    log:Step("Summary")
    log:Info("Hard close reconnect:  " .. t1_elapsed .. "ms")
    log:Info("MID 0003 reconnect:    " .. t2_elapsed .. "ms")
    if t2_elapsed < t1_elapsed then
        log:Info("MID 0003 was " .. (t1_elapsed - t2_elapsed) .. "ms faster")
    elseif t1_elapsed < t2_elapsed then
        log:Info("Hard close was " .. (t2_elapsed - t1_elapsed) .. "ms faster")
    else
        log:Info("No significant difference")
    end

    log:Step("Final disconnect")
    session:DisconnectWithMid3()
end
