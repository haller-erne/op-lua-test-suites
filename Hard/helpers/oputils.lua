-- helpers/oputils.lua
-- A reusable pure-Lua utility module for Open Protocol test scripts.
-- Demonstrates how to create modules that can be loaded with require().
--
-- Usage from a test script:
--   package.path = package.path .. ";" .. workspace_path .. "/?.lua"
--   local oputils = require("helpers/oputils")

local M = {}

--- Format a MID number with zero-padding (e.g., 1 -> "0001").
function M.formatMid(midNumber)
    return string.format("%04d", midNumber)
end

--- Build a raw Open Protocol header string (20 bytes, Rexroth format).
-- @param length  Total message length including header
-- @param mid     MID number (integer)
-- @param rev     Revision string (3 chars, e.g., "001")
function M.buildHeader(length, mid, rev)
    rev = rev or "001"
    return string.format("%04d%04d%s0010100010", length, mid, rev)
end

--- Parse a raw message string into header fields.
-- @param raw  Raw message string (at least 20 chars)
-- @return table with fields: length, mid, revision, noAck, station, spindle, seq
function M.parseHeader(raw)
    if #raw < 20 then
        return nil, "Message too short (need 20 bytes for header)"
    end
    return {
        length   = tonumber(raw:sub(1, 4)),
        mid      = tonumber(raw:sub(5, 8)),
        revision = raw:sub(9, 11),
        noAck    = raw:sub(12, 12),
        station  = raw:sub(13, 14),
        spindle  = raw:sub(15, 16),
        sequence = raw:sub(17, 18),
        msgParts = raw:sub(19, 19),
        msgNum   = raw:sub(20, 20),
    }
end

--- Create a simple timer object for measuring durations.
function M.timer()
    local t = { start = os.clock() }
    function t:elapsed()
        return (os.clock() - self.start) * 1000  -- ms
    end
    function t:reset()
        self.start = os.clock()
    end
    return t
end

--- Retry a function up to N times with a delay between attempts.
-- @param fn        Function to call (should return true on success)
-- @param maxRetries  Maximum number of attempts
-- @param delayMs   Delay between retries (note: os.clock busy-wait)
-- @return success (bool), attempts (number)
function M.retry(fn, maxRetries, delayMs)
    maxRetries = maxRetries or 3
    for i = 1, maxRetries do
        local ok, err = pcall(fn)
        if ok then return true, i end
        if i < maxRetries then
            -- busy-wait (no os.sleep in MoonSharp)
            local target = os.clock() + (delayMs or 100) / 1000
            while os.clock() < target do end
        end
    end
    return false, maxRetries
end

return M
