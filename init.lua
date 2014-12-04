-- A couple variables used throughout.
percent = 100
-- GUI related stuff
default.gui_bg = 'bgcolor[#080808BB;true]'
default.gui_bg_img = 'background[5,5;1,1;gui_formbg.png;true]'
default.gui_slots = 'listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]'

more_fire = {}

function default.get_hotbar_bg(x,y)
	local out = ''
	for i=0,7,1 do
		out = out ..'image['..x+i..','..y..';1,1;gui_hb_bg.png]'
	end
	return out
end

function more_fire.campfire(pos, percent, item_percent)
	local formspec =
	'size[8,6.75]'..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	'background[5,5;1,1;campfire_active.png;true]'..
	'list[current_name;fuel;1,1.5;1,1;]'..
	'list[current_player;main;0,2.75;8,1;]'..
	'list[current_player;main;0,4;8,3;8]'..
	default.get_hotbar_bg(0,2.75)
	return formspec
end

function more_fire.get_campfire_formspec(pos, percent)
	local meta = minetest.get_meta(pos)local inv = meta:get_inventory()
	local fuellist = inv:get_list('fuel')
	if fuellist then
		end
	return more_fire.campfire(pos, percent, item_percent)
end

function burn(pointed_thing) --kindling doesn't always start from the first spark
	ignite_chance = math.random(5)
	if ignite_chance == 1
		and string.find(minetest.get_node(pointed_thing.under).name, 'more_fire:kindling_contained')
		then
			minetest.swap_node(pointed_thing.under, {name = 'more_fire:embers_contained'})
	elseif ignite_chance == 1
		and string.find(minetest.get_node(pointed_thing.under).name, 'more_fire:kindling')
		then
			minetest.swap_node(pointed_thing.under, {name = 'more_fire:embers'})
	else --Do nothing
	end
end


-- formspecs
more_fire.embers_formspec =
'size[8,6.75]'..
default.gui_bg..
default.gui_bg_img..
default.gui_slots..
'listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]'..
'background[5,5;1,1;campfire_inactive.png;true]'..
'list[current_name;fuel;1,1.5;1,1;]'..
'list[current_player;main;0,2.75;8,1;]'..
'list[current_player;main;0,4;8,3;8]'..
default.get_hotbar_bg(0,2.75)

-- ABMs
minetest.register_abm({  -- Controls non-contained fire
	nodenames = {'more_fire:embers','more_fire:campfire'},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.env:get_meta(pos)
		for i, name in ipairs({
		'fuel_totaltime',
		'fuel_time',
		}) do
		if meta:get_string(name) == '' then
			meta:set_float(name, 5.0)
			end
		end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local was_active = false
		if meta:get_float('fuel_time') < meta:get_float('fuel_totaltime') then
			was_active = true
			meta:set_float('fuel_time', meta:get_float('fuel_time') + 0.25)
			end
		if meta:get_float('fuel_time') < meta:get_float('fuel_totaltime') then
			minetest.sound_play({name='fire_small'},{gain=0.07},
			{loop=true})
			local percent = math.floor(meta:get_float('fuel_time') /
			meta:get_float('fuel_totaltime') * 100)
			meta:set_string('infotext','Campfire active: '..percent..'%')
			minetest.swap_node(pos, {name = 'more_fire:campfire'})
			meta:set_string('formspec',
			'size[8,6.75]'..
			default.gui_bg..
			default.gui_slots..
			'background[5,5;1,1;campfire_active.png;true]'..
			'list[current_name;fuel;1,1.5;1,1;]'..
			'list[current_player;main;0,2.75;8,1;]'..
			'list[current_player;main;0,4;8,3;8]')
			return
			end
			local fuel = nil
			local fuellist = inv:get_list('fuel')
			if fuellist then
				fuel = minetest.get_craft_result({method = 'fuel', width = 1, items = fuellist})
			end
			if fuel.time <= 0 then
				meta:set_string('infotext','Put more wood on the fire!')
				minetest.swap_node(pos, {name = 'more_fire:embers'})
				meta:set_string('formspec', more_fire.embers_formspec)
			return
		end
		meta:set_string('fuel_totaltime', fuel.time)
		meta:set_string('fuel_time', 0)
		local stack = inv:get_stack('fuel', 1)
		stack:take_item()
		inv:set_stack('fuel', 1, stack)
end,
})

