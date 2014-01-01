--
-- another silly test system
--

require 'serialize'

local tbl = {}   -- tbl[ent] contains data for ent -- right now just speed

function rotator_set(ent, speed)
    if not speed then speed = 2 * math.pi end
    tbl[ent] = speed
end

cgame.add_system('rotator',
{
    update_all = function (dt)
        for ent, speed in pairs(tbl) do
            cgame.transform_rotate(ent, speed * dt)
        end
    end,

    save_all = function ()
        return serialize(tbl)
    end,

    load_all = function (str)
        tbl = loadstring(str)()
    end,
})

