#Requires -Version 5.1
<#
    NULL'S MOD ANALYZER v1.0
    Minecraft Mod Analysis & Cheat Detection
    Made by Null / Codebuff
#>

param(
    [string]$ModPath = "",
    [string]$MinecraftDir = "",
    [string]$ReportPath = "",
    [switch]$Interactive,
    [switch]$ExportJSON,
    [switch]$NoColor
)

$ErrorActionPreference = "SilentlyContinue"

$BANNER = @"
     _   _                      _    _                   ___                        ____
    | \ | | ___ _   _ _ __ __ / \  | | ___  _ __ ___   / _ \ _ __   ___ _ __ __ _ / ___|  ___ __ _ _ __
    |  \| |/ _ \ | | | '__/ _ \ | | | |/ _ \| '__/ _ \ | | | '_ \ / _ \ '__/ _` | |  _ | __/ _` | '__|
    | |\  |  __/ |_| | | | (_) | | |_| | (_) | | | (_) | |_| | |_) |  __/ | | (_| | |_| || (_| | |
    |_| \_|\___|\__,_|_|  \___/  \___/ \___/|_|  \___/  \___/| .__/ \___|_|  \__,_|\____|\__,_|_|
                                                               |_|
              M O D   A N A L Y Z E R   v 1 . 0
"@

# ================================================================
# CHEAT SIGNATURE DATABASE
# ================================================================

$CHEAT_SIGNATURES = @{
    "KillAura"      = @{ Threat="CRITICAL"; Cat="Combat";     Desc="Automated attack / hit aura" }
    "Reach"         = @{ Threat="HIGH";     Cat="Combat";     Desc="Extended attack reach" }
    "Velocity"      = @{ Threat="HIGH";     Cat="Combat";     Desc="Knockback reduction / cancel" }
    "AntiKnockback" = @{ Threat="HIGH";     Cat="Combat";     Desc="Nullifies server knockback" }
    "CrystalAura"   = @{ Threat="CRITICAL"; Cat="Combat";     Desc="Auto end crystal combat" }
    "AutoCrystal"   = @{ Threat="CRITICAL"; Cat="Combat";     Desc="Automated crystal PvP" }
    "AutoTotem"     = @{ Threat="MEDIUM";   Cat="Combat";     Desc="Automatic totem swap" }
    "BowAimbot"     = @{ Threat="HIGH";     Cat="Combat";     Desc="Perfect bow aiming" }
    "Aimbot"        = @{ Threat="CRITICAL"; Cat="Combat";     Desc="Auto-aim at targets" }
    "Triggerbot"    = @{ Threat="CRITICAL"; Cat="Combat";     Desc="Auto-shoot on crosshair" }
    "HitBox"        = @{ Threat="HIGH";     Cat="Combat";     Desc="Expanded hitboxes" }
    "MultiAura"     = @{ Threat="CRITICAL"; Cat="Combat";     Desc="Multi-target kill aura" }
    "TornadoAura"   = @{ Threat="CRITICAL"; Cat="Combat";     Desc="360-degree kill aura" }
    "SpinAura"      = @{ Threat="CRITICAL"; Cat="Combat";     Desc="Spinning kill aura" }
    "Surround"      = @{ Threat="HIGH";     Cat="Combat";     Desc="Auto obsidian surround" }
    "NoFall"        = @{ Threat="HIGH";     Cat="Movement";   Desc="Fall damage bypass" }
    "Fly"           = @{ Threat="HIGH";     Cat="Movement";   Desc="Flight in survival" }
    "Speed"         = @{ Threat="MEDIUM";   Cat="Movement";   Desc="Movement speed boost" }
    "Jesus"         = @{ Threat="HIGH";     Cat="Movement";   Desc="Walk on water/lava" }
    "NoSlowDown"    = @{ Threat="MEDIUM";   Cat="Movement";   Desc="No slowdown from items" }
    "Burrow"        = @{ Threat="CRITICAL"; Cat="Movement";   Desc="Clip into blocks" }
    "Phase"         = @{ Threat="CRITICAL"; Cat="Movement";   Desc="Walk through blocks" }
    "NoClip"        = @{ Threat="CRITICAL"; Cat="Movement";   Desc="Noclip through all blocks" }
    "PacketFly"     = @{ Threat="CRITICAL"; Cat="Movement";   Desc="Packet-based flight" }
    "ClickTP"       = @{ Threat="HIGH";     Cat="Movement";   Desc="Teleport on click" }
    "Teleport"      = @{ Threat="HIGH";     Cat="Movement";   Desc="Position teleportation" }
    "AntiVoid"      = @{ Threat="MEDIUM";   Cat="Movement";   Desc="Void damage bypass" }
    "ElytraFly"     = @{ Threat="HIGH";     Cat="Movement";   Desc="Elytra speed boost / fly" }
    "AutoElytra"    = @{ Threat="MEDIUM";   Cat="Movement";   Desc="Automatic elytra launch" }
    "Step"          = @{ Threat="MEDIUM";   Cat="Movement";   Desc="Automatic step up blocks" }
    "Sprint"        = @{ Threat="MEDIUM";   Cat="Movement";   Desc="Unlimited sprint" }
    "Scaffold"      = @{ Threat="CRITICAL"; Cat="World";      Desc="Auto-bridge / block placement" }
    "Tower"         = @{ Threat="HIGH";     Cat="World";      Desc="Auto-tower with blocks" }
    "Nuker"         = @{ Threat="CRITICAL"; Cat="World";      Desc="Instant block destruction" }
    "FastBreak"     = @{ Threat="MEDIUM";   Cat="World";      Desc="Instant block breaking" }
    "FastPlace"     = @{ Threat="MEDIUM";   Cat="World";      Desc="Instant block placement" }
    "PistonAura"    = @{ Threat="HIGH";     Cat="World";      Desc="Piston-based combat" }
    "Grief"         = @{ Threat="CRITICAL"; Cat="World";      Desc="Server griefing tools" }
    "XRay"          = @{ Threat="HIGH";     Cat="Render";     Desc="See through blocks" }
    "ESP"           = @{ Threat="HIGH";     Cat="Render";     Desc="Entity / player highlighting" }
    "WallHack"      = @{ Threat="HIGH";     Cat="Render";     Desc="See through walls" }
    "Tracers"       = @{ Threat="MEDIUM";   Cat="Render";     Desc="Lines to players" }
    "Freecam"       = @{ Threat="HIGH";     Cat="Render";     Desc="Detached camera noclip" }
    "ChestESP"      = @{ Threat="HIGH";     Cat="Render";     Desc="Highlight chests" }
    "HoleESP"       = @{ Threat="HIGH";     Cat="Render";     Desc="Highlight safe holes" }
    "Radar"         = @{ Threat="MEDIUM";   Cat="Render";     Desc="Entity radar" }
    "MatrixDisabler"= @{ Threat="CRITICAL"; Cat="AC Bypass";  Desc="Bypasses Matrix AC" }
    "NCPDisabler"   = @{ Threat="CRITICAL"; Cat="AC Bypass";  Desc="Bypasses NoCheatPlus" }
    "VulcanDisabler"= @{ Threat="CRITICAL"; Cat="AC Bypass";  Desc="Bypasses Vulcan AC" }
    "GrimDisabler"  = @{ Threat="CRITICAL"; Cat="AC Bypass";  Desc="Bypasses Grim AC" }
    "IntaveDisabler"= @{ Threat="CRITICAL"; Cat="AC Bypass";  Desc="Bypasses Intave AC" }
    "PingSpoof"     = @{ Threat="HIGH";     Cat="AC Bypass";  Desc="Fakes player ping" }
    "AutoTool"      = @{ Threat="MEDIUM";   Cat="Utility";    Desc="Automatic tool switching" }
    "AutoArmor"     = @{ Threat="MEDIUM";   Cat="Utility";    Desc="Automatic armor equipping" }
    "AntiHunger"    = @{ Threat="MEDIUM";   Cat="Survival";   Desc="Prevents hunger loss" }
    "AutoDisconnect"= @{ Threat="MEDIUM";   Cat="Utility";    Desc="Auto logout on low HP" }
    "Spammer"       = @{ Threat="MEDIUM";   Cat="Chat";       Desc="Chat spam bot" }
    "Bedwars"       = @{ Threat="HIGH";     Cat="Minigame";   Desc="Bedwars automation" }
    "Skywars"       = @{ Threat="HIGH";     Cat="Minigame";   Desc="Skywars automation" }
    "Dupe"          = @{ Threat="CRITICAL"; Cat="Exploit";    Desc="Item duplication exploit" }
    "Wurst"         = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="Wurst client" }
    "Impact"        = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="Impact client" }
    "Inertia"       = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="Inertia client" }
    "SalHack"       = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="SalHack client" }
    "Rise"          = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="Rise client" }
    "Moon"          = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="Moon client" }
    "Ares"          = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="Ares client" }
    "Vape"          = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="Vape client" }
    "Tenacity"      = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="Tenacity client" }
    "Spectre"       = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="Spectre client" }
    "DripLac"       = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="DripLac client" }
    "Novoline"      = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="Novoline client" }
    "Astolfo"       = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="Astolfo client" }
    "Sigma"         = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="Sigma client" }
    "Horion"        = @{ Threat="CRITICAL"; Cat="Cheat Client"; Desc="Horion client" }
}

