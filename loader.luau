--[[
    Universal Syn Save Instance - GUI Loader v1.13.7
    Forces fresh HTTP requests with unique URLs and no-cache request headers,
    validates the downloaded source, and reports fetch/compile/runtime errors.

    Usage:
        local HttpService = game:GetService("HttpService")
        local cacheBust = HttpService:GenerateGUID(false)
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/finalcircuitgame-crypto/UniversalSynSaveInstance/main/loader.luau?_ussi_nocache=" .. cacheBust
        ))()
]]

local BASE_URL = "https://raw.githubusercontent.com/finalcircuitgame-crypto/UniversalSynSaveInstance/"
local MAIN_URL = BASE_URL .. "main/saveinstance-gui.luau"

-- Stable fallback in case GitHub's main branch cannot be reached.
local FALLBACK_URL = BASE_URL .. "cdcf7a4c71d997565249efd8ee9525193e522647/saveinstance-gui.luau"

local MIN_VERSION = { 1, 13, 6 }

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

local HttpService = game:GetService("HttpService")

local function newCacheToken()
    -- GUIDs make each request URL different, even when the loader is run
    -- multiple times in the same second.
    local ok, guid = pcall(function()
        return HttpService:GenerateGUID(false)
    end)
    if ok and type(guid) == "string" then
        return guid
    end

    return tostring(os.time())
        .. "-"
        .. tostring(os.clock()):gsub("%.", "")
        .. "-"
        .. tostring(math.random(100000, 999999))
end

local function appendCacheToken(url)
    local separator = url:find("?", 1, true) and "&" or "?"
    return url .. separator .. "_ussi_nocache=" .. newCacheToken()
end

local function getFreshSource(url)
    local requestUrl = appendCacheToken(url)
    local noCacheHeaders = {
        ["Cache-Control"] = "no-cache, no-store, max-age=0",
        ["Pragma"] = "no-cache",
        ["Expires"] = "0",
    }

    -- Prefer the executor's request API so cache-control headers can be sent.
    -- Fall back to HttpGet with a unique URL if request/http_request is absent
    -- or unsupported by the executor.
    local requestFunction
    if type(request) == "function" then
        requestFunction = request
    elseif type(http_request) == "function" then
        requestFunction = http_request
    end

    if requestFunction then
        local ok, response = pcall(requestFunction, {
            Url = requestUrl,
            Method = "GET",
            Headers = noCacheHeaders,
        })

        if ok and type(response) == "table" then
            local statusCode = tonumber(response.StatusCode or response.StatusCodeValue)
            local body = response.Body
            if (not statusCode or (statusCode >= 200 and statusCode < 300))
                and type(body) == "string"
                and #body > 0 then
                return body
            end
        end
    end

    return game:HttpGet(requestUrl)
end

local function download(url)
    local ok, source = pcall(getFreshSource, url)
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