minetest.register_abm({  -- Controls the contained fires.
	nodenames = {'more_fire:embers_contained', 'more_fire:campfire_contained'},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.env:get_meta(pos)
		for i, name in ipairs({
		'fuel_totaltime',
		'fuel_time',
		}) do
		if meta:get_string(name) == '' then
			meta:set_float(name, 0.0)
			end
		end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local was_active = false
		if meta:get_float('fuel_time') < meta:get_float('fuel_totaltime') then
			was_active = true
			meta:set_float('fuel_time', meta:get_float('fuel_time') + 0.25)
			end
		if meta:get_float('fuel_time') < meta:get_float('fuel_totaltime') then
			minetest.sound_play({name='fire_small'},{gain=0.07},
			{loop=true})
			local percent = math.floor(meta:get_float('fuel_time') /
			meta:get_float('fuel_totaltime') * 100)
			meta:set_string('infotext','Campfire active: '..percent..'%')
			minetest.swap_node(pos, {name = 'more_fire:campfire_contained'})
			meta:set_string('formspec',
			'size[8,6.75]'..
			default.gui_bg..
			default.gui_slots..
			'background[5,5;1,1;campfire_active.png;true]'..
			'list[current_name;fuel;1,1.5;1,1;]'..
			'list[current_player;main;0,2.75;8,1;]'..
			'list[current_player;main;0,4;8,3;8]')
			return
			end
			local fuel = nil
			local fuellist = inv:get_list('fuel')
			if fuellist then
				fuel = minetest.get_craft_result({method = 'fuel', width = 1, items = fuellist})
			end
			if fuel.time <= 0 then
				meta:set_string('infotext','Put more wood on the fire!')
				minetest.swap_node(pos, {name = 'more_fire:embers_contained'})
				meta:set_string('formspec', more_fire.embers_formspec)
			return
		end
		meta:set_string('fuel_totaltime', fuel.time)
		meta:set_string('fuel_time', 0)
		local stack = inv:get_stack('fuel', 1)
		stack:take_item()
		inv:set_stack('fuel', 1, stack)
end,
})

-- node definitions
minetest.register_node(':default:gravel', {
	description = 'Gravel',
	tiles = {'default_gravel.png'},
	is_ground_content = true,
	groups = {crumbly=2, falling_node=1},
	drop = {
		max_items = 1,
		items = {
			{
				items = {'more_fire:flintstone'},
				rarity = 15,
			},
			{
				items = {'default:gravel'},
			}
		}
	},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name='default_gravel_footstep', gain=0.45},
	}),
})

minetest.register_node(":default:torch", {
	description = "Torch",
	drawtype = "nodebox",
	tiles = {
		{name = "default_torch_new_top.png",    animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.0}},
		{name = "default_torch_new_bottom.png", animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.0}},
		{name = "default_torch_new_side.png",   animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.0}},
	},
	inventory_image = "default_torch_new_inv.png",
	wield_image = "default_torch_new_inv.png",
	wield_scale = {x = 1, y = 1, z = 1.25},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	light_source = LIGHT_MAX - 1,
	node_box = {
		type = "wallmounted",
		wall_top    = {-0.0625, -0.0625, -0.0625, 0.0625, 0.5   , 0.0625},
		wall_bottom = {-0.0625, -0.5   , -0.0625, 0.0625, 0.0625, 0.0625},
		wall_side   = {-0.5   , -0.5   , -0.0625, -0.375, 0.0625, 0.0625},
	},
	selection_box = {
		type = "wallmounted",
		wall_top    = {-0.05, -0.05, -0.25, 0.25, 0.5   , 0.25},
		wall_bottom = {-0.25, -0.5   , -0.25, 0.25, 0.0625, 0.25},
		wall_side   = {-0.25, -0.5  , -0.25, -0.5, 0.0625, 0.25},
	},
	groups = {choppy = 2, dig_immediate = 3, flammable = 1, attached_node = 1, hot = 2},
	sounds = default.node_sound_wood_defaults(),
})
	
minetest.register_node('more_fire:charcoal_block', {
	description = 'Charcoal Block',
	tiles = {'more_fire_charcoal_block.png'},
	is_ground_content = true,
	groups = {oddly_breakable_by_hand=2,cracky=3,flammable=1,},
})

minetest.register_node('more_fire:kindling', {
	description = 'Kindling',
	drawtype = 'mesh',
	mesh = 'more_fire_kindling.obj',
	tiles = {'more_fire_campfire_logs.png'},
	inventory_image = 'more_fire_kindling.png',
	wield_image = 'more_fire_kindling.png',
	walkable = false,
	is_ground_content = true,
	groups = {dig_immediate=2, flammable=1,},
	paramtype = 'light',
	selection_box = {
		type = 'fixed',
		fixed = { -0.48, -0.5, -0.48, 0.48, -0.5, 0.48 },
		},
	on_construct = function(pos)
	 		local meta = minetest.env:get_meta(pos)
	 		meta:set_string('formspec', more_fire.embers_formspec)
	 		local inv = meta:get_inventory()
			inv:set_size('fuel', 4)
		end,
})