$KNOWN_CHEAT_CLIENTS = @(
    "wurst","impact","inertia","salhack","rise","moon","ares",
    "vape","artois","tenacity","spectre","driplac","novoline",
    "astolfo","raven","sigma","horion","meteor","baritone",
    "kamiblue","celestia","phobos","future","bleachhack",
    "liquidbounce","ghostclient","catalyst","dank","bhop",
    "rexuiz","xavehack","caketech","mineshafter","nullclient"
)

$KNOWN_C2_ENDPOINTS = @(
    "pastebin.com/raw","hastebin.com/raw","rentry.co","paste.ee",
    "ghostbin.co","discord.com/api/webhooks","api.telegram.org",
    "webhook.site","requestbin","pipedream.net","ngrok.io",
    "burpcollaborator.net","interact.sh","canarytokens.com"
)

$KNOWN_MALICIOUS_PACKAGES = @(
    "com.minecraftstealer","net.tokenlogger","org.discordwebhook",
    "com.mojang.authlib.hook","javax.crypto.malicious",
    "com.rat.server","org.remote.access","net.c2.client",
    "org.obfuscator","net.stringer","com.procyon"
)

# ================================================================
# HELPER FUNCTIONS
# ================================================================

function Write-Threat {
    param([string]$Level, [string]$Message)
    $ts = Get-Date -Format "HH:mm:ss"
    if (-not $NoColor) {
        switch ($Level) {
            "CRITICAL" { Write-Host "[$ts] [!!! CRITICAL] $Message" -ForegroundColor Red -BackgroundColor DarkRed }
            "HIGH"     { Write-Host "[$ts] [!! HIGH]      $Message" -ForegroundColor Red }
            "MEDIUM"   { Write-Host "[$ts] [! MEDIUM]     $Message" -ForegroundColor Yellow }
            "LOW"      { Write-Host "[$ts] [~ LOW]        $Message" -ForegroundColor DarkYellow }
            "INFO"     { Write-Host "[$ts] [i INFO]       $Message" -ForegroundColor Cyan }
            "OK"       { Write-Host "[$ts] [OK]           $Message" -ForegroundColor Green }
            "SCAN"     { Write-Host "[$ts] [>> SCAN]      $Message" -ForegroundColor Magenta }
            "HEADER"   { Write-Host "[$ts] [============] $Message" -ForegroundColor White }
        }
    } else {
        Write-Output "[$ts] [$Level] $Message"
    }
}

