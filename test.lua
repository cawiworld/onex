local weaponClientModule = game:GetService("StarterPlayer").StarterPlayerScripts.Start.Game.WeaponClient

print("--- [WEAPON CLIENT DUMP] ---")
for _, obj in ipairs(getgc(true)) do
    if type(obj) == "table" and (rawget(obj, "Fire") or rawget(obj, "Shoot") or rawget(obj, "Reload")) then
        print("Найдена таблица контроллера стрельбы!")
        for k, v in pairs(obj) do
            print("  [Field]", tostring(k), "=", typeof(v))
        end
        break
    end
end
print("--- [END DUMP] ---")