minetest.register_node('more_fire:embers', {
	description = 'Campfire',
	drawtype = 'mesh',
	mesh = 'more_fire_kindling.obj',
	tiles = {'more_fire_campfire_logs.png'},
	inventory_image = 'more_fire_campfire.png',
	wield_image = 'more_fire_campfire.png',
	walkable = false,
	is_ground_content = true,
	groups = {dig_immediate=3, flammable=1,},
	paramtype = 'light',
	drop = 'more_fire:kindling',
	selection_box = {
		type = 'fixed',
		fixed = { -0.48, -0.5, -0.48, 0.48, -0.5, 0.48 },
		},
	on_construct = function(pos)
			local meta = minetest.env:get_meta(pos)
			meta:set_string('formspec', more_fire.embers_formspec)
			meta:set_string('infotext', 'Campfire');
			local inv = meta:get_inventory()
			inv:set_size('fuel', 4)
		end,
	can_dig = function(pos, player)
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			if not inv:is_empty('fuel') then
				return false
			end
			return true
end,
})

minetest.register_node('more_fire:campfire', {
	description = 'Burning Campfire',
	drawtype = 'mesh',
	mesh = 'more_fire_campfire.obj',
	tiles = {
		{name='fire_basic_flame_animated.png', animation={type='vertical_frames', aspect_w=16, aspect_h=16, length=1}}, {name='more_fire_campfire_logs.png'}},
	inventory_image = 'more_fire_campfire.png',
	wield_image = 'more_fire_campfire.png',
	paramtype = 'light',
	walkable = false,
	damage_per_second = 1,
	light_source = 14,
	is_ground_content = true,
	groups = {cracky=2,hot=2,attached_node=1,igniter=1,not_in_creative_inventory=1},
	selection_box = {
		type = 'fixed',
		fixed = { -0.48, -0.5, -0.48, 0.48, -0.5, 0.48 },
		},
	can_dig = function(pos,player)
			local meta = minetest.env:get_meta(pos);
			local inv = meta:get_inventory()
			if not inv:is_empty('fuel') then
				return false
				end
			return true
			end,
			get_staticdata = function(self)
end,
})

minetest.register_node('more_fire:kindling_contained', {
	description = 'Contained Kindling',
	drawtype = 'mesh',
	mesh = 'more_fire_kindling_contained.obj',
	tiles = {'more_fire_campfire_logs.png'},
	inventory_image = 'more_fire_kindling_contained.png',
	wield_image = 'more_fire_kindling.png',
	walkable = false,
	is_ground_content = true,
	groups = {dig_immediate=3,flammable=1},
	paramtype = 'light',
	selection_box = {
		type = 'fixed',
		fixed = { -0.48, -0.5, -0.48, 0.48, -0.5, 0.48 },
		},
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string('formspec', more_fire.embers_formspec)
		local inv = meta:get_inventory()
		inv:set_size('fuel', 4)
	end,
})

minetest.register_node('more_fire:embers_contained', {
	description = 'Contained Campfire',
	drawtype = 'mesh',
	mesh = 'more_fire_kindling_contained.obj',
	tiles = {'more_fire_campfire_logs.png'},
	walkable = false,
	is_ground_content = true,
	groups = {dig_immediate=3, flammable=1, not_in_creative_inventory=1},
	paramtype = 'light',
	drop = 'more_fire:kindling_contained',
	inventory_image = 'more_fire_campfire_contained.png',
	wield_image = 'more_fire_campfire_contained.png',
	selection_box = {
		type = 'fixed',
		fixed = { -0.48, -0.5, -0.48, 0.48, -0.5, 0.48 },
		},
	on_construct = function(pos)
			local meta = minetest.env:get_meta(pos)
			meta:set_string('formspec', more_fire.embers_formspec)
			meta:set_string('infotext', 'Campfire');
			local inv = meta:get_inventory()
			inv:set_size('fuel', 4)
		end,
	can_dig = function(pos, player)
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			if not inv:is_empty('fuel') then
				return false
			end
			return true
end,
})

