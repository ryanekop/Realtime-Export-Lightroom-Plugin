# Realtime Export Plugin for Lightroom Classic

A powerful Lightroom Classic plugin designed for photographers who need real-time export capabilities. This tool monitors your catalog for new photos (perfect for tethering) and automatically exports them using your chosen Export Preset after a configurable delay.

## Features

- **Real-time Monitoring**: Automatically detects new photos added to the catalog.
- **Tethering Support**: Works seamlessly with Lightroom's tethering feature.
- **Configurable Delay**: Set a precise delay (0.1s to 10s) before export to ensure file stability.
- **Burst Mode Support**: Smart queue system handles rapid bursts of photos without skipping any images.
- **Native Export Presets**: Utilizes your existing Lightroom Export Presets for consistent results.
- **Stop Control**: Easy-to-use "Stop" button to end the monitoring session.

## Installation

1. Download or clone this repository.
2. Open **Adobe Lightroom Classic**.
3. Go to **File > Plug-in Manager**.
4. Click **Add** in the bottom left corner.
5. Browse to the downloaded folder and select `Realtime Export Dialog.lrplugin`.
6. Click **Add Plug-in**.
7. The plugin should now appear in the list with a green status light.

## Usage

1. Go to **Library > Plugin Extras > Realtime Export** (or where the menu item is located).
2. **Settings Dialog**:
   - **Monitor Tethering**: Check this to enable monitoring.
   - **Delay (seconds)**: Set the wait time before export. 
     - *Default*: `0.1s` (Fastest).
     - *Range*: `0.1s` - `10s`.
     - *Tip*: Use the text box to type precise values like `0.5`.
   - **Export Preset**: Select one of your User Presets to define *how* and *where* the photo is exported (e.g., JPEG to Desktop, TIFF to Server).
3. Click **Start Export Hook**.
4. The plugin will now run in the background. A progress bar will appear in the top-left indicating it is "Watching for new photos...".
5. Capture photos (Tether) or import them. The plugin will automatically process and export them.

## Requirements

- Adobe Lightroom Classic (Tested on latest versions)
- macOS / Windows

## License

This project is open source. Feel free to modify and distribute.
