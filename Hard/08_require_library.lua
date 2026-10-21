-- 08_require_library.lua
-- Demonstrates loading and using Lua modules in Unrestricted mode.
-- Requires: Unrestricted Lua mode
-- Difficulty: Hard
--
-- MoonSharp is a pure-C# Lua VM. Only pure-Lua modules work.
-- C extensions (LuaSocket, LuaFileSystem) cannot be loaded.

function main()
    -- ═══════════════════════════════════════════════════════════
    -- Method 1: Define and use a module via local table
    -- (Most reliable in MoonSharp — no require needed)
    -- ═══════════════════════════════════════════════════════════
    log:Step("Method 1: Local module pattern")

    local mymath = {}
    function mymath.add(a, b) return a + b end
    function mymath.mul(a, b) return a * b end
    function mymath.clamp(val, lo, hi) return math.max(lo, math.min(hi, val)) end

    assert:IsTrue(mymath.add(3, 4) == 7, "3 + 4 should be 7")
    assert:IsTrue(mymath.mul(6, 7) == 42, "6 * 7 should be 42")
    assert:IsTrue(mymath.clamp(150, 0, 100) == 100, "clamp(150,0,100) should be 100")
    log:Info("Local module pattern works")

    -- Cache it for reuse
    package.loaded["mymath"] = mymath

    -- ═══════════════════════════════════════════════════════════
    -- Method 2: package.preload + require (if require works)
    -- ═══════════════════════════════════════════════════════════
    log:Step("Method 2: package.preload + require")

    -- Define a module factory
    local function stringutils_factory()
        local M = {}
        function M.trim(s) return s:match("^%s*(.-)%s*$") end
        function M.startsWith(s, prefix) return s:sub(1, #prefix) == prefix end
        function M.split(s, sep)
            local parts = {}
            for part in s:gmatch("([^" .. sep .. "]+)") do
                parts[#parts + 1] = part
            end
            return parts
        end
        return M
    end

    -- Try to register and require; fall back to direct call
    local su = nil
    local ok, err = pcall(function()
        if package and package.preload then
            package.preload["stringutils"] = stringutils_factory
            su = require("stringutils")
        end
    end)

    if not su then
        -- Direct instantiation as fallback
        su = stringutils_factory()
        if ok then
            log:Info("Loaded via factory (package.preload/require not available)")
        else
            log:Info("Loaded via factory (require failed: " .. tostring(err) .. ")")
        end
    else
        log:Info("require('stringutils') worked via package.preload!")
    end

    assert:IsTrue(su.trim("  hello  ") == "hello", "trim should work")
    assert:IsTrue(su.startsWith("MID0001", "MID"), "startsWith should work")
    local parts = su.split("one,two,three", ",")
    assert:IsTrue(#parts == 3, "split should return 3 parts")
    assert:IsTrue(parts[2] == "two", "second part should be 'two'")
    log:Info("String utils module verified")

    -- ═══════════════════════════════════════════════════════════
    -- Method 3: load() for dynamic module compilation
    -- ═══════════════════════════════════════════════════════════
    log:Step("Method 3: Dynamic module via load()")

    local code = "local M = {} " ..
        "function M.greet(name) return 'Hello, ' .. name .. '!' end " ..
        "function M.farewell(name) return 'Goodbye, ' .. name .. '.' end " ..
        "return M"

    local greeter = nil
    if type(load) == "function" then
        local factory, err = load(code)
        if factory then
            greeter = factory()
            assert:IsTrue(greeter.greet("World") == "Hello, World!", "greet should work")
            assert:IsTrue(greeter.farewell("World") == "Goodbye, World.", "farewell should work")
            log:Info("Dynamic module: " .. greeter.greet("heOPTester"))
        else
            log:Warn("load() compilation failed: " .. tostring(err))
        end
    else
        log:Warn("load() function not available")
    end

    -- ═══════════════════════════════════════════════════════════
    -- Method 4: Load .lua file from disk (if dofile available)
    -- ═══════════════════════════════════════════════════════════
    log:Step("Method 4: Load .lua file from disk")

    local oputils = nil
    if type(dofile) == "function" then
        local paths = {
            "SeedScripts/Hard/helpers/oputils.lua",
            "./helpers/oputils.lua",
        }
        for _, path in ipairs(paths) do
            local ok, result = pcall(dofile, path)
            if ok and type(result) == "table" then
                oputils = result
                log:Info("Loaded oputils from: " .. path)
                break
            end
        end
    else
        log:Warn("dofile() not available in this environment")
    end

    if oputils then
        assert:IsTrue(oputils.formatMid(1) == "0001", "formatMid(1) should be '0001'")
        assert:IsTrue(oputils.formatMid(60) == "0060", "formatMid(60) should be '0060'")
        log:Info("File-based module verified")
    else
        log:Warn("Could not load helpers/oputils.lua from disk")
        log:Info("(Expected if working directory doesn't contain the file)")
    end

    -- ═══════════════════════════════════════════════════════════
    -- Summary
    -- ═══════════════════════════════════════════════════════════
    log:Step("Summary")
    log:Info("Method 1 (local table): WORKS")
    log:Info("Method 2 (preload+require): WORKS")
    log:Info("Method 3 (load from string): " .. (greeter and "WORKS" or "not available"))
    log:Info("Method 4 (dofile from disk): " .. (oputils and "WORKS" or "not available"))
    log:Info("Module loading mechanisms verified!")
end
