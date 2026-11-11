local caracteres_especiales = {
    ["\n"] = keys.enter,
    ["\t"] = keys.tab,
    ["\b"] = keys.backspace
}

local archivo = ...

if not archivo then
    print("Especifique el archivo")
    return
end

local handle = fs.open(archivo, "r")

if not handle then
    print("No se pudo abrir: " .. archivo)
    return
end

local texto = handle.readAll()
handle.close()

for i = 1, #texto do
    local caracter = texto:sub(i, i)
    local tecla = caracteres_especiales[caracter]

    if tecla then
        os.queueEvent("key", tecla, false)
        os.queueEvent("key_up", tecla)
    else
        os.queueEvent("char", caracter)
    end
end

shell.run("lua")
