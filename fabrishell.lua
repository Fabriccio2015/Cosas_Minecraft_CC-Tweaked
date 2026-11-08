local comando
local pwd
print("FabriShell 1.0 para FabriOS")
while true do
    pwd = shell.resolve(".")
    write("[/" .. pwd .. "]>")
    comando = read()
    if comando == "exit" then break else
        local comando_separado = {}
        for parte_comando in string.gmatch(comando, "%S+") do
            table.insert(comando_separado, parte_comando)
        end
        local argumentos_comando = {table.unpack(comando_separado)}
        table.remove(argumentos_comando, 1)
        if #comando_separado >= 1 then
            local programa, error = loadfile(fs.combine("/disk2","apps",comando_separado[1]),"bt",_ENV)
            if programa then programa(table.unpack(argumentos_comando)) else print("ERROR: " .. error)
        end
    end
end
