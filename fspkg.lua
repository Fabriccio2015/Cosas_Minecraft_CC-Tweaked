
-- fsPKG v1
-- Empaquetador y desempaquetador para CC:Tweaked

local VERSION = "fsPKG1"

local function fail(msg)
    error(msg, 0)
end

local function writeFile(handle, path)
    local input = fs.open(path, "rb")
    if not input then
        fail("No se pudo leer: " .. path)
    end

    while true do
        local data = input.read(8192)
        if not data then break end
        handle.write(data)
    end

    input.close()
end

local function readExact(handle, amount)
    local result = ""

    while #result < amount do
        local data = handle.read(amount - #result)
        if not data then
            fail("Archivo fsPKG incompleto")
        end
        result = result .. data
    end

    return result
end

local function collectFiles(path, relative, entries)
    local list = fs.list(path)
    table.sort(list)

    for _, name in ipairs(list) do
        local full = fs.combine(path, name)
        local rel = relative == "" and name
            or relative .. "/" .. name

        if fs.isDir(full) then
            table.insert(entries, {
                type = "D",
                path = rel
            })

            collectFiles(full, rel, entries)
        else
            table.insert(entries, {
                type = "F",
                path = rel,
                full = full,
                size = fs.getSize(full)
            })
        end
    end
end

local function pack(source, destination)
    if not fs.exists(source) or not fs.isDir(source) then
        fail("La carpeta de origen no existe")
    end

    local entries = {}
    collectFiles(source, "", entries)

    local output = fs.open(destination, "wb")
    if not output then
        fail("No se pudo crear el archivo")
    end

    output.write(VERSION .. "\n")

    for _, entry in ipairs(entries) do
        if entry.type == "D" then
            output.write(
                "D " .. #entry.path .. "\n"
            )

            output.write(entry.path)
            output.write("\n")

        elseif entry.type == "F" then
            output.write(
                "F " .. #entry.path .. " " ..
                entry.size .. "\n"
            )

            output.write(entry.path)
            output.write("\n")

            writeFile(output, entry.full)
            output.write("\n")
        end
    end

    output.write("E\n")
    output.close()

    print("Empaquetado correctamente.")
    print("Elementos: " .. #entries)
    print("Archivo: " .. destination)
end

local function validPath(path)
    if path == "" then return false end
    if path:sub(1, 1) == "/" then return false end
    if path:find("\\", 1, true) then return false end

    for part in path:gmatch("[^/]+") do
        if part == "." or part == ".." then
            return false
        end
    end

    return true
end

local function unpackFile(source, destination)
    if not fs.exists(source) or fs.isDir(source) then
        fail("El archivo fsPKG no existe")
    end

    local input = fs.open(source, "rb")
    if not input then
        fail("No se pudo abrir el archivo")
    end

    local function getLine()
        local line = input.readLine()
        if line == nil then
            fail("Archivo fsPKG incompleto")
        end
        return line
    end

    if getLine() ~= VERSION then
        fail("Formato fsPKG desconocido o inválido")
    end

    fs.makeDir(destination)

    local count = 0

    while true do
        local header = getLine()

        if header == "E" then
            break
        end

        local kind, pathLength, size

        if header:sub(1, 2) == "D " then
            kind, pathLength = header:match(
                "^(D) (%d+)$"
            )

        elseif header:sub(1, 2) == "F " then
            kind, pathLength, size = header:match(
                "^(F) (%d+) (%d+)$"
            )
        end

        if not kind then
            fail("Entrada inválida")
        end

        pathLength = tonumber(pathLength)
        size = tonumber(size) or 0

        if not pathLength or pathLength < 1
            or pathLength > 4096
            or size < 0 or size > 9007199254740991 then
            fail("Tamaño inválido")
        end

        local relative = readExact(input, pathLength)

        if not validPath(relative) then
            fail("Ruta no permitida: " .. relative)
        end

        if getLine() ~= "" then
            fail("Separador de ruta inválido")
        end

        local target = fs.combine(destination, relative)

        if kind == "D" then
            fs.makeDir(target)

        elseif kind == "F" then
            local parent = fs.getDir(target)
            if parent ~= "" then
                fs.makeDir(parent)
            end

            local output = fs.open(target, "wb")
            if not output then
                fail("No se pudo crear: " .. relative)
            end

            local remaining = size

            while remaining > 0 do
                local amount = math.min(8192, remaining)
                local data = readExact(input, amount)

                output.write(data)
                remaining = remaining - #data
            end

            output.close()

            if getLine() ~= "" then
                fail("Separador de archivo inválido")
            end
        end

        count = count + 1
    end

    input.close()

    print("Desempaquetado correctamente.")
    print("Elementos: " .. count)
    print("Destino: " .. destination)
end

-- Interfaz de comandos

local command, source, destination = ...

if command == "pack" then
    if not source or not destination then
        print("Uso: fspkg pack <carpeta> <archivo.fsPKG>")
        return
    end

    pack(source, destination)

elseif command == "unpack" then
    if not source or not destination then
        print("Uso: fspkg unpack <archivo.fsPKG> <carpeta>")
        return
    end

    unpackFile(source, destination)

else
    print("fsPKG v1")
    print("")
    print("Comandos:")
    print(" fspkg pack <carpeta> <archivo.fsPKG>")
    print(" fspkg unpack <archivo.fsPKG> <carpeta>")
end
