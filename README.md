> [!IMPORTANT]
> Independent, unofficial project. Not affiliated with, endorsed by, or officially connected to Roblox Corporation. "Luau" is a trademark of Roblox Corporation.
<p align="center">
  <img height="300px" style="margin: 0; padding: 0" src=".moonwave\static\logo.png" />
</p>

# Loadstring

```lua
local Params = {
 RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
 SSI = "saveinstance",
}
local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
local Options = {} -- Documentation here https://luau.github.io/UniversalSynSaveInstance/api/UniversalSynSaveInstance
synsaveinstance(Options)
```

# Executor GUI Loader (this fork)

This fork includes a standalone executor GUI. Run this loader to fetch the newest GUI source from this repository:

```lua
local HttpService = game:GetService("HttpService")
local cacheBust = HttpService:GenerateGUID(false)

loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/finalcircuitgame-crypto/UniversalSynSaveInstance/6d3079af6d3b5f15e88ce3ddb2a397496eb8b8a8/loader.luau?_ussi_nocache=" .. cacheBust
))()
```

The v1.13.6 loader sends no-cache headers when the executor exposes request/http_request, adds a fresh GUID query to every request, requires GUI v1.13.5 or newer, and falls back to the patched, commit-pinned v1.13.5 copy if the main branch cannot be fetched. The bootstrap example pins the loader itself to a specific commit and uses a fresh GUID query to avoid reusing a cached bootstrap response.

## Custom output names

In the GUI's **Save** tab, use **Custom output name** to name the exported file. For example, entering `Example Experience Backup` with **RBXL - Place (Binary)** selected saves as `Example Experience Backup.rbxl`. Leave the field empty to use the automatic name. The selected format supplies the extension.

## Loading and save progress

GUI v1.13.5 includes a startup panel with download, compile, and engine initialization stages. During a save, the USSI status card reports hierarchy collection, encoded object counts, output size, and file writing. Percentages are shown only for stages where the engine can measure progress; a single whole-file `writefile` call uses an animated indeterminate bar instead.

## GUI v1.13.5 feature set

GUI v1.13.5 also fixes the startup compile issue caused by exceeding Luau's 200-active-local limit; startup references and saved window geometry are grouped into tables.\n\nThe GUI adds 20 categorized workflow features:

**Visuals (5):** five color themes, adjustable interface scale, compact layout, reduced motion, and window opacity.

**Optimization (5):** Balanced/Fastest/Smaller output/Maximum detail save profiles, configurable appendfile chunk size (1–16 MB), configurable Explorer search result limit, configurable search yield interval, and optional alphabetical sorting.

**Miscellaneous (5):** minimize/restore with `Left Ctrl + Left Shift + U`, remembered window size and position, reset-layout button, save-completion toast notifications, and a close guard while saving.

**Useful tools (5):** validate an Instance path, recent target history, persistent favorite targets, copy an Instance path, and use the selected Instance name as the output filename.

Save profiles affect the next save run and may override individual options for that run. The configurable chunk size only affects the engine's `appendfile` output path; it is clamped by the engine to 256 KB–16 MB.

The **Open project repository** button tries common executor browser-opening functions first. When the executor does not expose one, it copies the GitHub URL and displays a fallback message instead.

# Universal Syn Save Instance

Or shortly USSI, a project aimed at resurrecting saveinstance function from Synapse X.<br />
Reason: Many tools fail miserably at providing good user experience when it comes to tinkering with saving instances.

