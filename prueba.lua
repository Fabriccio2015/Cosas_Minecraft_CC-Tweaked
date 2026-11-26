term.redirect(peripheral.wrap("front"))

function clear()
    term.clear()
    term.setCursorPos(1, 1)
end

clear()
print("FabriPC 3")
shell.run("motd")
shell.run("shell")
clear()
os.shutdown()
