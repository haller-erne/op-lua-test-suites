-- 07_require_external_module.lua
-- Demonstrates capabilities unlocked by Unrestricted Lua mode.
-- Requires: Unrestricted Lua mode (uses os, load, package)
-- Difficulty: Hard
--
-- NOTE: MoonSharp is a pure-C# Lua VM. Not all standard library
-- functions have full implementations (e.g., io.tmpfile, os.getenv
-- may throw). This script uses pcall to safely probe what works.

-- Helper module defined inline
local helpers = {}
function helpers.format_duration(seconds)
    if seconds < 60 then
        return string.format("%.3fs", seconds)
    else
        return string.format("%dm %ds", math.floor(seconds / 60), seconds % 60)
    end
end

function main()
    local start = os.clock()

    -- Test 1: os.clock() works (timing)
    log:Step("os.clock() for high-resolution timing")
    assert:NotNil(start, "os.clock() should return a number")
    log:Info(string.format("Script start time: %.6f seconds", start))

    -- Test 2: os.time() and os.date()
    log:Step("os.time() and os.date()")
    local t = os.time()
    assert:IsTrue(t > 0, "os.time() should return epoch seconds")
    local ok, dateStr = pcall(os.date, "%Y-%m-%d %H:%M:%S", t)
    if ok then
        log:Info("Current time: " .. dateStr)
    else
        log:Warn("os.date() not fully supported: " .. tostring(dateStr))
    end

    -- Test 3: load() / loadstring() for dynamic code
    log:Step("Dynamic code execution with load()")
    local fn, err = load("return 6 * 7")
    assert:NotNil(fn, "load() should compile code: " .. tostring(err))
    local result = fn()
    assert:IsTrue(result == 42, "Dynamic code should return 42")
    log:Info("load('return 6 * 7') = " .. tostring(result))

    -- Test 4: load() with upvalues
    log:Step("Dynamic code with string building")
    local values = {10, 20, 30}
    local sum_code = "local s = 0; for _,v in ipairs({" ..
        table.concat(values, ",") .. "}) do s = s + v end; return s"
    local sum_fn = load(sum_code)
    assert:NotNil(sum_fn, "Should compile sum code")
    assert:IsTrue(sum_fn() == 60, "Sum should be 60")
    log:Info("Dynamic sum: " .. tostring(sum_fn()))

    -- Test 5: package table exists
    log:Step("Package system availability")
    assert:NotNil(package, "package table should exist")
    log:Info("package.path = " .. tostring(package.path or "(nil)"))

    -- Test 6: pcall probe of io module
    log:Step("Probe io module (may not be fully implemented)")
    local io_ok, io_err = pcall(function()
        -- Try io.write to stdout (safest io operation)
        if io and io.write then
            log:Info("io.write is available")
            return true
        end
        return false
    end)
    if io_ok then
        log:Info("io module accessible: " .. tostring(io_err))
    else
        log:Warn("io module error: " .. tostring(io_err))
    end

    -- Test 7: os.getenv probe
    log:Step("Probe os.getenv()")
    local env_ok, env_val = pcall(os.getenv, "PATH")
    if env_ok and env_val then
        log:Info("os.getenv('PATH') returned " .. #env_val .. " chars")
    elseif env_ok then
        log:Warn("os.getenv('PATH') returned nil (not implemented or empty)")
    else
        log:Warn("os.getenv() threw: " .. tostring(env_val))
    end

    -- Summary
    log:Step("Summary")
    local elapsed = os.clock() - start
    log:Info("Total script time: " .. helpers.format_duration(elapsed))
    log:Info("Unrestricted mode is working correctly!")
end