minetest.register_node('more_fire:campfire_contained', {
	description = 'Contained Campfire',
	drawtype = 'mesh',
	mesh = 'more_fire_contained_campfire.obj',
	tiles = {
		{name='fire_basic_flame_animated.png', animation={type='vertical_frames', aspect_w=16, aspect_h=16, length=1}}, {name='more_fire_campfire_logs.png'}},
	inventory_image = 'more_fire_campfire_contained.png',
	wield_image = 'more_fire_campfire_contained.png',
	paramtype = 'light',
	walkable = false,
	damage_per_second = 1,
	drop = 'more_fire:charcoal',
	light_source = 14,
	is_ground_content = true,
	groups = {cracky=2,hot=2,attached_node=1,dig_immediate=3,not_in_creative_inventory=1},
		selection_box = {
		type = 'fixed',
		fixed = { -0.48, -0.5, -0.48, 0.48, -0.5, 0.48 },
		},
	can_dig = function(pos,player)
			local meta = minetest.env:get_meta(pos);
			local inv = meta:get_inventory()
			if not inv:is_empty('fuel') then
				return false
				end
			return true
			end,
			get_staticdata = function(self)
end,
})

-- craft items
minetest.register_craftitem('more_fire:charcoal', {
	description = 'Charcoal',
	inventory_image = 'more_fire_charcoal_lump.png',
	groups = {coal = 1}
})

minetest.register_craftitem('more_fire:flintstone', {
	description = 'Flintstone',
	inventory_image = 'more_fire_flintstone.png',
})

minetest.register_craftitem('more_fire:lighter', {
	description = 'Flint and Steel',
	inventory_image = 'more_fire_lighter.png',
})

-- craft recipes
minetest.register_craft({
	output = 'more_fire:charcoal_block 1',
	recipe = {
		{'more_fire:charcoal', 'more_fire:charcoal', 'more_fire:charcoal'},
		{'more_fire:charcoal', 'more_fire:charcoal', 'more_fire:charcoal'},
		{'more_fire:charcoal', 'more_fire:charcoal', 'more_fire:charcoal'},
	}
})

minetest.register_craft({
	output = 'more_fire:charcoal 9',
	recipe = {
		{'more_fire:charcoal_block'}
	}
})

minetest.register_craft({
	output = 'more_fire:embers 1',
	recipe = {
		{'more_fire:kindling'},
		{'default:torch'},
	}
})

minetest.register_craft({
	output = 'more_fire:embers 1',
	recipe = {
		{'', '', ''},
		{'default:stick', 'default:torch', 'default:stick'},
		{'group:wood', 'group:wood', 'group:wood'},
	}
})

minetest.register_craft({
	output = 'more_fire:embers_contained 1',
	recipe = {
		{'', 'more_fire:embers', ''},
		{'default:cobble', 'default:cobble', 'default:cobble'},
	}
})

minetest.register_craft({
	output = 'default:torch 4',
	recipe = {
		{'more_fire:charcoal'},
		{'group:stick'},
	}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'more_fire:kindling 1',
	recipe = {'group:stick', 'group:wood', 'group:flammable', 'group:flammable'},
})

minetest.register_craft({
	output = 'more_fire:kindling_contained 1',
	recipe = {
		{'','more_fire:kindling', ''},
		{'default:cobble','default:cobble','default:cobble'},
		}
})

minetest.register_craft({
	type = 'shapeless',
	output = 'more_fire:lighter 1',
	recipe = {'more_fire:flintstone', 'default:steel_ingot'}
})

-- cooking recipes
minetest.register_craft({
	type = 'cooking',
	recipe = 'group:tree',
	output = 'more_fire:charcoal',
})

-- fuel recipes
minetest.register_craft({
	type = 'fuel',
	recipe = 'more_fire:charcoal',
	burntime = 35,
})

minetest.register_craft({
	type = 'fuel',
	recipe = 'more_fire:charcoal_block',
	burntime = 315,
})

-- tools
minetest.register_tool('more_fire:lighter', {
	description = 'Lighter',
	inventory_image = 'more_fire_lighter.png',
	stack_max = 1,
	tool_capabilities = {
		full_punch_interval = 1.0,
		max_drop_level = 0,
		groupcaps = {
			flammable = {uses = 200, maxlevel = 1},
		}
	},
	on_use = function(itemstack, user, pointed_thing, pos)
		minetest.sound_play("spark", {gain = 1.0, max_hear_distance = 32, loop = false })
		if pointed_thing.type == 'node'
			and string.find(minetest.get_node(pointed_thing.under).name, 'more_fire:kindling')
			then
				burn(pointed_thing)
				itemstack:add_wear(65535/200)
				return itemstack
			end
	end,
})
