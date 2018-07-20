Class = {}

function Class.TableID(tab)
	return tostring(tab):gsub("table: ", "", 1)
end

function Class.New(super)
	local class = {}
	class.__index = class
	class.static = {}

	if super then
		class.super = super
		setmetatable(class, super)

		if super.static.hooks then
			class.static.hooks = {}
			class.static.instances = {}

			for _, hk in pairs(super.static.hooks) do
				Class.AddHook(class, hk.name, hk.func_key)
			end
		end
	end

	function class.New(...)
		local instance = Class.Instance(class, ...)

		if class.static.hooks then
			table.insert(class.static.instances, instance)
		end

		return instance
	end

	return class
end

function Class.Instance(class, ...)
	local instance = setmetatable({}, class)

	if class.Init then
		instance:Init(...)
	end

	return instance
end

function Class.SetupForHooks(class)
	class.static.hooks = {}
	class.static.instances = {}

	function class:DisconnectFromHooks()
		table.RemoveByValue(class.static.instances, self)
	end

	function class:Finish()
		self:DisconnectFromHooks()
	end
end

function Class.AddHook(class, name, func_k)
	func_k = func_k or name

	if not class.static.hooks then
		Class.SetupForHooks(class)
	end

	table.insert(class.static.hooks, {name = name, func_key = func_k})

	hook.Add(name, Class.TableID(class).."."..func_k, function (...)
		for i = 1, #class.static.instances do
			local instance = class.static.instances[i]
			class[func_k](instance, ...)
		end
	end)
end

function Class.RemoveHook(class, name)
	local func_k

	for k, hk in pairs(class.static.hooks) do
		if name == hk.name then
			func_k = hk.func_key
			table.remove(hk, k)

			break
		end
	end

	if #class.static.hooks < 1 then
		class.static.hooks = false
		class.static.instances = {}
	end

	hook.Remove(name, Class.TableID(class).."."..func_k)
end