// Runs one Lua test file under Fengari (npm install fengari) against the addon folder given second.
// From the addon folder: node tests/run.js tests/loot.lua .
const { lua, lauxlib, lualib, to_luastring } = require("fengari");
const fs = require("fs");
const addonDir = process.argv[3] || ".";
const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);
lua.lua_pushstring(L, to_luastring(addonDir)); lua.lua_setglobal(L, to_luastring("ADDON_DIR"));
lua.lua_pushstring(L, to_luastring(fs.readFileSync(addonDir + "/Looti.toc", "utf8"))); lua.lua_setglobal(L, to_luastring("TOC"));
if (lauxlib.luaL_dofile(L, to_luastring(process.argv[2])) !== 0) {
    console.log("LUA ERROR:", lua.lua_tojsstring(L, -1));
    process.exit(1);
}
