-- 01_multi_tool.lua
-- Uses createSession() to connect to two controllers simultaneously.
-- Demonstrates multi-tool testing pattern: one tool uses toolbar config,
-- the second connects to an explicit IP/port/variant.
-- Difficulty: Hard
--
-- Prerequisites:
--   - First tool: configured via the toolbar (host/port/variant)
--   - Second tool: reachable at the address below (edit as needed)

-- Edit these to match your second controller:
local TOOL2_HOST    = "10.10.2.178"
local TOOL2_PORT    = 4545
local TOOL2_VARIANT = "OpenProtocol_Rexroth"

function main()
    log:Step("Create second session")
    local session2 = createSession()

    log:Step("Connect first tool (uses toolbar config)")
    session:Connect()
    session:Handshake(10000)
    log:Info("Tool 1 connected to " .. session.ToolHost .. ":" .. session.ToolPort)

    log:Step("Connect second tool (explicit address)")
    session2:Connect(TOOL2_HOST, TOOL2_PORT, TOOL2_VARIANT)
    session2:Handshake(10000)
    log:Info("Tool 2 connected to " .. TOOL2_HOST .. ":" .. TOOL2_PORT)

    log:Step("Select job on both tools")
    session:SelectJob(1)
    session2:SelectJob(2)
    log:Info("Tool 1 -> Job 1, Tool 2 -> Job 2")

    log:Step("Disconnect both")
    session:Disconnect()
    session2:Disconnect()

    assert:IsFalse(session.IsConnected, "Tool 1 should be disconnected")
    assert:IsFalse(session2.IsConnected, "Tool 2 should be disconnected")
    log:Info("Multi-tool test complete")
end
