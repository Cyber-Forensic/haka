%module module

%{
#include <haka/module.h>
#include <haka/config.h>

char *prefix = HAKA_MODULE_PREFIX;
char *suffix = HAKA_MODULE_SUFFIX;

%}

%include "haka/lua/swig.si"

%rename(path) module_get_path;
const char *module_get_path();

%rename(setpath) module_set_path;
void module_set_path(const char *path);

%immutable;
char *prefix;
char *suffix;

%luacode {
	package.cpath = package.cpath .. ";" .. string.gsub(module.path(), '*', module.prefix .. '?' .. module.suffix)
	package.path = package.path .. ";" .. string.gsub(module.path(), '*', '?.lua') .. ";" .. string.gsub(module.path(), '*', '?.bc')

	function module.addpath(newpath)
		if haka.module.path ~= "" then
			haka.module.setpath(haka.module.path() .. ';' .. newpath .. '*')
		else
			haka.module.setpath(newpath .. '*')
		end
	end
}
