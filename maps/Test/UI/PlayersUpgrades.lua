local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local UIUtil = import('/lua/ui/uiutil.lua')
local Group = import('/lua/maui/group.lua').Group
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Button = import('/lua/maui/button.lua').Button


local LayoutFor = UMT.Layouter.ReusedLayoutFor

---@type Control
local controls



function CreateUI(args, name)
    local parent = GetFrame(0)
    controls = Group(parent)
    local easyBtn = UIUtil.CreateButtonWithDropshadow(controls, '/BUTTON/medium/', "easy")

    local hardBtn = UIUtil.CreateButtonWithDropshadow(controls, '/BUTTON/medium/', "hard")


    local waitText = UIUtil.CreateText(controls, 'Wait for other players', 20, UIUtil.titleFont, true)

    easyBtn.OnClick = function()
        LOG("EASY")
        UI4Sim.Callback(name,
            {
                option = 1
            })
        hardBtn:Hide()
        easyBtn:Hide()
        waitText:Show()
    end

    hardBtn.OnClick = function()
        LOG("HARD")
        UI4Sim.Callback(name,
            {
                option = 2
            })
        hardBtn:Hide()
        easyBtn:Hide()
        waitText:Show()
    end

    LayoutFor(controls)
        :Width(300)
        :Height(100)
        :AtCenterIn(parent)
        :Over(parent, 1000)
        :DisableHitTest()
    LayoutFor(easyBtn)
        :AtLeftCenterIn(controls, 5)
    LayoutFor(hardBtn)
        :AtRightCenterIn(controls, 5)

    LayoutFor(waitText)
        :AtCenterIn(controls)
        :Hide()

end

function DestroyUI(args, name)
    controls:Destroy()
    controls = nil
end
