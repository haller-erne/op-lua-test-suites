-- 04_breakpoint_demo.lua
-- Shows how to pause script execution with a breakpoint.
-- Click Resume in the UI to continue past each breakpoint.
-- Difficulty: Easy

function main()
    log:Step("Setup")
    log:Info("About to hit a breakpoint...")

    log:Break("inspect controller state")

    log:Step("After breakpoint")
    log:Info("Resumed! Continuing test...")

    log:Break("second pause")

    log:Step("Done")
    log:Info("Script finished")
end
