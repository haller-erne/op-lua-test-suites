-- 05_multiple_jobs.lua
-- Selects multiple jobs in sequence to verify switching.
-- Difficulty: Medium

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    local jobs = {1, 2, 3}
    for i, jobId in ipairs(jobs) do
        log:Step("Select job " .. jobId)
        session:SelectJob(jobId)
        log:Info("Job " .. jobId .. " selected OK")
    end

    log:Step("Disconnect")
    session:Disconnect()
end
