-- data-transfer.lua
-- Transferencia de archivos y carpetas para CC:Tweaked

-- CONFIGURACION
local PROTOCOL = "data-transfer-v1"
local CHUNK_SIZE = 4000
local TIMEOUT = 30

-- ABRIR MODEM
local modem

for _, name in ipairs(peripheral.getNames()) do
    if peripheral.getType(name) == "modem" then
        modem = name
        break
    end
end

if not modem then
    error("No se encontro ningun modem.")
end

rednet.open(modem)

-- FUNCIONES DE RED

local function sendPacket(id, packet, sequence)
    packet.seq = sequence
    rednet.send(id, packet, PROTOCOL)

    while true do
        local sender, response = rednet.receive(PROTOCOL, TIMEOUT)

        if not sender then
            return false
        end

        if sender == id
        and type(response) == "table"
        and response.type == "ack"
        and response.seq == sequence then
            return true
        end
    end
end

local function receivePacket(id)
    while true do
        local sender, message = rednet.receive(PROTOCOL, TIMEOUT)

        if not sender then
            return nil
        end

        if sender == id and type(message) == "table" then
            rednet.send(id, {
                type = "ack",
                seq = message.seq
            }, PROTOCOL)

            return message
        end
    end
end

-- SERVIDOR

local function server()
    print("Data Transfer - SERVIDOR")
    print("ID: " .. os.getComputerID())
    print("Protocolo: " .. PROTOCOL)
    print("Esperando solicitudes...")

    while true do
        local id, request = rednet.receive(PROTOCOL)

        if type(request) == "table"
        and request.type == "get"
        and type(request.path) == "string" then

            local path = fs.combine("/", request.path)

            print("Solicitud de PC #" .. id)
            print("Ruta: " .. path)

            if path == "/" or not fs.exists(path) then
                sendPacket(id, {
                    type = "error",
                    message = "Archivo o carpeta inexistente."
                }, 1)

            else
                local sequence = 0

                local function send(packet)
                    sequence = sequence + 1
                    return sendPacket(id, packet, sequence)
                end

                local root = fs.getName(path)

                if root == "" then
                    root = "root"
                end

                local isDirectory = fs.isDir(path)

                local success = send({
                    type = "begin",
                    root = root,
                    directory = isDirectory
                })

                -- ENVIAR ARCHIVO
                local function sendFile(filePath, relative)
                    local file = fs.open(filePath, "rb")

                    if not file then
                        return false
                    end

                    if not send({
                        type = "file_start",
                        path = relative
                    }) then
                        file.close()
                        return false
                    end

                    while true do
                        local data = file.read(CHUNK_SIZE)

                        if not data or #data == 0 then
                            break
                        end

                        if not send({
                            type = "chunk",
                            data = data
                        }) then
                            file.close()
                            return false
                        end
                    end

                    file.close()

                    return send({
                        type = "file_end"
                    })
                end

                -- RECORRER CARPETAS
                local function sendDirectory(dirPath, relative)
                    local entries = fs.list(dirPath)
                    table.sort(entries)

                    for _, name in ipairs(entries) do
                        local fullPath = fs.combine(dirPath, name)
                        local relPath

                        if relative == "" then
                            relPath = name
                        else
                            relPath = fs.combine(relative, name)
                        end

                        if fs.isDir(fullPath) then
                            if not send({
                                type = "dir",
                                path = relPath
                            }) then
                                return false
                            end

                            if not sendDirectory(fullPath, relPath) then
                                return false
                            end
                        else
                            if not sendFile(fullPath, relPath) then
                                return false
                            end
                        end
                    end

                    return true
                end

                if success then
                    if isDirectory then
                        success = sendDirectory(path, "")
                    else
                        success = sendFile(path, root)
                    end
                end

                if success then
                    success = send({
                        type = "done"
                    })
                end

                if success then
                    print("Transferencia completada.")
                else
                    print("Transferencia interrumpida.")
                end
            end
        end
    end
end

-- CLIENTE

local function client(serverId, remotePath, localPath)
    print("Data Transfer - CLIENTE")
    print("Servidor: #" .. serverId)
    print("Solicitando: " .. remotePath)

    rednet.send(serverId, {
        type = "get",
        path = remotePath
    }, PROTOCOL)

    local message = receivePacket(serverId)

    if not message then
        print("Tiempo de espera agotado.")
        return
    end

    if message.type == "error" then
        print("Error: " .. tostring(message.message))
        return
    end

    if message.type ~= "begin" then
        print("Respuesta inesperada.")
        return
    end

    local isDirectory = message.directory
    local rootPath

    if isDirectory then
        rootPath = fs.combine(localPath, message.root)

        if fs.exists(rootPath) and not fs.isDir(rootPath) then
            print("Error: el destino ya es un archivo.")
            return
        end

        fs.makeDir(rootPath)
    else
        rootPath = localPath
    end

    print("Recibiendo...")
    print("Destino: " .. rootPath)

    local currentFile
    local failed = false

    local function getPath(relative)
        if not isDirectory then
            return localPath
        end

        if relative == "" then
            return rootPath
        end

        return fs.combine(rootPath, relative)
    end

    while true do
        message = receivePacket(serverId)

        if not message then
            print("Conexion perdida.")
            break
        end

        if message.type == "dir" then
            local path = getPath(message.path)

            local ok = pcall(fs.makeDir, path)

            if not ok then
                failed = true
            end

        elseif message.type == "file_start" then
            local path = getPath(message.path)
            local parent = fs.getDir(path)

            if parent ~= "" then
                pcall(fs.makeDir, parent)
            end

            local ok, handle = pcall(fs.open, path, "wb")

            if ok and handle then
                currentFile = handle
            else
                currentFile = nil
                failed = true
                print("No se pudo crear: " .. path)
            end

        elseif message.type == "chunk" then
            if currentFile then
                local ok = pcall(currentFile.write, message.data)

                if not ok then
                    pcall(currentFile.close)
                    currentFile = nil
                    failed = true
                end
            end

        elseif message.type == "file_end" then
            if currentFile then
                currentFile.close()
                currentFile = nil
            end

        elseif message.type == "done" then
            if currentFile then
                currentFile.close()
                currentFile = nil
            end

            break

        elseif message.type == "error" then
            print("Error: " .. tostring(message.message))
            failed = true
            break
        end
    end

    if failed then
        print("Transferencia terminada con errores.")
    else
        print("Transferencia completada!")
    end
end

-- INICIO

local args = {...}

if args[1] == "server" then
    server()

elseif args[1] == "get" then
    local id = tonumber(args[2])
    local remote = args[3]
    local destination = args[4]

    if not id or not remote or not destination then
        print("Uso:")
        print("data-transfer.lua get <ID> <remoto> <destino>")
        return
    end

    client(id, remote, destination)

else
    print("Data Transfer")
    print("")
    print("Modos disponibles:")
    print("  server")
    print("  get <ID> <remoto> <destino>")
end
