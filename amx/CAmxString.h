#pragma once

#include "../main.h"

class StrAmx
{
public:
	std::string GetString( AMX* amx, cell param );
	int	SetString( AMX* amx, cell param, std::string str);
	void SetCString( AMX* amx, cell param, char* str);
	int GetCString(AMX* amx, cell param, char*& dest);
};