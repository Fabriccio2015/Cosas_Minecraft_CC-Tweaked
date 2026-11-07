local i = 0
local teclas = {}

while true do
    local timer = os.startTimer(1)

    while true do
        local evento, valor = os.pullEvent()

        if evento == "key" then
            teclas[valor] = true

            if valor == keys.e then
                return
            end

        elseif evento == "key_up" then
            teclas[valor] = false

        elseif evento == "timer" and valor == timer then
            break
        end
    end

    i=i+1
    print(i)
end