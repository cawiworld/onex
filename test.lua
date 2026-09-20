-- test file for rapidfire on onetap
print("--- [SEARCHING IN MEMORY] ---")
local found = false

for _, obj in ipairs(getgc(true)) do
    if type(obj) == "table" and rawget(obj, "Moon Rifle") then
        found = true
        print("Найдена таблица оружия в памяти!")
        local weapon = obj["Moon Rifle"]
        if type(weapon) == "table" then
            for statName, statVal in pairs(weapon) do
                print("  [STAT]", statName, "=", statVal)
            end
        else
            for k, v in pairs(obj) do
                print(k, "=", v)
            end
        end
        break
    end
end

if not found then
    print("Поиск по названию не дал результатов. Пробуем перебор всех таблиц с параметрами задержки:")
    for _, obj in ipairs(getgc(true)) do
        if type(obj) == "table" and (rawget(obj, "FireRate") or rawget(obj, "Cooldown") or rawget(obj, "RPM")) then
            for k, v in pairs(obj) do
                print("  ", k, "=", v)
            end
            break
        end
    end
end
print("--- [SEARCH FINISHED] ---")
