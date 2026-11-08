local comando
local pwd
print("FabriShell Universal 1.0")
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
        if comando[1] then
            shell.run(table.unpack(comando))
        end
    end
end
