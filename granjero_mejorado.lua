print("Granjero Automatico")
print("Programado por: Fabriccio (Fabri2015)")
sleep(2)
print("Coloque las semillas en el slot 1 y pulse cualquier tecla... ")
_, _ = os.pullEvent("key")
local espera_entre_ejecuciones = 20
local filas = 7
local columnas = 7
local fila_actual = 1
local columna_actual = 1
while true do
    turtle.select(16)
    turtle.refuel(2)
    turtle.select(1)
    for fila_actual=1,filas do
        print("Fila #" .. tostring(fila_actual))
        turtle.turnRight()
        for columna_actual=1,columnas do
            print("Columna #" .. tostring(columna_actual))
            local exito, datos = turtle.inspectDown()
            if exito and datos.name == "minecraft:wheat" then
                if datos.state.age == 7 then
                    print("Cultivo crecido!")
                    turtle.digDown()
                    turtle.select(1)
                    turtle.placeDown()
                else
                    print("Cultivo sin crecer!")
                end
            end
            print("Avanzando a la siguiente columna...")
            if columna_actual < columnas then
                turtle.forward()
            end
        end
        turtle.turnLeft()
        turtle.turnLeft()
        print("Volviendo a la columna 1...")
        for columna_actual=columnas, 1, -1 do 
            if columna_actual > 1 then
                turtle.forward()
            end
        end
        turtle.turnRight()
        if fila_actual < filas then
            print("Avanzando a la siguiente fila...")
            turtle.forward()
        end
    end
    print("Volviendo a la posicion fila #1 columna #1...")
    turtle.turnLeft()
    turtle.turnLeft()
    for fila_actual=filas, 1, -1 do
        if fila_actual>1 then
            turtle.forward()
        end
    end
    turtle.turnRight()
    turtle.turnRight()
    turtle.turnRight()
    turtle.turnRight()
    print("Trigo cosechado y replantado")
    turtle.select(2)
    turtle.drop(64)
    sleep(espera_entre_ejecuciones)
    turtle.turnLeft()
    turtle.turnLeft()
end
