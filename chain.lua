local bitser = require("bitser")
local data = io.open("data", "r")
local tokens = bitser.loads(data:read("*a"))
data:close()

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