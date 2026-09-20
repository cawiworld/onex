-- test file for rapidfire on onetap
local weaponsModule = game:GetService("ReplicatedStorage").Common.Managers.WeaponManager._Weapons
local data = require(weaponsModule)

print("-- Weapons data")
local function printTable(tbl, indent)
    indent = indent or ""
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            print(indent .. tostring(k) .. " = {")
            printTable(v, indent .. "  ")
            print(indent .. "}")
        else
            print(indent .. tostring(k) .. " = " .. tostring(v))
        end
    end
end

if type(data) == "table" then
    printTable(data)
else
    print("Module returned:", typeof(data), data)
end
print("-- End Weapons data")
