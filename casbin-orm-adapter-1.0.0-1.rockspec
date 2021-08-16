package = "casbin-orm-adapter"
version = "1.0.0-1"
source = {
   url = "git://github.com/casbin-lua/4daysorm-adapter"
}
description = {
   summary = "4DaysORM based adapter for Casbin",
   detailed = [[
      4DaysORM based adapter for Casbin which supports policies from MySQL and SQLite3 databases.
   ]],
   detailed = "4DaysORM based adapter for Casbin which supports policies from MySQL and SQLite3 databases.",
   homepage = "https://github.com/casbin-lua/4daysorm-adapter",
   license = "Apache License 2.0",
   maintainer = "admin@casbin.org"
}
dependencies = {
   "casbin >= 1.29.0"
}
build = {
   type = "builtin",
   modules = {
      ["CasbinORMAdapter"] = "CasbinAdapter.lua",
      ["orm.model"] = "4DaysORM/orm/model.lua",
      ["orm.tools.fields"] = "4DaysORM/orm/tools/fields.lua",
      ["orm.tools.func"] = "4DaysORM/orm/tools/func.lua",
      ["orm.class.fields"] = "4DaysORM/orm/class/fields.lua",
      ["orm.class.global"] = "4DaysORM/orm/class/global.lua",
      ["orm.class.property"] = "4DaysORM/orm/class/property.lua",
      ["orm.class.query_list"] = "4DaysORM/orm/class/query_list.lua",
      ["orm.class.query"] = "4DaysORM/orm/class/query.lua",
      ["orm.class.select"] = "4DaysORM/orm/class/select.lua",
      ["orm.class.table"] = "4DaysORM/orm/class/table.lua",
      ["orm.class.type"] = "4DaysORM/orm/class/type.lua"
   }
}