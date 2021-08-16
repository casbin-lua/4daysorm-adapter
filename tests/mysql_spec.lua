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

local path = os.getenv("PWD") or io.popen("cd"):read()
package.path = package.path .. ";" .. path .. "/4DaysORM/?.lua"

_G.DB = {
    type = "mysql",
    name = "casbin",
    username = "root",
    password = "root",
    new = true,
    backtrace = true,
    DEBUG = true
}

local Adapter = require("CasbinAdapter")
local Enforcer = require("casbin")

local function initDB()
    local a = Adapter:new()
    a.conn.get:where({ptype = "p"}):delete()
    a.conn.get:where({ptype = "g"}):delete()
    local row = {
        ptype = "p",
        v0 = "alice",
        v1 = "data1",
        v2 = "read"
    }
    a.conn(row):save()
    row = {
        ptype = "p",
        v0 = "bob",
        v1 = "data2",
        v2 = "write"
    }
    a.conn(row):save()
    row = {
        ptype = "p",
        v0 = "data2_admin",
        v1 = "data2",
        v2 = "read"
    }
    a.conn(row):save()
    row = {
        ptype = "p",
        v0 = "data2_admin",
        v1 = "data2",
        v2 = "write"
    }
    a.conn(row):save()
    row = {
        ptype = "g",
        v0 = "alice",
        v1 = "data2_admin"
    }
    a.conn(row):save()
    return a
end

local function getEnforcer()
    local e = Enforcer:new(path .. "/tests/rbac_model.conf", path .. "/tests/empty_policy.csv")
    local a = initDB()
    e.adapter = a
    e:loadPolicy()
    return e
end

describe("Casbin MySQL Adapter tests", function ()
    it("Load Policy test", function ()
        local e = getEnforcer()
        assert.is.True(e:enforce("alice", "data1", "read"))
        assert.is.False(e:enforce("bob", "data1", "read"))
        assert.is.True(e:enforce("bob", "data2", "write"))
        assert.is.True(e:enforce("alice", "data2", "read"))
        assert.is.True(e:enforce("alice", "data2", "write"))
    end)

    it("Load Filtered Policy test", function ()
        local e = getEnforcer()
        e:clearPolicy()
        assert.is.Same({}, e:GetPolicy())

        assert.has.error(function ()
            local filter = {"alice", "data1"}
            e:loadFilteredPolicy(filter)
        end)

        local filter = {
            ["v0"] = "bob"
        }
        e:loadFilteredPolicy(filter)
        assert.is.Same({{"bob", "data2", "write"}}, e:GetPolicy())
        e:clearPolicy()

        filter = {
            ["v2"] = "read"
        }
        e:loadFilteredPolicy(filter)
        assert.is.Same({
            {"alice", "data1", "read"},
            {"data2_admin", "data2", "read"}
        }, e:GetPolicy())
        e:clearPolicy()

        filter = {
            ["v0"] = "data2_admin",
            ["v2"] = "write"
        }
        e:loadFilteredPolicy(filter)
        assert.is.Same({{"data2_admin", "data2", "write"}}, e:GetPolicy())
    end)

    it("Add Policy test", function ()
        local e = getEnforcer()
        assert.is.False(e:enforce("eve", "data3", "read"))
        e:AddPolicy("eve", "data3", "read")
        assert.is.True(e:enforce("eve", "data3", "read"))
    end)

    it("Add Policies test", function ()
        local e = getEnforcer()
        local policies = {
            {"u1", "d1", "read"},
            {"u2", "d2", "read"},
            {"u3", "d3", "read"}
        }
        e:clearPolicy()
        e.adapter:savePolicy(e.model)
        assert.is.Same({}, e:GetPolicy())

        e:AddPolicies(policies)
        e:clearPolicy()
        e:loadPolicy()
        assert.is.Same(policies, e:GetPolicy())
    end)

    it("Save Policy test", function ()
        local e = getEnforcer()
        assert.is.False(e:enforce("alice", "data4", "read"))

        e.model:clearPolicy()
        e.model:addPolicy("p", "p", {"alice", "data4", "read"})
        e.adapter:savePolicy(e.model)
        e:loadPolicy()

        assert.is.True(e:enforce("alice", "data4", "read"))
    end)

    it("Remove Policy test", function ()
        local e = getEnforcer()
        assert.is.True(e:HasPolicy("alice", "data1", "read"))
        e:RemovePolicy("alice", "data1", "read")
        assert.is.False(e:HasPolicy("alice", "data1", "read"))
    end)

    it("Remove Policies test", function ()
        local e = getEnforcer()
        local policies = {
            {"alice", "data1", "read"},
            {"bob", "data2", "write"},
            {"data2_admin", "data2", "read"},
            {"data2_admin", "data2", "write"}
        }
        assert.is.Same(policies, e:GetPolicy())
        e:RemovePolicies({
            {"data2_admin", "data2", "read"},
            {"data2_admin", "data2", "write"}
        })

        policies = {
            {"alice", "data1", "read"},
            {"bob", "data2", "write"}
        }
        assert.is.Same(policies, e:GetPolicy())
    end)

    it("Update Policy test", function ()
        local e = getEnforcer()
        local policies = {
            {"alice", "data1", "read"},
            {"bob", "data2", "write"},
            {"data2_admin", "data2", "read"},
            {"data2_admin", "data2", "write"}
        }
        assert.is.Same(policies, e:GetPolicy())

        e:UpdatePolicy(
            {"bob", "data2", "write"},
            {"bob", "data2", "read"}
        )
        policies = {
            {"alice", "data1", "read"},
            {"bob", "data2", "read"},
            {"data2_admin", "data2", "read"},
            {"data2_admin", "data2", "write"}
        }

        assert.is.Same(policies, e:GetPolicy())
    end)

    it("Remove Filtered Policy test", function ()
        local e = getEnforcer()
        assert.is.True(e:enforce("alice", "data1", "read"))
        e:RemoveFilteredPolicy(1, "data1")
        assert.is.False(e:enforce("alice", "data1", "read"))

        assert.is.True(e:enforce("bob", "data2", "write"))
        assert.is.True(e:enforce("alice", "data2", "read"))
        assert.is.True(e:enforce("alice", "data2", "write"))

        e:RemoveFilteredPolicy(1, "data2", "read")

        assert.is.True(e:enforce("bob", "data2", "write"))
        assert.is.False(e:enforce("alice", "data2", "read"))
        assert.is.True(e:enforce("alice", "data2", "write"))

        e:RemoveFilteredPolicy(1, "data2")

        assert.is.False(e:enforce("bob", "data2", "write"))
        assert.is.False(e:enforce("alice", "data2", "read"))
        assert.is.False(e:enforce("alice", "data2", "write"))
    end)
end)