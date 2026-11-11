rednet.open("back")

print("Cliente RNSC iniciado")
print("Destino: 141")

while true do
    local evento = {os.pullEvent()}

    if evento[1] == "key"
    or evento[1] == "key_up"
    or evento[1] == "char"
    or evento[1] == "paste" then

        rednet.send(141, evento, "fabri-rnsc")
    end
end
