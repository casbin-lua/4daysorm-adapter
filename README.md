# 4daysorm-adapter

[![GitHub Action](https://github.com/casbin-lua/4daysorm-adapter/workflows/test/badge.svg?branch=master)](https://github.com/casbin-lua/4daysorm-adapter/actions)
[![Coverage Status](https://coveralls.io/repos/github/casbin-lua/4daysorm-adapter/badge.svg?branch=master)](https://coveralls.io/github/casbin-lua/4daysorm-adapter?branch=master)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/casbin/lobby)

casbin-orm-adapter is a [4DaysORM](https://github.com/itdxer/4DaysORM) based adapter for Casbin that supports policies from MySQL and SQLite3 databases.

## Installation

First, install the corresponding driver of LuaSQL from LuaRocks based on the database you use:
- For MySQL, install luasql-mysql.
- For SQLite3, install luasql-sqlite3.

Then install the casbin-orm-adapter from LuaRocks by:
```bash
sudo luarocks install https://raw.githubusercontent.com/casbin-lua/4daysorm-adapter/master/casbin-orm-adapter-1.0.0-1.rockspec
```

## Usage

To create a new Casbin Enforcer using the adapter, you need to create a global variable `DB` containing the database configuration details (more details [here](https://github.com/itdxer/4DaysORM#database-configuration)):
```lua
DB = {
    type = "mysql", -- or "sqlite3"
    name = "your_database_name",
    username = "your_username",
    password = "your_password",
    new = true
}

local Enforcer = require("casbin")
local Adapter = require("CasbinAdapter")

local a = Adapter:new() -- uses the global DB configuration
local e = Enforcer:new("/path/to/model.conf", a) -- creates a new Casbin enforcer with the model.conf file and the database
```

## Getting Help

- [Lua Casbin](https://github.com/casbin/lua-casbin)

## License

This project is under Apache 2.0 License. See the [LICENSE](https://github.com/casbin-lua/4daysorm-adapter/blob/master/LICENSE) file for the full license text.