local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
---@type Bitmap
local bmp

local LayoutFor = UMT.Layouter.ReusedLayoutFor
LOG("imported UI for sim")
function CreateUI(args, name)
    if not bmp then
        LOG("Creating bitmap")
        reprsl(args)
        reprsl(name)
        local parent = GetFrame(0)
        bmp = Bitmap(parent, "/maps/Test/UI/GW.dds")
        LayoutFor(bmp)
            :Over(parent, 1000)
            :Fill(parent)
            :DisableHitTest()
    else
        LOG("WTF!")
    end
end

function DestroyUI()
    if not bmp then
        LOG("WTF!")
    else
        bmp:Destroy()
        bmp = nil
    end
end
