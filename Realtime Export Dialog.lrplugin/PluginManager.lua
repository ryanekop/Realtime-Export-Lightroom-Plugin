local LrFunctionContext = import 'LrFunctionContext'
local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'

LrFunctionContext.postAsyncTaskWithContext( 'RealtimeExportDialog', function( context )
    
    local status, result = pcall(function()
        local RealtimeExportDialog = require 'RealtimeExportDialog'
        RealtimeExportDialog.show( context )
    end)

    if not status then
        LrDialogs.message( "Error launching plugin", result )
    end
end )
