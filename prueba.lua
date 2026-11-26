function clear()
    term.clear()
    term.setCursorPos(1, 1)
end

local monitor = peripheral.wrap("front")
if monitor then
    term.redirect(monitor)
else
    print("No hay pantalla, usando la pantalla integrada de la compu")
end

clear()
print("FabriPC 3")
shell.run("motd")
shell.run("shell")
clear()
os.shutdown()
