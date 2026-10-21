-- AP27_start_menu_info.lua
-- FW261502RC delta: Start menu (left arrow) now has 'Information' item.
-- Change: New Information item in start menu.
-- Acceptance: Manual verification on tool display.
-- Tool: OPEX 30Nm (SN RO0310033, Rexroth variant)

function main()
    log:Step("Manual check: start menu Information item")
    log:Break("On the tool display, press the LEFT arrow key to open the Start menu and verify an 'Information' item is present. Press Continue when verified.")
end
