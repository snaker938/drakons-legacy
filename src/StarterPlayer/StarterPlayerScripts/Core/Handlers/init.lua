local HandlerCache = {}

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.GetHandler(handlerName)
    return HandlerCache[handlerName]
end

function Module.IsHandling(handlerName)
    local cachedModule = HandlerCache[handlerName]
    if not cachedModule then
        return
    end
    return cachedModule.Handling
end

function Module.StartHandler(handlerName, ...)
    local cachedModule = HandlerCache[handlerName]
    if not cachedModule then
        return
    end

    -- Check if the handler is handling, if it isnt, then start it
    if not cachedModule.Handling then
        cachedModule.StartHandling(...)
    end
end

function Module.EndHandler(handlerName, ...)
    local cachedModule = HandlerCache[handlerName]
    if not cachedModule then
        return
    end

    -- Check if the handler is handling, if it is then end it
    if cachedModule.Handling then
        cachedModule.EndHandling(...)
    end
end

function Module.EndAllHandling(ingoreHandlerList)
    -- Ends all the handlers except the ones in the ignore list
    for handlerName, HandlerModule in pairs(HandlerCache) do
        if table.find(ingoreHandlerList, handlerName) then
            continue
        end

        -- Check if the handler is handling, if it is then end it
        if HandlerModule.Handling then
            HandlerModule.EndHandling()
        end
    end
end

function Module.ResetHandler(handlerName, ...)
    local cachedModule = HandlerCache[handlerName]
    if not cachedModule then
        return
    end
    
    -- Check if the handler is handling, if it is then end it
    if cachedModule.Handling then
        cachedModule.EndHandling(...)
    end
  
    cachedModule.StartHandling(...)
end

function Module.Start()
    for _, HandlerModule in pairs(HandlerCache) do
        HandlerModule.EndHandling()
    end
end

function Module.Init(otherSystems)
    SystemsContainer = otherSystems

    print("------------ INITIALISING HANDLERS ------------")

    for _, HandlerModule in pairs(script:GetDescendants()) do
        if not HandlerModule:IsA("ModuleScript") then
            continue
        end

        print("Initialising handler: " .. HandlerModule.Name)
        local Cached = require(HandlerModule)
        Cached.Init(Module, SystemsContainer)
        HandlerCache[HandlerModule.Name] = Cached
    end

    print("------------ INITIALISED HANDLERS ------------")
end

return Module