function Get-ThreatColor {
    param([string]$Level)
    switch ($Level) { "CRITICAL" { return "Red" } "HIGH" { return "DarkRed" } "MEDIUM" { return "Yellow" } "LOW" { return "DarkYellow" } default { return "Gray" } }
}

function Get-ModMetadata {
    param([string]$JarPath)
    $metadata = @{
        FileName   = [System.IO.Path]::GetFileName($JarPath)
        FileSizeMB = [math]::Round((Get-Item $JarPath).Length / 1MB, 2)
        Hash       = (Get-FileHash -Path $JarPath -Algorithm SHA256).Hash
        Modified   = (Get-Item $JarPath).LastWriteTime
    }
    try {
        $tempDir = Join-Path $env:TEMP "nullmod_$([System.IO.Path]::GetRandomFileName())"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($JarPath, $tempDir)

        # fabric.mod.json
        $fm = Join-Path $tempDir "fabric.mod.json"
        if (Test-Path $fm) {
            $fd = Get-Content $fm -Raw | ConvertFrom-Json
            $metadata["ModName"] = $fd.name; $metadata["ModID"] = $fd.id
            $metadata["Version"] = $fd.version; $metadata["Authors"] = ($fd.authors -join ", ")
            $metadata["Loader"] = "Fabric"
        }
        # Forge mods.toml
        $ft = Join-Path $tempDir "META-INF\mods.toml"
        if (Test-Path $ft) {
            $fc = Get-Content $ft -Raw
            $metadata["Loader"] = "Forge"
            if ($fc -match 'modId\s*=\s*"?(\w+)"?') { $metadata["ModID"] = $Matches[1] }
            if ($fc -match 'displayName\s*=\s*"(.+?)"') { $metadata["ModName"] = $Matches[1] }
            if ($fc -match 'version\s*=\s*"(.+?)"') { $metadata["Version"] = $Matches[1] }
            if ($fc -match 'authors\s*=\s*"(.+?)"') { $metadata["Authors"] = $Matches[1] }
        }
        # Legacy mcmod.info
        $mi = Join-Path $tempDir "mcmod.info"
        if (Test-Path $mi) {
            $ld = Get-Content $mi -Raw | ConvertFrom-Json
            if ($ld[0]) {
                $metadata["ModName"] = $ld[0].name; $metadata["ModID"] = $ld[0].modid
                $metadata["Version"] = $ld[0].version; $metadata["Authors"] = ($ld[0].authorList -join ", ")
                $metadata["Loader"] = "Forge (Legacy)"
            }
        }
        # Quilt
        $qm = Join-Path $tempDir "quilt.mod.json"
        if (Test-Path $qm) {
            $qd = Get-Content $qm -Raw | ConvertFrom-Json
            $metadata["Loader"] = "Quilt"
            if ($qd.quilt_loader) { $metadata["ModID"] = $qd.quilt_loader.id; $metadata["Version"] = $qd.quilt_loader.version }
        }

        $classFiles = Get-ChildItem -Path $tempDir -Recurse -Filter "*.class" -ErrorAction SilentlyContinue
        $metadata["ClassCount"] = ($classFiles | Measure-Object).Count
        $nativeFiles = Get-ChildItem -Path $tempDir -Recurse -Include "*.dll","*.so","*.dylib" -ErrorAction SilentlyContinue
        if ($nativeFiles) { $metadata["HasNativeLibs"] = $true; $metadata["NativeLibs"] = ($nativeFiles | ForEach-Object { $_.Name }) -join ", " }
        $exeFiles = Get-ChildItem -Path $tempDir -Recurse -Include "*.exe","*.bat","*.cmd","*.ps1","*.vbs" -ErrorAction SilentlyContinue
        if ($exeFiles) { $metadata["HasExecutables"] = $true; $metadata["ExecFiles"] = ($exeFiles | ForEach-Object { $_.Name }) -join ", " }

        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    } catch { Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
    return $metadata
}

function Test-CheatSignatures {
    param([string]$JarPath)
    $findings = @()
    try {
        $tempDir = Join-Path $env:TEMP "nullmod_scan_$([System.IO.Path]::GetRandomFileName())"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($JarPath, $tempDir)

        $classFiles = Get-ChildItem -Path $tempDir -Recurse -Filter "*.class" -ErrorAction SilentlyContinue
        foreach ($class in $classFiles) {
            $bytes = [System.IO.File]::ReadAllBytes($class.FullName)
            $asciiText = [System.Text.Encoding]::ASCII.GetString($bytes)

            foreach ($sig in $CHEAT_SIGNATURES.Keys) {
                if ($asciiText -match "(?i)$([regex]::Escape($sig))") {
                    $findings += @{ Signature=$sig; Threat=$CHEAT_SIGNATURES[$sig].Threat; Category=$CHEAT_SIGNATURES[$sig].Cat; Desc=$CHEAT_SIGNATURES[$sig].Desc; File=$class.FullName.Replace($tempDir,"") }
                }
            }
            foreach ($ep in $KNOWN_C2_ENDPOINTS) {
                if ($asciiText -match $ep) {
                    $findings += @{ Signature="C2_ENDPOINT"; Threat="CRITICAL"; Category="Command & Control"; Desc="Suspicious endpoint: $ep"; File=$class.FullName.Replace($tempDir,"") }
                }
            }
            foreach ($pkg in $KNOWN_MALICIOUS_PACKAGES) {
                if ($asciiText -match $pkg) {
                    $findings += @{ Signature="MALICIOUS_PKG"; Threat="CRITICAL"; Category="Malware"; Desc="Malicious package: $pkg"; File=$class.FullName.Replace($tempDir,"") }
                }
            }
            # Obfuscation detection
            $obfScore = 0
            if ($asciiText -match "(?i)(procyon|allatori|xflow|zkm|stringer)") { $obfScore += 5 }
            if ($asciiText -match "(?i)(net.sourceforge.procyon|org.objectweb.asm)") { $obfScore += 3 }
            if ($class.Name -match "^[a-zA-Z]{1,2}\d*\.class$") { $obfScore += 1 }
            if ($obfScore -ge 3) {
                $findings += @{ Signature="OBFUSCATION"; Threat=$(if ($obfScore -ge 5){"HIGH"}else{"MEDIUM"}); Category="Obfuscation"; Desc="Suspicious obfuscation (score: $obfScore)"; File=$class.FullName.Replace($tempDir,"") }
            }
        }
        # Nested JARs
        $nestedJars = Get-ChildItem -Path $tempDir -Recurse -Filter "*.jar" -ErrorAction SilentlyContinue
        foreach ($nj in $nestedJars) {
            $findings += @{ Signature="JAR_IN_JAR"; Threat="MEDIUM"; Category="Payload"; Desc="Nested JAR: $($nj.Name)"; File=$nj.FullName.Replace($tempDir,"") }
        }
        # Dangerous resources
        $dangerous = Get-ChildItem -Path $tempDir -Recurse -Include "*.sh","*.bat","*.exe","*.dll","*.so" -ErrorAction SilentlyContinue
        foreach ($d in $dangerous) {
            $findings += @{ Signature="DANGEROUS_RESOURCE"; Threat="HIGH"; Category="Suspicious File"; Desc="Dangerous file: $($d.Name)"; File=$d.FullName.Replace($tempDir,"") }
        }
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    } catch { Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
    return $findings
}

function Get-SystemInfo {
    $info = @{ Hostname=$env:COMPUTERNAME; Username=$env:USERNAME; OS=(Get-CimInstance Win32_OperatingSystem).Caption; Launcher="Unknown"; JavaVer="" }
    $launchers = @(
        @{P="$env:APPDATA\.minecraft";N="Vanilla/Forge"}, @{P="$env:APPDATA\Badlion Client";N="Badlion"},
        @{P="$env:APPDATA\LunarClient";N="Lunar"}, @{P="$env:APPDATA\Feather Client";N="Feather"},
        @{P="$env:LOCALAPPDATA\PrismLauncher";N="Prism"}, @{P="$env:APPDATA\.technic";N="Technic"}
    )
    foreach ($l in $launchers) { if (Test-Path $l.P) { $info["Launcher"]=$l.N; break } }
    try { $jv = & java -version 2>&1 | Select-String "version" | Select-Object -First 1; $info["JavaVer"]=$jv.ToString().Trim() } catch { $info["JavaVer"]="Not found" }
    return $info
}

# ================================================================
# MAIN ANALYSIS ENGINE
# ================================================================

function Start-Analysis {
    param([string]$TargetPath, [string]$SystemMinecraftDir)

    $results = @{ Timestamp=Get-Date -Format "yyyy-MM-dd HH:mm:ss"; SystemInfo=@{}; ModsScanned=0; Threats=@(); Clean=@(); Warnings=@() }

    # PHASE 1: System Detection
    Write-Threat "HEADER" "PHASE 1: System Detection"
    $results.SystemInfo = Get-SystemInfo
    Write-Threat "INFO" "Hostname: $($results.SystemInfo.Hostname)"
    Write-Threat "INFO" "User:     $($results.SystemInfo.Username)"
    Write-Threat "INFO" "OS:       $($results.SystemInfo.OS)"
    Write-Threat "INFO" "Launcher: $($results.SystemInfo.Launcher)"
    Write-Threat "INFO" "Java:     $($results.SystemInfo.JavaVer)"
    Write-Host ""

    # PHASE 2: Directory Discovery
    Write-Threat "HEADER" "PHASE 2: Mod Directory Discovery"
    $searchPaths = @()
    if ($TargetPath -and (Test-Path $TargetPath)) { $searchPaths += $TargetPath }
    if ($SystemMinecraftDir -and (Test-Path $SystemMinecraftDir)) { $searchPaths += $SystemMinecraftDir }
    # Only auto-detect if user did NOT provide a path
    if ($searchPaths.Count -eq 0) {
        $autoPaths = @("$env:APPDATA\.minecraft","$env:APPDATA\.fabric","$env:APPDATA\.quilt","$env:APPDATA\Badlion Client","$env:APPDATA\LunarClient","$env:APPDATA\Feather Client")
        foreach ($ap in $autoPaths) { if (Test-Path $ap) { Write-Threat "OK" "Auto-detected: $ap"; $searchPaths += $ap } }
    }
    if ($searchPaths.Count -eq 0) {
        Write-Threat "HIGH" "No Minecraft directory found!"
        Write-Host "`n  Usage:" -ForegroundColor Yellow
        Write-Host "    .\NullModAnalyzer.ps1 -ModPath 'C:\path\to\mods'" -ForegroundColor White
        Write-Host "    .\NullModAnalyzer.ps1 -MinecraftDir 'C:\Users\You\.minecraft'" -ForegroundColor White
        Write-Host "    .\NullModAnalyzer.ps1 -Interactive`n" -ForegroundColor White
        return $results
    }

    # PHASE 3: Collect Mods
    Write-Threat "HEADER" "PHASE 3: Mod Collection"
    $allMods = @()
    foreach ($sp in $searchPaths) { $allMods += Get-ChildItem -Path $sp -Recurse -Filter "*.jar" -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 1024 } }
    $allMods = $allMods | Sort-Object FullName -Unique
    if ($allMods.Count -eq 0) { Write-Threat "INFO" "No mod JARs found."; return $results }
    Write-Threat "OK" "Found $($allMods.Count) mod(s) to analyze"
    $results.ModsScanned = $allMods.Count
    Write-Host ""

    # PHASE 4: Metadata Extraction
    Write-Threat "HEADER" "PHASE 4: Metadata Extraction"
    $modMeta = @{}
    $i = 0
    foreach ($mod in $allMods) {
        $i++
        $md = Get-ModMetadata -JarPath $mod.FullName
        $modMeta[$mod.Name] = $md
        $dn = if ($md["ModName"]) { $md["ModName"] } else { $mod.Name }
        $loader = if ($md["Loader"]) { " [$($md['Loader'])]" } else { "" }
        $ver = if ($md["Version"]) { " v$($md['Version'])" } else { "" }
        Write-Threat "INFO" "[$i/$($allMods.Count)] $dn$ver$loader"
        if ($md["HasNativeLibs"]) { Write-Threat "MEDIUM" "  >> Native libs: $($md['NativeLibs'])" }
        if ($md["HasExecutables"]) { Write-Threat "CRITICAL" "  >> EXECUTABLES: $($md['ExecFiles'])" }
    }
    Write-Host ""

    # PHASE 5: Cheat Signature Scan
    Write-Threat "HEADER" "PHASE 5: Cheat Signature Scan"
    $i = 0
    foreach ($mod in $allMods) {
        $i++
        Write-Threat "SCAN" "[$i/$($allMods.Count)] Scanning $($mod.Name)..."
        $findings = Test-CheatSignatures -JarPath $mod.FullName
        if ($findings.Count -gt 0) {
            foreach ($f in $findings) {
                $results.Threats += @{ Mod=$mod.Name; Threat=$f["Threat"]; Category=$f["Category"]; Detail="$($f['Signature']) - $($f['Desc'])"; File=$f["File"] }
                Write-Threat $f["Threat"] "  >> $($f['Signature']) [$($f['Category'])] $($f['Desc'])"
            }
        } else { $results.Clean += $mod.Name; Write-Threat "OK" "  >> Clean" }
    }
    Write-Host ""

    # PHASE 6: Known Cheat Client Detection
    Write-Threat "HEADER" "PHASE 6: Cheat Client Name Detection"
    foreach ($mod in $allMods) {
        $modLower = $mod.Name.ToLower()
        foreach ($client in $KNOWN_CHEAT_CLIENTS) {
            if ($modLower -match $client) {
                Write-Threat "CRITICAL" "Known cheat client: $($mod.Name) (matches: $client)"
                $results.Threats += @{ Mod=$mod.Name; Threat="CRITICAL"; Category="Cheat Client"; Detail="Matches: $client"; File=$mod.Name }
                break
            }
        }
    }
    Write-Host ""

    # PHASE 7: File Integrity
    Write-Threat "HEADER" "PHASE 7: File Integrity & Hash Analysis"
    foreach ($mod in $allMods) {
        $sizeMB = [math]::Round($mod.Length / 1MB, 2)
        if ($sizeMB -gt 50) { Write-Threat "MEDIUM" "Large mod: $($mod.Name) ($sizeMB MB)"; $results.Warnings += "Large: $($mod.Name)" }
        if ($sizeMB -lt 0.01) { Write-Threat "LOW" "Tiny mod: $($mod.Name) ($sizeMB MB)" }
        $hash = (Get-FileHash -Path $mod.FullName -Algorithm SHA256).Hash
        Write-Threat "INFO" "  $($mod.Name): SHA256=$hash"
    }
    Write-Host ""

    # PHASE 8: Network Analysis
    Write-Threat "HEADER" "PHASE 8: Network Endpoint Analysis"
    foreach ($mod in $allMods) {
        try {
            $tempDir = Join-Path $env:TEMP "nullmod_net_$([System.IO.Path]::GetRandomFileName())"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($mod.FullName, $tempDir)
            $classes = Get-ChildItem -Path $tempDir -Recurse -Filter "*.class" -ErrorAction SilentlyContinue
            foreach ($c in $classes) {
                $bytes = [System.IO.File]::ReadAllBytes($c.FullName)
                $text = [System.Text.Encoding]::ASCII.GetString($bytes)
                if ($text -match '(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})') {
                    $ip = $Matches[1]
                    if ($ip -notmatch "^(0\.0\.0\.0|127\.0\.0\.1|255\.255\.255\.255|192\.168\.|10\.)") {
                        Write-Threat "HIGH" "Hardcoded IP in $($mod.Name): $ip"
                        $results.Threats += @{ Mod=$mod.Name; Threat="HIGH"; Category="Network"; Detail="Hardcoded IP: $ip"; File=$c.FullName.Replace($tempDir,"") }
                    }
                }
                if ($text -match '(https?://[^\s\x00-\x1F]{5,})') {
                    $url = $Matches[1]
                    foreach ($ep in $KNOWN_C2_ENDPOINTS) {
                        if ($url -match $ep) {
                            Write-Threat "CRITICAL" "C2 URL in $($mod.Name): $url"
                            $results.Threats += @{ Mod=$mod.Name; Threat="CRITICAL"; Category="C2"; Detail="C2 URL: $url"; File=$c.FullName.Replace($tempDir,"") }
                        }
                    }
                }
            }
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        } catch { Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
    Write-Threat "OK" "Network analysis complete"
    Write-Host ""

    # PHASE 9: Summary
    Write-Threat "HEADER" "=============================================="
    Write-Threat "HEADER" "ANALYSIS COMPLETE"
    Write-Threat "HEADER" "=============================================="

    $crit = ($results.Threats | Where-Object { $_.Threat -eq "CRITICAL" } | Measure-Object).Count
    $high = ($results.Threats | Where-Object { $_.Threat -eq "HIGH" } | Measure-Object).Count
    $med  = ($results.Threats | Where-Object { $_.Threat -eq "MEDIUM" } | Measure-Object).Count
    $low  = ($results.Threats | Where-Object { $_.Threat -eq "LOW" } | Measure-Object).Count
    $total = $crit + $high + $med + $low

    $overall = "CLEAN"
    if ($crit -gt 0) { $overall = "CRITICAL - CHEAT/MALWARE DETECTED" }
    elseif ($high -gt 0) { $overall = "HIGH - SUSPICIOUS MODS FOUND" }
    elseif ($med -gt 0) { $overall = "MEDIUM - WARNINGS" }
    elseif ($low -gt 0) { $overall = "LOW - MINOR ISSUES" }

    $bc = if ($crit -gt 0) { "Red" } elseif ($high -gt 0) { "Yellow" } else { "Green" }
    Write-Host ""
    Write-Host "    +=====================================================+" -ForegroundColor $bc
    Write-Host "    |       NULL'S MOD ANALYZER - SCAN RESULTS            |" -ForegroundColor White
    Write-Host "    +=====================================================+" -ForegroundColor $bc
    Write-Host "    |  Mods Scanned:    $($results.ModsScanned.ToString().PadLeft(5))                            |" -ForegroundColor White
    Write-Host "    |  Clean:           $($results.Clean.Count.ToString().PadLeft(5))                            |" -ForegroundColor Green
    Write-Host "    |  Threats Found:   $($total.ToString().PadLeft(5))                            |" -ForegroundColor $(if($total -gt 0){"Red"}else{"Green"})
    Write-Host "    +-----------------------------------------------------+" -ForegroundColor White
    Write-Host "    |  [!!!] Critical:  $($crit.ToString().PadLeft(5))                            |" -ForegroundColor $(if($crit -gt 0){"Red"}else{"Green"})
    Write-Host "    |  [!!]  High:      $($high.ToString().PadLeft(5))                            |" -ForegroundColor $(if($high -gt 0){"Red"}else{"Green"})
    Write-Host "    |  [!]   Medium:    $($med.ToString().PadLeft(5))                            |" -ForegroundColor $(if($med -gt 0){"Yellow"}else{"Green"})
    Write-Host "    |  [~]   Low:       $($low.ToString().PadLeft(5))                            |" -ForegroundColor $(if($low -gt 0){"DarkYellow"}else{"Green"})
    Write-Host "    +=====================================================+" -ForegroundColor $bc
    $tc = if ($overall -match "CRITICAL") {"Red"} elseif ($overall -match "HIGH") {"Yellow"} elseif ($overall -match "MEDIUM") {"DarkYellow"} else {"Green"}
    Write-Host "    |  VERDICT: $($overall.PadRight(44)) |" -ForegroundColor $tc
    Write-Host "    +=====================================================+" -ForegroundColor $bc
    Write-Host ""

    if ($results.Threats.Count -gt 0) {
        Write-Host "    +-----------------------------------------------------+" -ForegroundColor Red
        Write-Host "    |           DETAILED THREAT REPORT                     |" -ForegroundColor Red
        Write-Host "    +-----------------------------------------------------+" -ForegroundColor Red
        $sorted = $results.Threats | Sort-Object @{Expression={switch($_.Threat){"CRITICAL"{0}"HIGH"{1}"MEDIUM"{2}"LOW"{3}default{4}}}}
        foreach ($t in $sorted) {
            $color = Get-ThreatColor $t.Threat
            Write-Host "    [$($t.Threat.PadRight(8))]" -ForegroundColor $color -NoNewline
            Write-Host " $($t.Mod)" -ForegroundColor White -NoNewline
            Write-Host " -> $($t.Detail)" -ForegroundColor Gray
        }
        Write-Host ""
    }

    # JSON Export
    if ($ExportJSON -or $ReportPath) {
        $jsonPath = if ($ReportPath) { $ReportPath } else { Join-Path $PSScriptRoot "NullModAnalyzer_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json" }
        $report = @{ scanner="Null's Mod Analyzer v1.0"; timestamp=$results.Timestamp; systemInfo=$results.SystemInfo; overallThreat=$overall; summary=@{ modsScanned=$results.ModsScanned; critical=$crit; high=$high; medium=$med; low=$low; clean=$results.Clean.Count; totalIssues=$total }; threats=$results.Threats; clean=$results.Clean; warnings=$results.Warnings }
        $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonPath -Encoding UTF8
        Write-Threat "OK" "Report saved: $jsonPath"
    }
    return $results
}

# ================================================================
# INTERACTIVE MODE
# ================================================================

function Start-InteractiveMode {
    Write-Host $BANNER -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    =======================================================" -ForegroundColor Cyan
    Write-Host "    Interactive Mode - Select analysis type" -ForegroundColor Cyan
    Write-Host "    =======================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    [1] Full System Scan (auto-detect)" -ForegroundColor White
    Write-Host "    [2] Scan specific .jar file" -ForegroundColor White
    Write-Host "    [3] Scan mods folder" -ForegroundColor White
    Write-Host "    [4] Scan Minecraft installation" -ForegroundColor White
    Write-Host "    [5] Scan + Export JSON report" -ForegroundColor White
    Write-Host "    [6] Exit" -ForegroundColor DarkGray
    Write-Host ""
    $choice = Read-Host "    Select [1-6]"
    switch ($choice) {
        "1" { Start-Analysis }
        "2" { $j = Read-Host "    .jar path"; if (Test-Path $j) { Start-Analysis -TargetPath (Split-Path $j) } }
        "3" { $d = Read-Host "    Mods folder"; if (Test-Path $d) { Start-Analysis -TargetPath $d } }
        "4" { $m = Read-Host "    .minecraft path"; if (Test-Path $m) { Start-Analysis -SystemMinecraftDir $m } }
        "5" { $d = Read-Host "    Mods folder"; if (Test-Path $d) { Start-Analysis -TargetPath $d -ExportJSON } }
        "6" { Write-Host "    Goodbye!" -ForegroundColor DarkGray }
    }
}

# ================================================================
# ENTRY POINT
# ================================================================

Write-Host $BANNER -ForegroundColor Cyan
Write-Host ""

if ($ModPath -or $MinecraftDir) {
    Start-Analysis -TargetPath $ModPath -SystemMinecraftDir $MinecraftDir
} else {
    Write-Host "    Enter the directory to scan:" -ForegroundColor Cyan
    Write-Host "    (e.g. C:\Users\YOU\AppData\Roaming\.minecraft\mods)" -ForegroundColor DarkGray
    Write-Host ""
    $scanPath = Read-Host "    Path"
    if ($scanPath -and (Test-Path $scanPath)) {
        Start-Analysis -TargetPath $scanPath
    } elseif ($scanPath) {
        Write-Threat "CRITICAL" "Path not found: $scanPath"
    } else {
        Write-Threat "HIGH" "No path entered."
    }
}
