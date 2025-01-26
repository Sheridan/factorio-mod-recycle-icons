require("ri-global")

  data:extend({
    {
      type = "item-group",
      name = group_name,
      order = "z-" .. group_name,
      icon = "__quality__/graphics/icons/recycling.png",
      icon_size = 64,
      hidden_in_factoriopedia = true
    },
    {
      type = "item-subgroup",
      name = "recycle-base",
      group = group_name,
      order = "a",
      hidden_in_factoriopedia = true
    },
    {
      type = "virtual-signal",
      name = "recycle",
      subgroup = "recycle-base",
      icon = "__quality__/graphics/icons/recycling.png",
      icon_size = 64,
      hidden_in_factoriopedia = true
    },
  })
