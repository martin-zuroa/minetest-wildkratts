
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

minetest.register_craft({
    type = "shaped",
    output = "wildkratts:syringe",
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