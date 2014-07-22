local ffi = require 'ffi'
local refct = require 'reflect'

--- utilities ------------------------------------------------------------------

-- dereference a cdata from a pointer
function cg.__deref_cdata(ct, p)
    return ffi.cast(ct, p)[0]
end

-- enum --> values and enum --> string functions
local enum_values_map = {}
function cg.enum_values(typename)
    if enum_values_map[typename] then return enum_values_map[typename] end
    enum_values_map[typename] = {}
    for v in refct.typeof(typename):values() do
        enum_values_map[typename][v.name] = true
    end
    return enum_values_map[typename]
end
function cg.enum_tostring(typename, val)
    -- no nice inverse mapping exists...
    for name in pairs(cg.enum_values(typename)) do
        if ffi.new(typename, name) == val then return name end
    end
    return nil
end

-- return serialized string for cdata, func must be of form
-- void (typeof(cdata) *, Serializer *)
function cg.c_serialize(func, cdata)
    local s = cg.store_open()
    func(cdata, nil, s)
    local dump = ffi.string(cg.store_write_str(s))
    cg.store_close(s)
    return dump
end

-- return struct deserialized from string 'str', func must be of form
-- void (ctype *, Deserializer *)
function cg.c_deserialize(ctype, func, str)
    local cdata = ctype { }
    local s = cg.store_open_str(str)
    func(cdata, nil, cdata, s)
    cg.store_close(s)
    return cdata
end

-- create a save/load function given C type and C save/load functions all
-- as string names
function cg.c_save_load(ctype, c_save, c_load)
    return function (cdata)
        local cdump = cg.c_serialize(loadstring('return ' .. c_save)(),
                                        cdata)
        return 'cg.c_deserialize(' .. ctype .. ', ' .. c_load .. ', '
            .. cg.safestr(cdump) .. ')'
    end
end


--- Entity ---------------------------------------------------------------------

cg.Entity = ffi.metatype('Entity',
{
    __eq = function (a, b)
        return type(a) == 'cdata' and type(b) == 'cdata'
            and ffi.istype('Entity', a) and ffi.istype('Entity', b)
            and cg.entity_eq(a, b)
    end,
    __index =
    {
        __serialize = cg.c_save_load('cg.Entity', 'cg.entity_save',
            'cg.entity_load')
    },
})


--- Vec2 -----------------------------------------------------------------------

cg.Vec2 = ffi.metatype('Vec2',
{
    __add = cg.vec2_add,
    __sub = cg.vec2_sub,
    __mul = function (a, b)
        if type(a) == 'number' then return cg.vec2_scalar_mul(b, a)
        elseif type(b) == 'number' then return cg.vec2_scalar_mul(a, b)
        else return cg.vec2_mul(a, b) end
    end,
    __div = function (a, b)
        if type(b) == 'number' then return cg.vec2_scalar_div(a, b)
        elseif type(a) == 'number' then return cg.scalar_vec2_div(a, b)
        else return cg.vec2_div(a, b) end
    end,
    __index =
    {
        __serialize = cg.c_save_load('cg.Vec2', 'cg.vec2_save',
            'cg.vec2_load')
    },
})


--- Mat3 -----------------------------------------------------------------------

cg.Mat3 = ffi.metatype('Mat3',
{
    __index =
    {
        __serialize = cg.c_save_load('cg.Mat3', 'cg.mat3_save',
            'cg.mat3_load')
    },
})

--- BBox -----------------------------------------------------------------------

cg.BBox = ffi.metatype('BBox', {})
