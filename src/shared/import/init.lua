local RunService = game:GetService("RunService")
local Directory = {
	Server = {
		Modules = {},
		Services = {},
	},
	Client = {
		Controllers = {},
		Modules = {},
	},
	Shared = {},
	Packages = {},
}

-- made by @lunarprogramas (janslan)

local function setAliases(modules, type)
	local isSharedModule = type == "Packages" or type == "Shared"

	if RunService:IsServer() and not isSharedModule then
		Directory.Server[type] = modules
	elseif RunService:IsClient() and not isSharedModule then
		Directory.Client[type] = modules
	elseif type == "Packages" and isSharedModule then
		Directory.Packages = modules
	elseif type == "Shared" and isSharedModule then
		Directory.Shared = modules
	end
end

local function solveDirectory(path: string)
	local split = string.split(path, "/")
	local indexDirectories = {} -- Example: Shared/Modules/Table

	for _, v in split do
		table.insert(indexDirectories, v)
	end

	local foundDirectory = false
	local indexedFirstDirectory = false

	for _, directory in indexDirectories do
		if not indexedFirstDirectory then
			foundDirectory = Directory[directory]
			indexedFirstDirectory = true
			continue
		else
			if type(foundDirectory) == "table" then
                if foundDirectory[directory] then
                    foundDirectory = foundDirectory[directory]
                    continue
                end

				for i, file: Script in foundDirectory do
					if type(file) == "table" then
						for subI, subFile in file do
							if directory == subFile.Name then
								foundDirectory = foundDirectory[subI]
								continue
							end
						end
					else
						if directory == file.Name then
							foundDirectory = foundDirectory[i]
							continue
						end
					end
				end
			else -- assuming its a normal instance value which is higly unlikely
				foundDirectory = foundDirectory[directory]
				continue
			end
		end
	end

	return foundDirectory
end

return function(directory, modules: Object?)
	if string.find(directory, "set:") then
		local split = string.split(directory, ":")
		return setAliases(modules, split[2])
	end

	local split = string.split(directory, "/")
	local context = split[1] == "Shared" and "Shared"
		or split[1] == "Packages" and "Packages"
		or RunService:IsClient() and "Client"
		or RunService:IsServer() and "Server"

	if Directory[context] then
		local outputFile
		if context == "Packages" or context == "Shared" then
			outputFile = solveDirectory(directory)
		else
			outputFile = solveDirectory(`{context}/{directory}`)
		end
		local success, result = pcall(require, outputFile)
		if success then
			return result
		else
			print(`[import] Failed to require {directory} : {result}`)
		end
	end
end
