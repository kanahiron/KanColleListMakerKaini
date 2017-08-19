#module "execwMod"

#define global execw(%1, %2) CreateProcess (%1), " "+(%2), 0, 0, 0, 0, 0, 0, varptr(_startupinfo@execwMod), varptr(_procinfo@execwMod)

	dim _startupinfo, 17
	dim _procinfo, 4
	_startupinfo(0) = 68

#global