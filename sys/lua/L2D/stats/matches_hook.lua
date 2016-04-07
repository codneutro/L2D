--- Match Result Hooks
-- @author x[N]ir
-- @release 30/03/16

---
-- Removes all GUI on restart
--
-- @tparam int mode restart mode
--
function hookRestartRound(mode)
	for key, pid in pairs(player(0, "table")) do
		removeGUI(pid);
	end
end
