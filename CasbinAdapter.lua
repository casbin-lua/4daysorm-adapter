--Copyright 2021 The casbin Authors. All Rights Reserved.
--
--Licensed under the Apache License, Version 2.0 (the "License");
--you may not use this file except in compliance with the License.
--You may obtain a copy of the License at
--
--    http://www.apache.org/licenses/LICENSE-2.0
--
--Unless required by applicable law or agreed to in writing, software
--distributed under the License is distributed on an "AS IS" BASIS,
--WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--See the License for the specific language governing permissions and
--limitations under the License.

local Adapter = require("src.persist.Adapter")
local Util = require("src.util.Util")
local Table = require("orm.model")
local fields = require("orm.tools.fields")

local _M = {}

function _M:new()
    local o = {}
    self.__index = self
    setmetatable(o, self)
    o.conn = Table({
        __tablename__ = "casbin",
        ptype = fields.CharField({null = false, max_length = 255}),
        v0 = fields.CharField({null = true, max_length = 255}),
        v1 = fields.CharField({null = true, max_length = 255}),
        v2 = fields.CharField({null = true, max_length = 255}),
        v3 = fields.CharField({null = true, max_length = 255}),
        v4 = fields.CharField({null = true, max_length = 255}),
        v5 = fields.CharField({null = true, max_length = 255})
    })
    return o
end

-- Filter for filtered policies
local Filter = {
    ptype = "",
    v0 = "",
    v1 = "",
    v2 = "",
    v3 = "",
    v4 = "",
    v5 = ""
}

--[[
    * loadPolicy loads all policy rules from the storage.
]]
function _M:loadPolicy(model)
    local rows = self.conn.get:all()
    for _, row in pairs(rows) do
        local r = {}
        table.insert(r, row["ptype"])
        for i = 0, 5 do
            table.insert(r, row["v"..tostring(i)])
        end
        local line = table.concat(r, ", ")
        Adapter.loadPolicyLine(line, model)
    end
end

function _M:savePolicyLine(ptype, rule)
    local row = {
        ptype = ptype
    }
    for i = 0, 5 do
        row["v"..tostring(i)] = rule[i+1]
    end
    local policy = self.conn(row)
    policy:save()
end

--[[
    * savePolicy saves all policy rules to the storage.
]]
function _M:savePolicy(model)
    self.conn.get:where({ptype = "p"}):delete()
    self.conn.get:where({ptype = "g"}):delete()

    if model.model["p"] then
        for ptype, ast in pairs(model.model["p"]) do
            for _, rule in pairs(ast.policy) do
                self:savePolicyLine(ptype, rule)
            end
        end
    end

    if model.model["g"] then
        for ptype, ast in pairs(model.model["g"]) do
            for _, rule in pairs(ast.policy) do
                self:savePolicyLine(ptype, rule)
            end
        end
    end
end

--[[
    * addPolicy adds a policy rule to the storage.
]]
function _M:addPolicy(_, ptype, rule)
    self:savePolicyLine(ptype, rule)
end

--[[
    * addPolicies adds policy rules to the storage.
]]
function _M:addPolicies(_, ptype, rules)
    for _, rule in pairs(rules) do
        self:savePolicyLine(ptype, rule)
    end
end

--[[
    * removePolicy removes a policy rule from the storage.
]]
function _M:removePolicy(_, ptype, rule)
    local policy = {
        ptype = ptype
    }
    for i = 0, 5 do
        policy["v"..tostring(i)] = rule[i+1]
    end
    self.conn.get:where(policy):delete()
end

--[[
    * removePolicies removes policy rules from the storage.
]]
function _M:removePolicies(_, ptype, rules)
    for _, rule in pairs(rules) do
        self:removePolicy(_, ptype, rule)
    end
end

--[[
    * updatePolicy updates a policy rule from the storage
]]
function _M:updatePolicy(_, ptype, oldRule, newRule)
    local oldPolicy = {
        ptype = ptype
    }
    for i = 0, 5 do
        oldPolicy["v"..tostring(i)] = oldRule[i+1]
    end
    local newPolicy = {
        ptype = ptype
    }
    for i = 0, 5 do
        newPolicy["v"..tostring(i)] = newRule[i+1]
    end
    self.conn.get:where(oldPolicy):update(newPolicy)
end

--[[
    * loadFilteredPolicy loads the policy rules that match the filter from the storage.
]]
function _M:loadFilteredPolicy(model, filter)
    local values = {}
    for col, val in pairs(filter) do
        if not Filter[col] then
            error("Invalid filter column " .. col)
        end
        if Util.trim(val) ~= "" then
            values[col] = Util.trim(val)
        end
    end

    local rows = self.conn.get:where(values):all()
    for _, row in pairs(rows) do
        local r = {}
        table.insert(r, row["ptype"])
        for i = 0, 5 do
            table.insert(r, row["v"..tostring(i)])
        end
        local line = table.concat(r, ", ")
        Adapter.loadPolicyLine(line, model)
    end
end

--[[
    * removeFilteredPolicy removes the policy rules that match the filter from the storage.
]]
function _M:removeFilteredPolicy(_, ptype, fieldIndex, fieldValues)
    local values = {}
    values["ptype"] = ptype
    for i = fieldIndex + 1, #fieldValues do
        if Util.trim(fieldValues[i]) ~= "" then
            values["v"..tostring(i-1)] = fieldValues[i]
        end
    end
    self.conn.get:where(values):delete()
end

return _M
