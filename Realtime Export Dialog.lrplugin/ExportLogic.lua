local ExportLogic = {}

function ExportLogic.start( props )
    -- Import namespaces locally to avoid scope issues
    local LrApplication = import 'LrApplication'
    local LrTasks = import 'LrTasks'
    local LrExportSession = import 'LrExportSession'
    local LrPathUtils = import 'LrPathUtils'
    local LrFileUtils = import 'LrFileUtils'
    local LrProgressScope = import 'LrProgressScope'

    LrTasks.startAsyncTask( function()
        local scope = LrProgressScope({ title = "Realtime Export Monitoring" })
        scope:setCaption("Watching for new photos...")
        scope:setPortionComplete(0, 1)

        local catalog = LrApplication.activeCatalog()
        local allPhotos = catalog:getAllPhotos()
        local lastPhotoCount = #allPhotos
        
        -- Copy props
        local delay = props.delay
        local exportPreset = props.selectedExportPreset -- The native LrExportPreset path (string)

        local outputFile = LrPathUtils.child(LrPathUtils.getStandardFilePath('desktop'), "LrPluginLog.txt")
        
        local function log( msg )
            scope:setCaption( msg )
            local f = io.open(outputFile, "a")
            if f then
                f:write( os.date("%H:%M:%S") .. ": " .. msg .. "\n" )
                f:close()
            end
        end
        
        -- Clear log file on start
        local f = io.open(outputFile, "w")
        if f then f:write("Session Started (Native Presets Mode)\n"); f:close() end
        
        log("Started. Initial count: " .. lastPhotoCount)
        local expName = "Unknown"
        if exportPreset and type(exportPreset) == "string" then 
            expName = LrPathUtils.leafName(exportPreset) 
        end
        
        log("Config: ExportPreset=" .. expName)
        
        ExportLogic.running = true

        while ExportLogic.running do
            if scope:isCanceled() then
                log("Monitoring stopped by user.")
                ExportLogic.running = false
                break
            end
        
            local currentPhotos = catalog:getAllPhotos()
            local currentCount = #currentPhotos
            
            if currentCount > lastPhotoCount then
                local newCount = currentCount - lastPhotoCount
                log("New photo(s) detected: " .. newCount)
                
                -- Find the new photos by time
                local allPhotoData = {}
                for _, p in ipairs(currentPhotos) do
                    local time = p:getRawMetadata("captureTime") 
                    if time then
                        table.insert(allPhotoData, { photo = p, time = time })
                    end
                end
                
                table.sort(allPhotoData, function(a, b) return a.time < b.time end)
                
                -- Identify the specific new photos (last 'newCount' items)
                local photosToProcess = {}
                for i = 1, newCount do
                    local index = #allPhotoData - newCount + i
                    if index > 0 and allPhotoData[index] then
                        table.insert(photosToProcess, allPhotoData[index].photo)
                    end
                end
                
                -- Process each new photo
                for _, photo in ipairs(photosToProcess) do
                    if scope:isCanceled() then break end
                    
                    log("Processing: " .. photo:getFormattedMetadata("fileName"))
                    
                    -- Non-blocking sleep for fractional support
                    if delay and tonumber(delay) > 0 then
                        scope:setCaption("Stable wait: " .. delay .. "s")
                        LrTasks.sleep(tonumber(delay))
                    end
                    
                    if scope:isCanceled() then break end

                    -- 2. Export using Native Preset
                    scope:setCaption("Exporting...")
                    local finalExportSettings = nil
                    
                    if exportPreset and LrFileUtils.exists(exportPreset) then
                        log("Loading Export Preset from: " .. exportPreset)
                        -- Safe way to load lua table from file
                        local status, result = pcall(function()
                            local chunk, loadErr = loadfile(exportPreset)
                            if chunk then
                                -- setfenv is nil in this LR version, so standard execution
                                -- LrTemplates usually set global 's'
                                _G.s = nil 
                                local ret = chunk()
                                
                                if ret then return ret end
                                if _G.s then return _G.s end
                                return nil
                            else
                                error("Could not load chunk: " .. tostring(loadErr))
                            end
                        end)
                        
                        if status and type(result) == "table" then
                            -- Standard presets have settings in 'value' key
                            if result.value then
                                finalExportSettings = result.value
                            else
                                finalExportSettings = result
                            end
                            log("Preset loaded successfully.")
                        else
                             log("Error loading preset: " .. tostring(result))
                        end
                    else
                        log("Error: Export Preset path is invalid: " .. tostring(exportPreset))
                    end
                    
                    if finalExportSettings then
                        log("Starting native export...")
                        
                        local exportSession = LrExportSession({
                            photosToExport = { photo },
                            exportSettings = finalExportSettings
                        })
                        
                        exportSession:doExportOnNewTask()
                        log("Export task launched.")
                    else
                         log("Failed to prepare export settings.")
                    end
                end
                
                lastPhotoCount = currentCount
                scope:setCaption("Waiting for next photo...")
            end
            
            LrTasks.sleep( 1 )
        end
        
        scope:done()
    end )
end

return ExportLogic
