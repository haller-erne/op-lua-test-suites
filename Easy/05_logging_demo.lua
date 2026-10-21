-- 05_logging_demo.lua
-- Shows how to use log levels and test steps.
-- Difficulty: Easy

function main()
    log:Step("Info messages")
    log:Info("This is an informational message")

    log:Step("Warning messages")
    log:Warn("This is a warning")

    log:Step("Debug messages")
    log:Debug("Debug detail: x = 42")
    print("print() also routes to log:Debug()")

    log:Step("Error messages")
    log:Error("This is an error message (test continues)")

    log:Step("Step counter")
    log:Info("Five steps have been logged using log:Step()")
    log:Info("Each step becomes a test result row in the report")
end
