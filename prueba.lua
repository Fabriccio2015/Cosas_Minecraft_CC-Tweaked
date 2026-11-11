local l = {}

function l.deepCopy(original, copies)
    copies = copies or {}

    if type(original) ~= "table" then
        return original
    end

    if copies[original] then
        return copies[original]
    end

    local copy = {}
    copies[original] = copy

    for k, v in pairs(original) do
        copy[l.deepCopy(k, copies)] = l.deepCopy(v, copies)
    end

    return setmetatable(copy, getmetatable(original))
end

return l
