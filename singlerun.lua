local tokens = {}
local file = io.open("source.txt", "r")

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

local possibilities = {}
local ptotal = 0
for i,v in pairs(tokens) do
    if i ~= "__fnord" and i ~= "__fnordpunc" and not v.fnorded and v.type == "word" then
        possibilities[#possibilities+1] = v
        ptotal = ptotal + v.hits
    end
end
local pvalue = math.random(1, ptotal)
local current = tokens.__fnord
for i,v in ipairs(possibilities) do
    pvalue = pvalue - v.hits
    if pvalue <= 0 then
        current = v
        break
    end
end

local output = ""
for i=1, math.random(40, 120) do
    output = output..current.token
    local nexts = {}
    local ntotal = 0
    for i,v in pairs(current.next) do
        local token = tokens[i]
        nexts[#nexts+1] = {token, v}
        ntotal = ntotal + v
    end
    local nvalue = math.random(1, ntotal)
    local next = tokens.__fnord
    for i,v in ipairs(nexts) do
        nvalue = nvalue - v[2]
        if nvalue <= 0 then
            next = v[1]
            break
        end
    end
    if next.fnorded then next = next.type == "word" and tokens.__fnord or tokens.__fnordpunc end
    if current.type == "word" and next.type == "word" then output = output.." " end
    current = next
end
local _, punc = output:gsub("[.?!]", "")
if punc == 0 then print(output) return end
local ppick = math.random(1, punc or 1)
local pi = 0
for n in output:gmatch("[.?!]+()") do
    pi = pi + 1
    if pi == ppick then
        print(output:sub(0, n-1))
        return
    end
end