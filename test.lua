local clientScript = game:GetService("Players").LocalPlayer.PlayerScripts:FindFirstChild("WeaponClient", true)
    or game:GetService("StarterPlayer").StarterPlayerScripts.Start.Game.WeaponClient

print("--- [GETSENV WEAPONCLIENT] ---")
local env = getsenv(clientScript)

for k, v in pairs(env) do
    print("[ENV]", tostring(k), "=", typeof(v))
    if type(v) == "table" then
        for subK, subV in pairs(v) do
            print("    ->", tostring(subK), "=", typeof(subV), tostring(subV))
        end
    end
end
print("--- [END GETSENV] ---")
