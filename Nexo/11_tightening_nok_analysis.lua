-- 11_tightening_nok_analysis.lua
-- Capture a NOK tightening and analyze the failure reason from fields.
-- Target: Rexroth Nexo
-- Note: Requires triggering a NOK tightening on the controller.

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Subscribe to results")
    session:StartTightening()

    log:Step("Wait for result (trigger a tightening on the Nexo)")
    local result = session:WaitForResult(120000)  -- 2 minutes
    assert:NotNil(result.fields, "Result should have fields")

    log:Step("Analyze tightening status")
    local status = result.fields.TighteningStatus
    local torqueStatus = result.fields.TorqueStatus
    local angleStatus = result.fields.AngleStatus
    local batchStatus = result.fields.BatchStatus

    log:Info("TighteningStatus: " .. (status or "nil") .. " (1=OK, 0=NOK)")
    log:Info("TorqueStatus: " .. (torqueStatus or "nil") .. " (1=OK, 0=Low, 2=High)")
    log:Info("AngleStatus: " .. (angleStatus or "nil") .. " (1=OK, 0=Low, 2=High)")
    if batchStatus then
        log:Info("BatchStatus: " .. batchStatus .. " (1=OK, 0=NOK)")
    end

    log:Step("Determine failure mode")
    if status == "0" then
        log:Info("=== NOK ANALYSIS ===")
        if torqueStatus == "0" then
            log:Info("FAILURE: Torque too LOW")
        elseif torqueStatus == "2" then
            log:Info("FAILURE: Torque too HIGH")
        end
        if angleStatus == "0" then
            log:Info("FAILURE: Angle too LOW")
        elseif angleStatus == "2" then
            log:Info("FAILURE: Angle too HIGH")
        end
        if torqueStatus == "1" and angleStatus == "1" then
            log:Warn("Torque and Angle are OK but overall is NOK — check other criteria")
        end
    else
        log:Info("Tightening is OK — no failure to analyze")
    end

    log:Step("Cleanup")
    session:StopTightening()
    session:Disconnect()
end
