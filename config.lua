Config = Config or {}
Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use qb-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)

Config.Items = {
    ['car_unlocker'] = {
        name = 'car_unlocker',
        label = 'Hacking car device',
        weight = 50,
        type = 'item',
        image = 'tablet.png',
        unique = true,
        useable = true,
        shouldClose = true,
        combinable = nil,
        description = 'An high-tech hacking device to easily open and start cars'
    }
}

Config.Hacking = {
    duration = 10000,
    animation = {
        anim_dict = "gestures@m@sitting@generic@casual",
        anim_name = "gesture_hand_left",
        attached_bone = 36029,
        prop_model = 'w_am_hackdevice_m32',
        prop_coord = vector3(0.05, 0.05, 0),
        prop_rotaton = vector3(-110, 20, 0)
    }
}

Config.Disguise = {
    duration = 30000,
    price = 10000
}

Config.Zones = {
    ["jbb-veh-disguise"] = {
        coords = {
            vector2(-280.96661376953, 2540.818359375),
            vector2(-287.13748168945, 2540.3610839844),
            vector2(-286.85116577148, 2528.7258300781),
            vector2(-280.86108398438, 2528.9560546875)
        },
        options = {
            name="jbb-veh-disguise",
            minZ = 69.9,
            maxZ = 78.2,
            debugGrid=false,
            debugPoly=false,
        }
    }
}

