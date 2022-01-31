minetest.register_craftitem("wildkratts:syringe", {
    description = S("Kratts DNA Syringe"),
    inventory_image = "wildkratts_syringe.png",
    wield_image = "wildkratts_syringe.png",
})

minetest.register_craftitem("wildkratts:syringe_dna", {
    description = S("Kratts DNA Syringe"),
    inventory_image = "wildkratts_syringe_dna.png",
    wield_image = "wildkratts_syringe_dna.png",
})

minetest.register_craftitem("wildkratts:disc_dna", {
    description = S("Kratts DNA Disc"),
    inventory_image = "wildkratts_disc_dna.png",
    wield_image = "wildkratts_disc_dna.png",
})

minetest.register_craft({
    type = "shaped",
    output = "wildkratts:syringe",
    recipe = {
        {"", "", "vessels:glass_fragments"},
        {"", "vessels:glass_fragments", ""},
        {"default:diamond", "", ""},
    }
})

local disc_machine_fs = "size[8,7]"
    .."image[3.25,1.75;1.7,.5;wildkratts_progress_bar.png^[transformR270]"
    .."list[current_player;main;0,3;8,4;]"
    .."list[context;input;2,1.5;1,1;]"
    .."list[context;output;5,1.5;1,1;]"
    .."label[3,0.5;Disc Machine]"
    .."label[2.0,1;DNA]"
    .."label[5.1,1;Disc]"


local function update_formspec(progress, goal, meta)
    local formspec
  
    if progress > 0 and progress <= goal then
        local item_percent = math.floor(progress / goal * 100)
        --formspec = get_active_disc_machine_fs(item_percent)
        formspec = disc_machine_fs
    else
        formspec = disc_machine_fs
    end
    meta:set_string("formspec", formspec)
end
    
local function recalculate(pos)
	local meta, timer = minetest.get_meta(pos), minetest.get_node_timer(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack("input", 1)

	local k = "wildkratts:disc_dna"
	if not k then return end

	timer:stop()
    update_formspec(0, 3, meta)
    timer:start(1)
end

minetest.register_node("wildkratts:disc_machine", {
    description = S("Disc Machine"),
    tiles = {
        "wildkratts_disc_machine_back.png"
    },
    paramtype2 = "facedir",
	groups = {cracky = 2, tubedevice = 1, tubedevice_receiver = 1},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	drawtype = "node",
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("input") and inv:is_empty("output")
	end,

	on_timer = function(pos, elapsed)
        local meta = minetest.get_meta(pos)
        local stack = meta:get_inventory():get_stack("input", 1)
        local cooking_time = meta:get_int("cooking_time") or 0
        cooking_time = cooking_time + 1

        if cooking_time % 100 == 0 then
            do_cook_single(pos)
        end

        update_formspec(cooking_time % 100, 100, meta)
        meta:set_int("cooking_time", cooking_time)

        if not stack:is_empty() then
            return true
        else
            meta:set_int("cooking_time", 0)
            update_formspec(0, 3, meta)
            return false
        end
	end,

	on_metadata_inventory_put = recalculate,
    on_metadata_inventory_take = recalculate,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", disc_machine_fs)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
        inv:set_size("output", 1)
	end,

	on_blast = function(pos)
		local drops = {}
		default.get_inventory_drops(pos, "input", drops)
        default.get_inventory_drops(pos, "output", drops)
		table.insert(drops, "wildkratts:disc_machine")
		minetest.remove_node(pos)
		return drops
	end,

	allow_metadata_inventory_put = function(pos, list, index, stack, player)
		return 1
	end,
})

minetest.register_craft({
    output = "wildkratts:disc_machine",
    recipe = {
        {"", "", "vessels:glass_fragments"},
        {"", "vessels:glass_fragments", ""},
        {"default:diamond", "", ""},
    }
})

petz.on_rightclick = function(self, clicker)
    local wielded_item = clicker:get_wielded_item()
    local wielded_item_name = wielded_item:get_name()
    if wielded_item_name == "wildkratts:syringe" then
        local new_item = ItemStack("wildkratts:syringe_dna")
        clicker:set_wielded_item(new_item)
    end
end