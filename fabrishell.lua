local comando
local pwd
print("FabriShell 1.0 para FabriOS")
local function separar(texto)
    local resultado = {}
    local actual = ""
    local escapar = false

    for i = 1, #texto do
        local c = texto:sub(i, i)

        if escapar then
            actual = actual .. c
            escapar = false
        elseif c == "\\" then
            escapar = true
        elseif c == " " then
            if #actual > 0 then
                table.insert(resultado, actual)
                actual = ""
            end
        else
            actual = actual .. c
        end
    end

    if escapar then
        actual = actual .. "\\"
    end

    if #actual > 0 then
        table.insert(resultado, actual)
    end

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
            if programa then
                local exito, error = pcall(programa, table.unpack(argumentos_comando))
                if not exito then
                    print("ERROR: " .. error)
                end
            else
                print("ERROR: " .. error)
            end
        end
    end
end
