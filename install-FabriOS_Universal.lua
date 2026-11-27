print("Instalador de FabriOS Universal")
print("Version del instalador: 1.0")
local URL_BASE = "https://github.com/Fabriccio2015/Cosas_Minecraft_CC-Tweaked/raw/refs/heads/main"
local ubicacion_fspkg = "/fspkg.lua"
local ubicacion_fabrios = "/FabriOS_Universal.fsPKG"
print("Instalando FabriOS Universal...")
shell.run("wget " .. URL_BASE .. ubicacion_fabrios .. " /FabriOS_Universal.fsPKG")
shell.run("wget run " .. URL_BASE .. ubicacion_fspkg .. " unpack /FabriOS_Universal.fsPKG /fabrios")
print("FabriOS Universal Instalado!")
print("Para iniciarlo ejecute este comando: '/fabrios/system/init'")
print("Si desea que se ejecute al encender, configure el archivo startup.lua")
