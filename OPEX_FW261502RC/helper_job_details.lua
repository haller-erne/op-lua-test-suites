-- helper_job_details.lua
-- Requests details for job 1 via MID 0032/0033.
-- Use this to inspect job batch mode, size, and steps.

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    log:Step("Request job 1 data (MID 0032)")
    session:SendMid(32, { [1] = "0001" })
    local response = session:WaitForMid(33, 5000)
    assert:NotNil(response, "Should receive MID 0033 job data")

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