> [!WARNING]
> As stated under the Section 7 (b) in the LICENSE:
> - You **MUST** always include the following Credit string: `UniversalSynSaveInstance https://discord.gg/wx4ThpAsmw`
> - You are **NOT** allowed to claim authorship of the source code provided in this repository
> - You **MUST** always include the following [License](https://github.com/luau/UniversalSynSaveInstance/blob/main/LICENSE)

## Disclaimer

This project is provided for development, debugging, archival, and research purposes within the Roblox platform.

It is not intended for misuse, including violating platform rules, unauthorized access, or redistribution of content without permission.

Users are responsible for ensuring their usage complies with all applicable rules, including Roblox’s Terms of Use.

The maintainers do not support or condone misuse of this software and are not responsible for how it is used.

> [!TIP]
> If this script is helpful to you, please click `⭐ Star` in the upper right corner of the page to support it, thank you!

# Documentation

[Documentation]

# 💖 Support Us & Our Work

<a href='https://ko-fi.com/M4M1JNH5G' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi2.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' title='KO-FI' /></a>
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/M4M1JNH5G "KO-FI")
<br />
[![ko-fi](https://user-images.githubusercontent.com/95628489/231759262-25661006-b7ca-4967-a79d-2b465cd9575a.png)](https://ko-fi.com/M4M1JNH5G "KO-FI QR-CODE")

# DISCORD SERVER:<br />

<https://discord.com/invite/wx4ThpAsmw> **/** <https://discord.gg/wx4ThpAsmw><br />
[<img src="https://discordapp.com/api/guilds/1022465460517740654/widget.png?style=banner2" alt="Our Official Discord Server!"></img>](https://discord.com/invite/wx4ThpAsmw)<br />

# TO-DOs

- [x] Look into adding support for Binary Format Output (rbxl/rbxm)
- [ ] Add table.clone instead {} in some cases if possible
- [x] Support for Model files:
  - [x] rbxmx (xml)
  - [x] rbxm (binary)
- [x] Implement [Luau Syntax] (important for performance!):
  - [x] Compound Operators
  - [x] Avoid using `next`, `ipairs` & `pairs`
  - [x] ~~Interpolated strings instead of concat~~ Slower
  - [ ] Type-checking (😩🙀)
  - [ ] ~~`if-then-else` expressions~~ No reason to
  - [ ] Floor division

- [x] Speed things up as much as possible
  - Requires benchmarks
- [x] Support for as many [KRNL-like saveinstance Options] & [UNC]:
  - Change mode to invalid mode like "custom" if you only want to save ExtraInstances
  * [x] Decompile (! This takes priority over OPTIONS.noscripts if set !)
  * [x] DecompileIgnore
  * [x] DecompileTimeout (! This takes priority over OPTIONS.timeout if set !)
  * [x] ExtraInstances
  * [x] FilePath
  * [x] IgnoreDefaultProps
  * [x] IsolateStarterPlayer
  * [x] NilInstances
  * [x] Object (for .rbxmx files)
  * [x] RemovePlayerCharacters
  * [x] SavePlayers
  * [x] ShowStatus
    - [x] ~~Add Drawing Library support for ShowStatus~~ Can't reliably test if it's working on a tool
  * [x] IsolatePlayerGui (same as IsolateLocalPlayer)
  * [x] Callback
  * [x] CopyToClipboard/Clipboard
  * [x] Binary (rbxl/rbxm)
- [x] ~~Remove buffersize, savebuffer & so on for sake of performance by concatenating <Item> strings to total string then writing it to file (no extra steps like table.concat)~~ table.concat proved faster in the case of huge amount of concatenations
  - Test table.concat vs string ..= with a full buffer (this benchmark differs per usecase)
- [ ] Add Option to restart saveinstance from the point that it crashed on (perhaps by skipping)
- [ ] Maybe modes should do more than just determining the list of instances to save, like changing IgnoreDefaultProperties to false if mode is "full" for example
- [x] Add Lua & Luau versions instead of merged (WARNING: LUAU MIGHT BE MORE UPDATED THAN LUA VERSION, lua version exists just for the sake of old & bad tools, ask devs of your tools to support luau as its latest & greatest)
- [x] ~~Add Support for multiple Instances to be saved as a model~~ IsModel = true & ExtraInstances
- [x] ~~Force disable ParticleEmitters in case something like IgnorePropertiesOfNotScriptsOnScriptsMode is enabled (they stack in one place and create huge lag)~~ Not needed anymore it seems as empty FlipbookLayout breaks them which also results in no particles
- [ ] Be able to specify which special properties you want saved (to avoid saving all)

# Acknowledgments
> [!IMPORTANT]
> This document is based largely on the efforts of [@Anaminus] & [@Dekkonot], authors of the [Roblox Format Specifications]. Additional
resources include:
> 
> - [Syngp Synapse X Source code 2019][Synapse X Source 2019] for base saveinstance code (extended by [@mblouka] & [@Acrillis])
> - [Moon/LorekeeperZinnia][@LorekeeperZinnia] for being the original creator of saveinstance that was used in Synapse X, Elysian and many others. As well as being an inspiration for this project.
> - [Rojo Rbx Dom Xml] for being a fallback documentation in case something wasn't clear in the [Roblox Format Specifications]
> - [Roblox File Format] for a list of redirects of old/deprecated xml properties that still use the old tag values
> - [Roblox Client Tracker] for an extended & close to full JSON Api Dump (with hidden properties & default values)

\*\*\* View source code of this file for more credits

[Documentation]: https://luau.github.io/UniversalSynSaveInstance/api/UniversalSynSaveInstance
[@Acrillis]: https://github.com/Acrillis
[@Anaminus]: https://github.com/Anaminus
[@Dekkonot]: https://github.com/Dekkonot
[@mblouka]: https://github.com/mblouka
[@LorekeeperZinnia]: https://github.com/LorekeeperZinnia
[saveinstance Options]: https://app.archbee.com/public/PREVIEW-2Jp4SDaAD4P1COFfx1p_t/PREVIEW-EtjA4sQe5zYUxIHwA6CqJ#mDB9D
[Rojo Rbx Dom Xml]: https://github.com/rojo-rbx/rbx-dom/blob/master/docs/xml.md
[Rojo Rbx Dom Binary]: https://github.com/rojo-rbx/rbx-dom/blob/master/docs/binary.md
[Luau Syntax]: https://luau-lang.org/syntax
[Rbx-Binary-Format]: https://github.com/Dekkonot/rbx-binary-format/blob/master/src/writer.lua
[Roblox Client Tracker]: https://github.com/MaximumADHD/Roblox-Client-Tracker
[Roblox File Format]: https://github.com/MaximumADHD/Roblox-File-Format
[Roblox Format Specifications]: https://github.com/RobloxAPI/spec/
[Roblox Format Specifications Binary]: https://github.com/RobloxAPI/spec/blob/master/formats/rbxl.md
[Synapse X Source 2019]: https://github.com/Acrillis/SynapseX
[UNC]: https://github.com/unified-naming-convention/NamingStandard/commit/613c1956b801ace54ba141dfc60842a16608b54f
