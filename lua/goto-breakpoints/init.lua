local M = {}
local api = vim.api

local tablelength = function(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

local tail = function(T)
	local last = -1
	for index, _ in pairs(T) do last = index end
	return last
end


local dap_breakpoints = require('dap.breakpoints')
local go_to_breakpoint = function(go_to_next)
	local breakpoints = dap_breakpoints.get()
	local amount_of_breakpoints = tablelength(breakpoints)
	if amount_of_breakpoints == 0 then -- No breakpoints, just return
		return
	end
	local current_bufnr = api.nvim_get_current_buf()
	local choosed_buffer = -1
	local prev_buffer = -1

	-- Go over all the breakpoints find the current buffer, the previous one and the next one
	for bufnr, _ in pairs(breakpoints) do
		if bufnr == current_bufnr then
			choosed_buffer = bufnr
		else
			prev_buffer = bufnr
		end
	end

	if choosed_buffer == -1 then
		choosed_buffer = prev_buffer
	end

	if choosed_buffer == -1 then
		return
	end

	local current_line = api.nvim_win_get_cursor(0)[1]
	local line = -1
	for _, breakpoint in ipairs(breakpoints[choosed_buffer]) do
		if (go_to_next and breakpoint.line > current_line) or (not go_to_next and breakpoint.line < current_line) then
			line = breakpoint.line
			break
		end
	end

	-- No line was found, go to next/prev buffer
	if line == -1 then
		local new_buffer = -1
		if go_to_next then
			local next_buffer = next(breakpoints, choosed_buffer)
			if next_buffer == nil then -- No next buffer, go to first
				next_buffer = next(breakpoints, nil) -- get first
			end

			if next_buffer ~= nil then
				new_buffer = next_buffer
			else
				new_buffer = -1
			end
		else
			if prev_buffer ~= -1 then
				new_buffer = prev_buffer
			else
				new_buffer = tail(breakpoints)
			end
		end

		if new_buffer ~= -1 then
			choosed_buffer = new_buffer
		end

		if go_to_next then
			line = breakpoints[choosed_buffer][1].line
		else
			local buffer_breakpoints = breakpoints[choosed_buffer]
			line = buffer_breakpoints[#buffer_breakpoints].line
		end
	end

	if current_bufnr ~= choosed_buffer then
		api.nvim_set_current_buf(choosed_buffer)
	end
	api.nvim_win_set_cursor(0, {line, 0})
end

M.next = function()
	go_to_breakpoint(true)
end

M.prev = function()
	go_to_breakpoint(false)
end

return M
