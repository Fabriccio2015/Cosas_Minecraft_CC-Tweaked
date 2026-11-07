local comando
local pwd
print("FabriShell 1.0")
while true do
    pwd = shell.resolve(".")
    write("[/" .. pwd .. "]>")
    comando = read()
    if comando == exit then break
    else shell.run(comando) end
end
