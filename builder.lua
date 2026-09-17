local bitser = require("bitser")

local tokens = {}

local file = io.open("aadenyt.txt", "r")

local prevtoken
local token = ""
local ttype = ""
while true do
    local char = file:read(1)
    if char then char = char:lower() end
    local ctype = not char and "" or (char:match("[A-Za-z0-9]") and "word" or "punctuation")
    if ttype == "" or token == "fnord" then
        token = char
        ttype = ctype
    elseif char == "'" or (ttype == ctype and (ctype == "word" or ctype == "" or char == " " or token:match("^[%"..char.." ]+$"))) then
        token = token..char
    elseif token:match("^ +$") then
        token = char
        ttype = ctype
    else
        tokens[token] = tokens[token] or {
            token = token,
            type = ttype,
            hits = 0,
            total = 0,
            amount = 0,
            next = {}
        }
        tokens[token].hits = tokens[token].hits + 1
        if prevtoken then
            prevtoken.total = prevtoken.total + (prevtoken.next[token] and 0 or 1)
            prevtoken.next[token] = (prevtoken.next[token] or 0) + 1
        end
        prevtoken = tokens[token]
        token = char
        ttype = ctype
    end
    if not char then break end
end
file:close()

local fnord = {
    token = "fnord",
    type = "word",
    hits = -1,
    total = 0,
    next = {}
}
local fnordpunc = {
    token = " fnord. ",
    type = "punctuation",
    hits = -1,
    total = 0,
    next = {}
}
local trimmed = 0
for i,v in pairs(tokens) do
    if not v.fnorded then
        local sum = 0
        for o,b in pairs(v.next) do
            sum = sum + b
        end
        local average = sum / v.total
        for o,b in pairs(v.next) do
            if b < average then
                v.next[o] = nil
                v.total = v.total - 1
                trimmed = trimmed + 1
            end
        end
    end
end
local total = 0
for i,v in pairs(tokens) do
    if v.hits < 4 or v.total == 0 then
        --print("Fnorded: "..i.." ("..v.type..")")
        v.fnorded = true
        local obj = v.type == "word" and fnord or fnordpunc
        obj.total = obj.total + v.total
        for o,b in pairs(v.next) do
            obj.next[o] = (obj.next[o] or 0) + b
        end
    else
        total = total + 1
        --print("NOT Fnorded: "..i.." ("..v.type..")")
    end
end

tokens.__fnord = fnord
tokens.__fnordpunc = fnordpunc
print(total.." non-fnorded tokens, "..trimmed.." trimmed connections")

local outfile = io.open("data", "w")
outfile:write(bitser.dumps(tokens))
outfile:close()