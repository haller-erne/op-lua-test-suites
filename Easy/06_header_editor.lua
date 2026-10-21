-- 06_header_editor.lua
-- Demonstrates the Header Editor API: SetHeader, GetHeader, ClearHeader,
-- and per-call header overrides in SendMid.
-- Difficulty: Easy

function main()
    log:Step("Connect and handshake")
    session:Connect()
    session:Handshake(10000)

    -- ─── 1. Set persistent header defaults ──────────────────────
    log:Step("Set persistent header defaults")
    session:SetHeader({
        revision  = 3,       -- Use revision 3 for all MIDs
        station   = "01",    -- Station 01
        spindle   = "02",    -- Spindle 02
        sequence  = "00",    -- Sequence counter
        noAck     = 0,       -- Acknowledge required
    })
    log:Info("Header defaults set: rev=3, station=01, spindle=02")

    -- ─── 2. Read back the current defaults ──────────────────────
    log:Step("Verify header defaults")
    local hdr = session:GetHeader()
    log:Info("Current revision: " .. tostring(hdr.revision))
    log:Info("Current station:  " .. tostring(hdr.station))
    log:Info("Current spindle:  " .. tostring(hdr.spindle))
    assert:Equals(3, hdr.revision, "Revision should be 3")
    assert:Equals("01", hdr.station, "Station should be 01")

    -- ─── 3. Send MID using persistent defaults ──────────────────
    log:Step("Send MID 0010 (Parameter Set ID) with persistent header")
    -- This will use revision=3, station=01, spindle=02 from SetHeader
    session:SendMid(10)
    local resp = session:TryWaitForRawResponse(5000)
    if resp then
        log:Info("Response MID: " .. tostring(resp.mid))
    else
        log:Info("No response (timeout) — controller may not support this MID revision")
    end

    -- ─── 4. Per-call override (takes precedence) ────────────────
    log:Step("Send MID 0010 with per-call revision override")
    -- Per-call: revision=1 overrides the persistent revision=3
    -- But station/spindle still come from the persistent defaults
    session:SendMid(10, nil, { revision = 1 })
    resp = session:TryWaitForRawResponse(5000)
    if resp then
        log:Info("Response MID: " .. tostring(resp.mid))
    else
        log:Info("No response (timeout)")
    end

    -- ─── 5. SendMid with body fields AND header overrides ───────
    log:Step("Send MID 0018 with body + header override")
    session:SendMid(18,
        { ParameterSetId = "001" },           -- body fields
        { revision = 1, noAck = 1 }           -- header override: rev 1, no-ack
    )
    resp = session:TryWaitForRawResponse(5000)
    if resp then
        log:Info("Response MID: " .. tostring(resp.mid))
    else
        log:Info("No response (no-ack mode, expected)")
    end

    -- ─── 6. Clear header defaults ───────────────────────────────
    log:Step("Clear header defaults and send with built-in defaults")
    session:ClearHeader()
    -- Now SendMid uses built-in defaults: revision=1, station=00, spindle=00
    session:SendMid(10)
    resp = session:TryWaitForRawResponse(5000)
    if resp then
        log:Info("Response MID: " .. tostring(resp.mid))
    end

    -- ─── 7. Verify header is empty after clear ──────────────────
    log:Step("Verify header cleared")
    local empty = session:GetHeader()
    assert:IsTrue(empty.revision == nil, "Revision should be nil after ClearHeader")
    assert:IsTrue(empty.station == nil, "Station should be nil after ClearHeader")
    log:Info("Header defaults successfully cleared")

    -- ─── Done ────────────────────────────────────────────────────
    log:Step("Disconnect")
    session:Disconnect()
    log:Info("=== Header Editor demo COMPLETE ===")
end
