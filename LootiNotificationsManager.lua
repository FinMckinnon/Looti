NotificationManager = {
    showNotificationFrame = true, -- Initialise as true
    listeners = {} -- Stores listener callbacks
}

function NotificationManager:AddListener(callback)
    if type(callback) == "function" then
        table.insert(self.listeners, callback)
    end
end

function NotificationManager:SetShowNotificationFrame(value)
    if self.showNotificationFrame ~= value then
        self.showNotificationFrame = value
        self:NotifyListeners(value)
    end
end

function NotificationManager:NotifyListeners(value)
    for _, listener in ipairs(self.listeners) do
        listener(value)
    end
end