-- 02_select_job.lua
-- Connects, performs handshake, and selects job 1.
-- Difficulty: Easy

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Select job 1")
    session:SelectJob(1)
    log:Info("Job 1 selected successfully")

    log:Step("Disconnect")
    session:Disconnect()
end
