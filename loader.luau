--[[
    Universal Syn Save Instance - GUI Loader
    Fetches the newest GUI from the repository, bypasses stale URL caches,
    validates the downloaded source, and reports fetch/compile/runtime errors.

    Usage:
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/finalcircuitgame-crypto/UniversalSynSaveInstance/main/loader.luau"
        ))()
]]

local BASE_URL = "https://raw.githubusercontent.com/finalcircuitgame-crypto/UniversalSynSaveInstance/"
local MAIN_URL = BASE_URL .. "main/saveinstance-gui.luau"

-- Stable fallback in case GitHub's main branch cannot be reached.
local FALLBACK_URL = BASE_URL .. "4d4f61a7daef6aacef18b5d3924ba84f8c571ff3/saveinstance-gui.luau"

local MIN_VERSION = { 1, 13, 1 }

local function log(message)
    print("[USSI Loader] " .. tostring(message))
end

local function reportError(stage, message)
    warn("[USSI Loader] " .. stage .. " failed: " .. tostring(message))
end

local function parseVersion(version)
    local major, minor, patch = tostring(version):match("^v?(%d+)%.(%d+)%.(%d+)$")
    if not major then return nil end
    return { tonumber(major), tonumber(minor), tonumber(patch) }
end

local function versionAtLeast(version, minimum)
    local parsed = parseVersion(version)
    if not parsed then return false end

    for index = 1, 3 do
        if parsed[index] > minimum[index] then return true end
        if parsed[index] < minimum[index] then return false end
    end
    return true
end

local function download(url)
    -- A unique query string prevents stale raw-GitHub/CDN responses.
    local cacheKey = string.format("%.6f", os.clock()):gsub("%.", "")
    local requestUrl = url .. "?cache=" .. cacheKey

    local ok, source = pcall(function()
        return game:HttpGet(requestUrl)
    end)

    if not ok then
        return nil, source
    end
    if type(source) ~= "string" or #source < 1000 then
        return nil, "GitHub returned an empty or incomplete GUI source."
    end

    local version = source:match('local GUI_VERSION%s*=%s*"([^"]+)"')
    if not version then
        return nil, "The downloaded file does not contain a GUI version marker."
    end
    if not versionAtLeast(version, MIN_VERSION) then
        return nil, "GitHub returned outdated GUI " .. version .. "."
    end
    if not source:find("USSI_Executor_GUI", 1, true) then
        return nil, "The downloaded file does not look like the USSI GUI."
    end

    return source, version
end

if type(loadstring) ~= "function" then
    reportError("Environment check", "loadstring is unavailable in this executor.")
    return
end

log("Checking for the latest GUI...")

local source, version = download(MAIN_URL)
if not source then
    local mainError = version
    log("Main branch unavailable (" .. tostring(mainError) .. "); trying the stable fallback.")
    source, version = download(FALLBACK_URL)
end

if not source then
    reportError("Download", version)
    return
end

log("Downloaded GUI " .. version .. ". Compiling...")

local chunk, compileError = loadstring(source, "@USSI_GUI_" .. version)
if type(chunk) ~= "function" then
    reportError("Compile", compileError or "loadstring did not return a function.")
    return
end

local ran, runtimeError = pcall(chunk)
if not ran then
    reportError("Execution", runtimeError)
    return
end

log("GUI " .. version .. " executed successfully.")
