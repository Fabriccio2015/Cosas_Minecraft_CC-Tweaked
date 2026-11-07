local salida = ""

local terminal = {}

term.redirect(peripheral.wrap("top"))

local terminalOriginal = term.current()

-- Copiar las funciones originales
for nombre, funcion in pairs(terminalOriginal) do
    if type(funcion) == "function" then
        terminal[nombre] = function(...)
            local resultado = funcion(...)
            return resultado
        end
    end
end

-- Capturar y mostrar write()
function terminal.write(texto)
    texto = tostring(texto)

    salida = salida .. texto

    terminalOriginal.write(texto)
end

-- Capturar y mostrar blit()
function terminal.blit(texto, coloresTexto, coloresFondo)
    salida = salida .. texto

    terminalOriginal.blit(texto, coloresTexto, coloresFondo)
end

-- Redirigir la terminal
term.redirect(terminal)

-- Ejecutar programa
shell.run("shell")

-- Restaurar la terminal original
term.redirect(terminalOriginal)

-- Imprimir salida capturada
nombre_impresora = "printer_5"
local impresora = peripheral.wrap(nombre_impresora)

impresora.newPage()

local y = 1

for linea in (salida .. "\n"):gmatch("(.-)\n") do
    impresora.setCursorPos(1, y)
    impresora.write(linea)
    y = y + 1
end

impresora.endPage()
impresora.print()