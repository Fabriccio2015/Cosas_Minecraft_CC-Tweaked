local monitor = peripheral.find("monitor")

assert(monitor, "No se encontro un monitor")

monitor.setTextScale(0.5)

local w, h = monitor.getSize()

-- Crear las ventanas
local win1 = window.create(monitor, 1, h - 13, w, 14)
local win2 = window.create(monitor, 1, 1, w, h - 14)

-- Configurar ventanas
win1.setBackgroundColor(colors.gray)
win2.setBackgroundColor(colors.black)

win1.clear()
win2.clear()

-- Teclado
local keyboard = {}
local shift = false

local function addKey(label, x, y, width, value, shifted, kind)
    table.insert(keyboard, {
        label = label,
        x = x,
        y = y,
        width = width,
        value = value,
        shifted = shifted,
        kind = kind
    })
end

-- Fila de numeros
local nums = {
    {"1", "!"}, {"2", "@"}, {"3", "#"}, {"4", "$"},
    {"5", "%"}, {"6", "^"}, {"7", "&"}, {"8", "*"},
    {"9", "("}, {"0", ")"}
}

for i, v in ipairs(nums) do
    addKey(v[1], 2 + (i - 1) * 3, 1, 3, v[1], v[2])
end

-- Primera fila de letras
local row1 = "qwertyuiop"

for i = 1, #row1 do
    local c = row1:sub(i, i)
    addKey(c, 2 + (i - 1) * 3, 3, 3, c, c:upper())
end

-- Segunda fila de letras
local row2 = {"a","s","d","f","g","h","j","k","l","ñ"}
local upper2 = {"A","S","D","F","G","H","J","K","L","Ñ"}

for i, c in ipairs(row2) do
    addKey(c, 2 + (i - 1) * 3, 5, 3, c, upper2[i])
end

-- Tercera fila
addKey("Shift", 1, 7, 5, nil, nil, "shift")

local row3 = "zxcvbnm"

for i = 1, #row3 do
    local c = row3:sub(i, i)
    addKey(c, 7 + (i - 1) * 3, 7, 3, c, c:upper())
end

addKey("Shift", 28, 7, 5, nil, nil, "shift")

-- Signos de puntuacion
local symbols = {
    {",", "<"}, {".", ">"}, {"-", "_"}, {"/", "?"},
    {":", ";"}, {";", ":"}, {"(", "["}, {")", "]"},
    {"=", "+"}, {"+", "*"}
}

for i, v in ipairs(symbols) do
    addKey(v[1], 2 + (i - 1) * 3, 9, 3, v[1], v[2])
end

-- Teclas especiales
addKey("Ctrl", 1, 12, 5, nil, nil, "ctrl")
addKey("Alt", 7, 12, 5, nil, nil, "alt")
addKey("Espacio", 13, 12, 8, " ", " ", "char")
addKey("Bksp", 22, 12, 5, nil, nil, "backspace")
addKey("Enter", 28, 12, 5, nil, nil, "enter")

-- Dibujar teclado
local function drawKeyboard()
    win1.clear()

    for _, k in ipairs(keyboard) do
        win1.setBackgroundColor(colors.lightGray)
        win1.setTextColor(colors.black)
        win1.setCursorPos(k.x, k.y)
        win1.write(string.rep(" ", k.width))

        local label = k.label
        local offset = math.floor((k.width - #label) / 2)

        win1.setCursorPos(k.x + offset, k.y)
        win1.write(label)
    end

    win1.setBackgroundColor(colors.gray)
    win1.setTextColor(colors.white)
    win1.setCursorPos(1, 14)
    win1.write("Teclado tactil")
end

drawKeyboard()

-- Procesar pulsaciones
local function keyboardLoop()
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")

        for _, k in ipairs(keyboard) do
            if y == k.y and x >= k.x and x < k.x + k.width then

                if k.kind == "shift" then
                    shift = not shift

                elseif k.kind == "backspace" then
                    os.queueEvent("key", keys.backspace)

                elseif k.kind == "enter" then
                    os.queueEvent("key", keys.enter)

                elseif k.kind == "ctrl" then
                    os.queueEvent("key", keys.leftCtrl)
                    os.queueEvent("key_up", keys.leftCtrl)

                elseif k.kind == "alt" then
                    os.queueEvent("key", keys.leftAlt)
                    os.queueEvent("key_up", keys.leftAlt)

                else
                    local character = shift and k.shifted or k.value
                    os.queueEvent("char", character)
                    shift = false
                end

                drawKeyboard()
                break
            end
        end
    end
end

-- Ejecutar una terminal en la ventana superior
local function terminalLoop()
    term.redirect(win2)
    shell.run("rom/programs/shell.lua")
end

parallel.waitForAny(terminalLoop, keyboardLoop)