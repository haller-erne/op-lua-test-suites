-- 10_select_job_parse_response.lua
-- Select job via high-level helper and verify the controller's response.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Select job 1")
    session:SelectJob(1)
    log:Info("Job 1 selected (no exception = MID 0005 received)")

    log:Step("Verify by requesting job info")
    session:SendMid(30)
    local ack = session:WaitForMid(5, 5000)
    assert:IsTrue(ack.mid == 5, "Job info subscribe accepted")

    local jobData = session:WaitForMid(32, 10000)
    assert:NotNil(jobData.fields, "Job data should have fields")

    if jobData.fields.JobId then
        log:Info("Active JobId: " .. jobData.fields.JobId)
        assert:MidFieldEquals(jobData.fields, "JobId", "1")
    else
        log:Warn("JobId field not present in MID 0032")
    end

    log:Step("Unsubscribe from job info")
    session:SendMid(33)

    log:Step("Try selecting non-existent job (expect error)")
    local ok, err = pcall(function()
        session:SelectJob(9999)
    end)
    if not ok then
        log:Info("Job 9999 rejected as expected: " .. tostring(err))
    else
        log:Warn("Job 9999 was accepted — unusual")
    end

    log:Step("Disconnect")
    session:Disconnect()
end
