local RealtimeExportDialog = {}

function RealtimeExportDialog.show( context )
    -- Import namespaces within function to ensure they are available
    local LrView = import 'LrView'
    local LrApplication = import 'LrApplication'
    local LrDialogs = import 'LrDialogs'
    local LrBinding = import 'LrBinding'
    local LrPathUtils = import 'LrPathUtils'
    local LrFileUtils = import 'LrFileUtils'
    

    
    local f = LrView.osFactory()
    
    -- Properties for the dialog
    local props = LrBinding.makePropertyTable( context )
    props.delay = 0.1
    props.isTethering = true
    props.selectedExportPreset = nil

    -- 2. Fetch EXPORT Presets (Manual File System)
    local exportPresetItems = {}
    -- Fix: Ensure LrPathUtils is valid
    if not LrPathUtils then 
        LrDialogs.message( "Error", "LrPathUtils not loaded!", "critical" )
        return 
    end

    local exportPresetsFolder = LrPathUtils.child( LrPathUtils.getStandardFilePath( 'appData' ), "Export Presets/User Presets" )
    
    -- Helper to recursively find templates
    local traverseExportTemplates
    traverseExportTemplates = function( dir )
        if LrFileUtils.exists( dir ) then
            for filePath in LrFileUtils.directoryEntries( dir ) do
                local ext = LrPathUtils.extension( filePath )
                if ext and string.lower( ext ) == "lrtemplate" then
                    local name = LrPathUtils.removeExtension( LrPathUtils.leafName( filePath ) )
                    table.insert( exportPresetItems, { title = name, value = filePath } ) -- Value is PATH now
                elseif LrFileUtils.exists( filePath ) == "directory" then
                    traverseExportTemplates( filePath )
                end
            end
        end
    end

    traverseExportTemplates( exportPresetsFolder )
    
    if #exportPresetItems > 0 then
         props.selectedExportPreset = exportPresetItems[1].value
    else
         table.insert(exportPresetItems, { title = "No User Export Presets Found", value = nil })
         table.insert(exportPresetItems, { title = "Checked: " .. exportPresetsFolder, value = nil })
    end

    local c = f:column {
        bind_to_object = props,
        spacing = f:control_spacing(),
        
        f:row {
            f:static_text { title = "Source:" },
            f:checkbox {
                title = "Monitor Tethering / New Photos",
                value = LrView.bind( "isTethering" ),
            },
        },
        
        f:row {
            f:static_text { title = "Delay (seconds):" },
            f:slider {
                value = LrView.bind( "delay" ),
                min = 0.1,
                max = 10,
                width = 300,
                precision = 1,
            },
            f:edit_field { 
                value = LrView.bind( "delay" ), 
                min = 0,
                max = 10,
                width_in_digits = 5,
                precision = 1,
            },
        },
        

        
        f:row {
            f:static_text { title = "Export Preset:" },
            f:popup_menu {
                value = LrView.bind( "selectedExportPreset" ),
                items = exportPresetItems,
                width = 300,
            },
        },
        
        f:static_text { 
            title = "Note: Create 'User Presets' in the standard Export dialog to appear here.",
            font = "<system/small>",
        },
    }

    local result = LrDialogs.presentModalDialog({
        title = "Realtime Export Settings",
        contents = c,
        actionVerb = "Start Export Hook",
    })

    if result == "ok" then
        if not props.selectedExportPreset then
            LrDialogs.message( "Error", "Please select a valid Export Preset.", "critical" )
            return
        end
        
        local params = {
            delay = props.delay,
            isTethering = props.isTethering,
            selectedExportPreset = props.selectedExportPreset
        }
        
        local ExportLogic = require 'ExportLogic'
        ExportLogic.start( params )
    end
end

return RealtimeExportDialog
