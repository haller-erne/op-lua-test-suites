-- 05_job_info_parse.lua
-- Request job info (MID 0032) and parse the response fields.
-- Target: Rexroth Nexo

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request job data (MID 0030 - subscribe to job info)")
    session:SendMid(30)
    local ack = session:WaitForMid(5, 5000)
    assert:IsTrue(ack.mid == 5, "Expected MID 0005 acceptance")

    log:Step("Wait for job info (MID 0032)")
    local job = session:WaitForMid(32, 10000)
    assert:NotNil(job, "Should receive MID 0032")
    assert:NotNil(job.fields, "MID 0032 should have parsed fields")

    log:Step("Parse job fields")
    log:Info("Raw body: " .. (job.body or "(empty)"))

    if job.fields.JobId then
        log:Info("JobId: " .. job.fields.JobId)
    end
    if job.fields.JobName then
        log:Info("JobName: " .. job.fields.JobName)
    end
    if job.fields.NumberOfParameterSets then
        log:Info("NumberOfParameterSets: " .. job.fields.NumberOfParameterSets)
    end
    if job.fields.ForcedOrder then
        log:Info("ForcedOrder: " .. job.fields.ForcedOrder)
    end
    if job.fields.MaxTimeForFirstTightening then
        log:Info("MaxTimeForFirstTightening: " .. job.fields.MaxTimeForFirstTightening)
    end

    log:Step("Unsubscribe (MID 0033)")
    session:SendMid(33)

    log:Step("Disconnect")
    session:Disconnect()
end
