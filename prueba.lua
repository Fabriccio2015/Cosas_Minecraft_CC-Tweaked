local tipo_error = ""
function morse(texto, frecuencia)
    frecuencia = frecuencia or 800

    local speaker = peripheral.find("speaker")

    local sampleRate = 48000

    local function tono(duracion)
        local muestras = {}

        for i = 1, math.floor(sampleRate * duracion) do
            muestras[i] = math.sin(
                2 * math.pi * frecuencia * i / sampleRate
            ) * 0.5
        end

        while not speaker.playAudio(muestras) do
            os.pullEvent("speaker_audio_empty")
        end
    end

    for simbolo in texto:gmatch(".") do
        if simbolo == "." then
            tono(0.15)
        elseif simbolo == "-" then
            tono(0.45)
        end

        sleep(0.15)
    end
end

function clear()
    term.clear()
    term.setCursorPos(1, 1)
end

local monitor = peripheral.wrap("front")
if monitor then
    term.redirect(monitor)
else
    tipo_error = "pantalla"
end

if tipo_error == "" then
    clear()
    print("FabriPC 3")
    shell.run("motd")
    shell.run("shell")
    clear()
    os.shutdown()
end

clear()
write("ERROR: ")
if tipo_error == "pantalla" then
    print("No hay Pantalla!!!")
    while true do
        morse("... --- ...")
        sleep(1.25)
    end
end
