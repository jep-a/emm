Class = {}

function Class.New(super)
	local class = {}
	class.__index = class

	if super then
		class.super = super
		setmetatable(class, super)

		if super.hooks then
			class.hooks = {}
			class.instances = {}

			for _, hk in pairs(super.hooks) do
				Class.AddHook(class, hk.name, '_'..hk.id)
			end
		end
	end

	function class.New(...)
		local instance = Class.Instance(class, ...)

		if class.hooks then
			table.insert(class.instances, instance)
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
	class.hooks = {}
	class.instances = {}

	function class:RemoveHooks()
		table.RemoveByValue(class.instances, self)
	end
end

function Class.AddHook(class, name, id)
	if not class.hooks then
		Class.SetupForHooks(class)
	end

	table.insert(class.hooks, {name = name, id = id})

	hook.Add(name, id, function (...)
		for i = 1, #class.instances do
			local instance = class.instances[i]
			class[name](instance, ...)
		end
	end)
end

function Class.RemoveHook(class, name, id)
	for k, hk in pairs(class.hooks) do
		if name == hk.name then
			table.remove(hk, k)

			break
		end
	end

	if #class.hooks < 1 then
		class.hooks = false
		class.instances = {}
	end

	hook.Remove(name, id, class[name])
end
