print("FabriBIOS Install")
print("Si usa este instalador para una computadora sin pantalla externa, ponga cualquier cosa cuando le pida la pantalla y luego borre la primera linea del startup.lua")
print("En que disco desea guardar la BIOS? (si tiene una BIOS en ese disco podria dejar de funcionar)")
write(">")
local disco_bios = shell.resolve(read())

if not fs.exists(disco_bios) or not fs.isDir(disco_bios) then
    error("El disco que introdujo no existe")
elseif disco_bios == "/" then
    error("No puede usar / como disco de BIOS")
end

print()
print("Indique la ruta del archivo que se ejecutara al arrancar")
write(">")
local medio_arranque = shell.resolve(read())

print()
print("Que nombre de PC desea que aparezca?")
write(">")
local nombre_pc = read()

print()
print("Cual es el nombre de dispositivo/lado en ingles en el que esta su pantalla?")
write(">")
local nombre_pantalla = read()

print()
print("Instalando FabriBIOS...")

print("Creando startup.lua...")

local archivo_startup = fs.open(disco_bios .. "/startup.lua", "w")
if not archivo_startup then
    error("No se pudo crear startup.lua")
end

archivo_startup.writeLine("term.redirect(peripheral.wrap(" .. string.format("%q", nombre_pantalla) .. "))")
archivo_startup.writeLine("term.setCursorBlink(true)")
archivo_startup.writeLine("shell.run(\"clear\")")
archivo_startup.writeLine("shell.setDir(" .. string.format("%q", disco_bios) .. ")")
archivo_startup.writeLine("shell.run(\"main.lua\")")
archivo_startup.writeLine("shell.run(\"clear\")")
archivo_startup.writeLine("term.setCursorBlink(false)")
archivo_startup.writeLine("os.shutdown()")
archivo_startup.close()

print("startup.lua creado!")
archivo_startup = nil

print()
print("Creando main.lua...")

local archivo_main = fs.open(disco_bios .. "/main.lua", "w")
if not archivo_main then
    error("No se pudo crear main.lua")
end

archivo_main.writeLine("print(" .. string.format("%q", nombre_pc) .. ")")
archivo_main.writeLine("print(\"FabriBIOS\")")
archivo_main.writeLine("print(" .. string.format("%q", "Arrancando en " .. medio_arranque) .. ")")
archivo_main.writeLine("sleep(3)")
archivo_main.writeLine("term.clear()")
archivo_main.writeLine("term.setCursorPos(1,1)")
archivo_main.writeLine("shell.run(" .. string.format("%q", medio_arranque) .. ")")
archivo_main.writeLine("sleep(5)")
archivo_main.close()

print("main.lua creado!")

print("FabriBIOS instalado!")
