local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
---@type Bitmap
local bmp

local LayoutFor = UMT.Layouter.ReusedLayoutFor



function CreateUI(args, name)
    if not bmp then
        local parent = GetFrame(0)
        bmp = Bitmap(parent, "/maps/Test/UI/GW.dds")
        LayoutFor(bmp)
            :Over(parent, 1000)
            :Fill(parent)
            :DisableHitTest()

        local animation = UMT.Animation.Factory.Alpha
            :StartWith(0)
            :ToAppear()
            :For(0.5)
            :EndWith(1)
            :Create()
        animation:Apply(bmp)
    else
        LOG("WTF!")
    end
end

function DestroyUI()
    if not bmp then
        LOG("WTF!")
    else
        local animation = UMT.Animation.Factory.Alpha
            :ToFade()
            :For(3)
            :EndWith(0)
            :OnFinish(function(control)
                control:Destroy()
            end)
            :Create()
        animation:Apply(bmp)

        bmp = nil
    end
end
