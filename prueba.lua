local monitor = peripheral.find("monitor")

assert(monitor, "No se encontro un monitor")

monitor.setTextScale(0.5)

local w, h = monitor.getSize()

assert(w >= 32 and h >= 14, "Monitor demasiado pequeno")

-- Crear las ventanas
local keyboardY = h - 13

local win1 = window.create(monitor, 1, keyboardY, w, 14)
local win2 = window.create(monitor, 1, 1, w, h - 14)

win1.setBackgroundColor(colors.gray)
win2.setBackgroundColor(colors.black)

win1.clear()
win2.clear()

-- Estado de las teclas modificadoras
local held = {}

local modifierKeys = {
    shift = keys.leftShift,
    ctrl = keys.leftCtrl,
    alt = keys.leftAlt
}

-- Lista de teclas
local keyboard = {}

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

-- Crear filas distribuyendo el ancho disponible
local function addRow(items, y)
    local count = #items
    local baseWidth = math.floor(w / count)
    local remainder = w % count
    local x = 1

    for i, item in ipairs(items) do
        local width = baseWidth

        if i <= remainder then
            width = width + 1
        end

        addKey(
            item[1],
            x,
            y,
            width,
            item[2],
            item[3]
        )

        x = x + width
    end
end

-- Fila de numeros
addRow({
    {"1", "1", "!"},
    {"2", "2", "@"},
    {"3", "3", "#"},
    {"4", "4", "$"},
    {"5", "5", "%"},
    {"6", "6", "^"},
    {"7", "7", "&"},
    {"8", "8", "*"},
    {"9", "9", "("},
    {"0", "0", ")"}
}, 1)

-- Primera fila de letras
local row1 = {}

for c in ("qwertyuiop"):gmatch(".") do
    table.insert(row1, {c, c, c:upper()})
end

addRow(row1, 3)

-- Segunda fila de letras
local row2 = {
    {"a", "a", "A"},
    {"s", "s", "S"},
    {"d", "d", "D"},
    {"f", "f", "F"},
    {"g", "g", "G"},
    {"h", "h", "H"},
    {"j", "j", "J"},
    {"k", "k", "K"},
    {"l", "l", "L"},
    {"ñ", "ñ", "Ñ"}
}

addRow(row2, 5)

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
    {",", ",", "<"},
    {".", ".", ">"},
    {"-", "-", "_"},
    {"/", "/", "?"},
    {":", ":", ";"},
    {";", ";", ":"},
    {"(", "(", "["},
    {")", ")", "]"},
    {"=", "=", "+"},
    {"+", "+", "*"}
}

addRow(symbols, 9)

-- Teclas especiales
addKey("Ctrl",    1, 12, 5, nil, nil, "ctrl")
addKey("Alt",     6, 12, 5, nil, nil, "alt")
addKey("Espacio", 11, 12, 8, " ", " ", "char")
addKey("Bksp",    19, 12, 6, nil, nil, "backspace")
addKey("Enter",   25, 12, 8, nil, nil, "enter")

-- Dibujar teclado
local function drawKeyboard()
    win1.clear()

    for _, k in ipairs(keyboard) do
        local active = k.kind and held[k.kind]

        if active then
            win1.setBackgroundColor(colors.lime)
        else
            win1.setBackgroundColor(colors.lightGray)
        end

        win1.setTextColor(colors.black)

        win1.setCursorPos(k.x, k.y)
        win1.write(string.rep(" ", k.width))

        local offset = math.max(0, math.floor((k.width - #k.label) / 2))

        win1.setCursorPos(k.x + offset, k.y)
        win1.write(k.label)
    end

    -- Indicadores de estado
    win1.setBackgroundColor(colors.gray)
    win1.setTextColor(colors.white)

    win1.setCursorPos(1, 14)

    local status = string.format(
        "CTRL:%s ALT:%s SHIFT:%s",
        held.ctrl and "ON" or "OFF",
        held.alt and "ON" or "OFF",
        held.shift and "ON" or "OFF"
    )

    win1.write(status)
end

drawKeyboard()

-- Codigos de teclas
local keyCodes = {}

for c in ("abcdefghijklmnopqrstuvwxyz"):gmatch(".") do
    keyCodes[c] = keys[c]
end

local digitNames = {
    ["1"] = "one",
    ["2"] = "two",
    ["3"] = "three",
    ["4"] = "four",
    ["5"] = "five",
    ["6"] = "six",
    ["7"] = "seven",
    ["8"] = "eight",
    ["9"] = "nine",
    ["0"] = "zero"
}

for digit, name in pairs(digitNames) do
    keyCodes[digit] = keys[name]
end

-- Simular una pulsacion completa
local function tapKey(key, character)
    if key then
        os.queueEvent("key", key, false)
    end

    if character then
        os.queueEvent("char", character)
    end

    if key then
        os.queueEvent("key_up", key)
    end
end

-- Activar o desactivar modificadores
local function toggleModifier(kind)
    local key = modifierKeys[kind]

    if held[kind] then
        os.queueEvent("key_up", key)
        held[kind] = false
    else
        os.queueEvent("key", key, false)
        held[kind] = true
    end
end

-- Procesar pulsaciones del monitor
local function keyboardLoop()
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")

        -- Convertir coordenadas globales a locales
        local localY = y - keyboardY + 1

        for _, k in ipairs(keyboard) do
            if localY == k.y
            and x >= k.x
            and x < k.x + k.width then

                if modifierKeys[k.kind] then
                    toggleModifier(k.kind)

                elseif k.kind == "backspace" then
                    tapKey(keys.backspace)

                elseif k.kind == "enter" then
                    tapKey(keys.enter)

                else
                    local character

                    if held.shift then
                        character = k.shifted
                    else
                        character = k.value
                    end

                    if character then
                        local key = keyCodes[k.value]
                        tapKey(key, character)
                    end
                end

                drawKeyboard()
                break
            end
        end
    end
end

-- Terminal superior
local function terminalLoop()
    term.redirect(win2)

    shell.run("rom/programs/shell.lua")

    term.redirect(term.native())
end

-- Ejecutar ambas tareas
parallel.waitForAny(
    terminalLoop,
    keyboardLoop
)