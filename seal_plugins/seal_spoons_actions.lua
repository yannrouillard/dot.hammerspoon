local obj = {}
obj.__index = obj
obj.__name = "seal_spoons_actions"

local log = hs.logger.new('seal_spoons_actions', 'info')

local spoonActionsByName = {}
local spoonActionsChoices = {}

---
--- Private functions
---

function loadActionsFromSpoons()
    spoonActions = {}
    for _, spoonModule in pairs(spoon) do
        if spoonModule.sealActions then
            for actionName, action in pairs(spoonModule.sealActions) do
                spoonActionsByName[actionName] = action
                table.insert(spoonActionsChoices, {
                    text = actionName,
                    subText = action.subText,
                    image = action.image,
                    plugin = obj.__name
                })
            end
        end
    end
end

---
--- Seal plugin interface implementation
---

function obj:start()
    loadActionsFromSpoons()
end

function obj:commands()
    return {}
end

function obj:bare()
    return obj.choicesSpoonsActions
end

function obj.choicesSpoonsActions(query)
    local choices = hs.fnutils.filter(spoonActionsChoices, function(action)
        return action.text:lower():find(query) or (action.subText and action.subText:lower():find(query))
    end)
    return choices
end

function obj.completionCallback(rowInfo)
    local spoonAction = spoonActionsByName[rowInfo.text]
    if spoonAction.url then
        hs.urlevent.openURL(spoonAction.url)
    elseif spoonAction.fn then
        spoonAction.fn()
    end
end

obj:start()

return obj
