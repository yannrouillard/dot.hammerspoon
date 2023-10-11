local obj = {}
obj.__index = obj
obj.__name = "seal_quick_contacts"

obj.contacts_file = hs.configdir .. "/contacts/contacts_list.json"
obj.contacts_image_folder = hs.configdir .. "/contacts/images"

local log = hs.logger.new('seal_quick_contacts', 'info')

local contactsChoices = {}

---
--- Private functions
---

function loadQuickContacts()
    local contacts = hs.json.read(obj.contacts_file)
    for contactName, contactInfo in pairs(contacts) do
        local choice = {
            text = contactName,
            image = hs.image.imageFromPath(obj.contacts_image_folder .. "/" .. contactName .. ".jpg"),
            plugin = obj.__name
        }
        if contactInfo.phone then
            choice.url = "whatsapp://send?phone=" .. contactInfo.phone
        elseif contactInfo.slackChannel then
            choice.url = "slack://channel?" .. contactInfo.slackChannel
        end
        table.insert(contactsChoices, choice)
    end
end

---
--- Seal plugin interface implementation
---

function obj:start()
    loadQuickContacts()
end

function obj:commands()
    return {}
end

function obj:bare()
    return obj.choicesContacts
end

function obj.choicesContacts(query)
    local choices = hs.fnutils.filter(contactsChoices, function(choice)
        return choice.text:lower():find(query:lower())
    end)
    return choices
end

function obj.completionCallback(rowInfo)
    hs.urlevent.openURL(rowInfo.url)
end

obj:start()

return obj
