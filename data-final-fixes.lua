
require("ri-global")
require("lib.string_util")

-- log(serpent.block(data.raw))

function contains_subgroup(signals_data, subgroup_name)
  for _, element in ipairs(signals_data) do
      if  element.type and
          element.type == "item-subgroup" and
          element.name and
          element.name == subgroup_name
      then
          return true
      end
  end
  return false
end

local function make_subgroup(subgroup_name, order)
  return {
    type = "item-subgroup",
    name = subgroup_name,
    group = group_name,
    order = order,
    hidden_in_factoriopedia = true
  }
end

local function make_virtual_signal_from_recipe(recipe, subgroup_name, order)
  return {
    type = "virtual-signal",
    name = "virtual-signal-" .. recipe.name,
    localised_name = recipe.localised_name,
    localised_description = recipe.localised_description,
    subgroup = subgroup_name,
    icons = recipe.icons,
    icon_size = 64,
    order = order,
    hidden_in_factoriopedia = true
  }
end

local function make_virtual_signal_from_category(name, category, subgroup_name)
  return {
    type = "virtual-signal",
    name = "virtual-signal-" .. name .. category.name .. "-recycling",
    localised_name = {
      "",
      { "factoriopedia." .. name },
      ": ",
      { name .. "-name." .. category.name }
    },
    subgroup = subgroup_name,
    icons = {
      {
        icon = "__quality__/graphics/icons/recycling.png"
      },
      {
        icon = category.icon,
        scale = 0.4
      },
      {
        icon = "__quality__/graphics/icons/recycling-top.png"
      }
    },
    icon_size = 64,
    order = category.bonus_gui_order,
    hidden_in_factoriopedia = true
  }
end

local function is_recycling_recipe(name, recipe)
  return  name:match("%-recycling$") or
          (
            recipe.category and
            recipe.category == "recycling"
          )
end

local function is_category_group(name, category)
  return name:contains("category")
end

local function get_recycle_recipe_item(base_name)
  for item_type, _ in pairs(defines.prototypes.item)
  do
		local type = data.raw[item_type]
		if type
    then
		  local item = type[base_name]
      if item then return item end
		end
  end
  return nil
end

local function is_item_hidden(item)
  local item_recipe = data.raw.recipe[item.name]
  return (item_recipe ~= nil and item_recipe.hidden ~= nil and item_recipe.hidden) or
         (item.hidden ~= nil and item.hidden) or
         (item.enabled ~= nil and item.enabled) or
         (item.parameter ~= nil and item.parameter) or
         (item.subgroup ~= nil and (item.subgroup == "spawnables" or item.subgroup:match(".*infinity.*") ))
end

local function prepare_data()
  local recycling_signals_data = {}
  -- ammo category
  for name, _ in pairs(data.raw)
  do
    for _, category in pairs(data.raw[name])
    do
      if is_category_group(name, category) and category.icon ~= nil
      then
        local subgroup_name = category_subgroup_name .. name
        if not contains_subgroup(recycling_signals_data, category_subgroup_name)
        then
          table.insert(recycling_signals_data, make_subgroup(subgroup_name, "zz" .. name))
        end
        table.insert(recycling_signals_data, make_virtual_signal_from_category(name, category, subgroup_name))
      end
    end
  end
  -- recipes
  for name, recycle_recipe in pairs(data.raw.recipe)
  do
    if is_recycling_recipe(name, recycle_recipe)
    then
      local base_name = name:gsub("%-recycling", "")
      local item = get_recycle_recipe_item(base_name)
      -- log(serpent.block(item))
      if  item and
          not is_item_hidden(item) and
          item.subgroup
      then
        local item_subgroup = data.raw['item-subgroup'][item.subgroup]
        local item_group    = data.raw['item-group'][item_subgroup.group]

        local subgroup_name = group_name .. item_subgroup.name
        if not contains_subgroup(recycling_signals_data, subgroup_name)
        then
          table.insert(recycling_signals_data, make_subgroup(subgroup_name, item_group.order .. item_subgroup.order))
        end
        table.insert(recycling_signals_data, make_virtual_signal_from_recipe(recycle_recipe, subgroup_name, item.order))
      end
    end
  end
  -- log(serpent.block(recycling_signals_data))
  return recycling_signals_data
end

data:extend(prepare_data())
