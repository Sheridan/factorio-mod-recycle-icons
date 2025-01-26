
require("ri-global")

-- log(serpent.block(data.raw))

local function first(t)
  local i = 0
  while t[i] == nil do i = i + 1 end
  return t[i]
end

local function recipe_category(recipe)
  -- if recipe.category then return recipe.category end
  -- if recipe.subgroup then return recipe.subgroup end
  return "no-category"
end

local function data_valid(recycle_recipe)
  if not (recycle_recipe.icons ~= nil and recycle_recipe.ingredients ~= nil and #recycle_recipe.ingredients > 0)
  then log("recycle recipe" .. recycle_recipe.name .. " without icons or ingredients"); return false end
  -- log(first(recycle_recipe.ingredients).name .. " -> " .. data.raw.recipe[first(recycle_recipe.ingredients).name])

  local recipe = data.raw.recipe[first(recycle_recipe.ingredients).name]
  return recipe ~= nil and not recipe.hidden and recipe_category(recipe)
end

local function ingredient_subgroup_name(recycle_recipe)
  local recipe = data.raw.recipe[first(recycle_recipe.ingredients).name]
  return group_name .. "-" .. recipe_category(recipe)
end

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

local function make_subgroup(subgroup_name)
  return {
    type = "item-subgroup",
    name = subgroup_name,
    group = group_name,
    order = subgroup_name,
    hidden_in_factoriopedia = true
  }
end

local function make_icon(recipe, subgroup_name)
  return {
    type = "virtual-signal",
    name = "virtual-signal-" .. recipe.name,
    localised_name = recipe.localised_name,
    subgroup = subgroup_name,
    icons = recipe.icons,
    icon_size = 64,
    order = recipe.name,
    hidden_in_factoriopedia = true
  }
end

local function prepare_data()
  local recycling_signals_data = {}
  for _, recipe in pairs(data.raw.recipe) do
    if recipe.category and recipe.category == "recycling"
    then
      if data_valid(recipe)
      then
        local subgroup_name = ingredient_subgroup_name(recipe)
        if not contains_subgroup(recycling_signals_data, subgroup_name)
        then
          table.insert(recycling_signals_data, make_subgroup(subgroup_name))
        end
        table.insert(recycling_signals_data, make_icon(recipe, subgroup_name))
      else
        -- log("Recipe " .. recipe.name .. " is`nt valid")
        -- log(serpent.block(recipe))
        -- log(serpent.block(data.raw.recipe[recipe.ingredients[1].name]))
      end
    end
  end
  -- log(serpent.block(recycling_signals_data))
  return recycling_signals_data
end

data:extend(prepare_data())
