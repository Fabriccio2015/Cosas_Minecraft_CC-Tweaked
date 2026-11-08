local comando
local pwd
print("FabriShell 1.0 para FabriOS")
local function separar(texto)
    local resultado = {}
    local actual = ""
    local escapar = false

    for i = 1, #texto do
        local c = texto:sub(i, i)

        if c == " " and not escapar then
            table.insert(resultado, actual)
            actual = ""
        else
            actual = actual .. c
        end

        if c == "\\" then
            escapar = not escapar
        else
            escapar = false
        end
    end

    table.insert(resultado, actual)
    return resultado
end
while true do
    pwd = shell.resolve(".")
    write("[/" .. pwd .. "]>")
    comando = separar(read())
    if comando[1] == "exit" then break else
        local argumentos_comando = {table.unpack(comando)}
        table.remove(argumentos_comando, 1)
        if comando[1] then
            local programa, error = loadfile(fs.combine("/disk2","apps",comando[1]),"bt",_ENV)
            if programa then programa(table.unpack(argumentos_comando)) else print("ERROR: " .. error)
        end
    end
end
