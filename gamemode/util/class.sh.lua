Class = {}

function Class.InstanceOf(instance, class)
	local instance_of

	local current_class = getmetatable(instance)

	if current_class then
		if class == current_class then
			instance_of = true
		else
			while current_class.super do
				local super = current_class.super

				if class == super then
					instance_of = true

					break
				else
					current_class = super
					instance_of = false
				end
			end
		end
	end

	return instance_of
end

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
		table.RemoveByValue(getmetatable(self).static.instances, self)
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

	local existing_hk_k

	for k, hk in pairs(class.static.hooks) do
		if hk.name == name then
			existing_hk_k = k

			break
		end
	end

	if existing_hk_k then
		class.static.hooks[existing_hk_k].func_key = func_k
	else
		table.insert(class.static.hooks, {name = name, func_key = func_k})
	end

	local instances = class.static.instances
	local queued_for_finish = {}

	hook.Add(name, Class.TableID(class).."."..func_k, function (...)
		local arguments = {...}
		local len = #instances

		for i = 1, len do
			local instance = instances[i]

			if instance then
				local success, error = pcall(function ()
					class[func_k](instance, unpack(arguments))
				end)
		
				if not success then
					if instance.debug_trace then
						Error(error.."\n"..instance.debug_trace.."\n")
					else
						Error(error.."\n")
					end

					table.insert(queued_for_finish, instance)
				end
			end
		end

		local finish_len = #queued_for_finish

		for i = 1, finish_len do
			queued_for_finish[i]:DisconnectFromHooks()
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