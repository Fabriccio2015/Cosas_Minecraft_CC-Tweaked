term.redirect(peripheral.wrap("front"))

function clear()
    term.clear()
    term.setCursorPos(1, 1)
end

local function manejador_reset()
    while true do
        os.pullEvent("redstone")

        if redstone.getInput("top") then
            print("RESET!!!")
            sleep(0.25)
            os.reboot()
        end
    end
end

local function main()
    clear()
    print("FabriPC 3")
    shell.run("motd")
    shell.run("shell")
end

parallel.waitForAny(manejador_reset, main)

clear()
os.shutdown()
