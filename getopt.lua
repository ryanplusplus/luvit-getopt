--[[lit-meta
  name = 'ryanplusplus/getopt'
  version = '1.0.0'
  description = 'http://lua-users.org/wiki/PosixGetOpt packaged for Luvit'
  tags = { 'getopt', 'options', 'command line', 'cli' }
  license = 'MIT?'
  author = { name = 'http://lua-users.org/wiki/PosixGetOpt' }
  homepage = 'https://github.com/ryanplusplus/luvit-getopt.lua'
]]
return function (optstring, ...)
	local opts = { }
	local args = { ... }

	for optc, optv in optstring:gmatch"(%a)(:?)" do
		opts[optc] = { hasarg = optv == ":" }
	end

	return coroutine.wrap(function()
		local yield = coroutine.yield
		local i = 1

		while i <= #args do
			local arg = args[i]

			i = i + 1

			if arg == "--" then
				break
			elseif arg:sub(1, 1) == "-" then
				for j = 2, #arg do
					local opt = arg:sub(j, j)

					if opts[opt] then
						if opts[opt].hasarg then
							if j == #arg then
								if args[i] then
									yield(opt, args[i])
									i = i + 1
								elseif optstring:sub(1, 1) == ":" then
									yield(':', opt)
								else
									yield('?', opt)
								end
							else
								yield(opt, arg:sub(j + 1))
							end

							break
						else
							yield(opt, false)
						end
					else
						yield('?', opt)
					end
				end
			else
				yield(false, arg)
			end
		end

		for i = i, #args do
			yield(false, args[i])
		end
	end)
end
