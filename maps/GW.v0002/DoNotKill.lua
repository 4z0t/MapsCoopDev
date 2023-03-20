local KillObjective = Oxygen.Objective.Kill

---@class DoNotKillObjective : KillObjective
DoNotKillObjective = Class(KillObjective)
{
    ---@param self DoNotKillObjective
    ---@param unit Unit
    OnUnitKilled = function(self, unit)
        if not self.Active then return end

        self:Fail(unit)
    end,
}