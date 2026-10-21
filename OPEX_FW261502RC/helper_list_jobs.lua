-- helper_list_jobs.lua
-- Lists all jobs configured on the controller via MID 0030/0031.
-- Use this before AP18 to verify job 1 exists.

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request job ID list (MID 0030)")
    session:SendMid(30)
    local response = session:WaitForMid(31, 5000)
    assert:NotNil(response, "Should receive MID 0031 job list")

    log:Info("Raw body: [" .. (response.body or "") .. "]")

    if response.fields then
        for k, v in pairs(response.fields) do
            log:Info("Field " .. tostring(k) .. " = " .. tostring(v))
        end
    end

    log:Step("Disconnect")
    session:SendMid(3)
    session:Disconnect()
end
