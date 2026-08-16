# Null's Mod Analyzer v1.0
### Minecraft Mod Analysis & Cheat Detection Tool

A PowerShell-based scanner that analyzes Minecraft mods for cheats, malware, and suspicious activity across 80+ signatures.

## Quick Run (One-Liner)
```powershell
irm https://raw.githubusercontent.com/YOUR_USERNAME/NullModAnalyzer/main/NullModAnalyzer.ps1 -OutFile NullModAnalyzer.ps1; .\NullModAnalyzer.ps1 -Interactive
```

## Usage
| Command | Description |
|---------|-------------|
| `.\NullModAnalyzer.ps1` | Auto-detect and scan |
| `.\NullModAnalyzer.ps1 -Interactive` | Interactive menu |
| `.\NullModAnalyzer.ps1 -ModPath 'C:\path\to\mods'` | Scan specific folder |
| `.\NullModAnalyzer.ps1 -MinecraftDir 'C:\.minecraft'` | Scan MC install |
| `.\NullModAnalyzer.ps1 -ExportJSON` | Export JSON report |

## What It Scans (9 Phases)
1. System Detection - Hostname, OS, launcher
2. Directory Discovery - Auto-finds Minecraft folders
3. Mod Collection - Gathers all jar mod files
4. Metadata Extraction - Reads mod metadata
5. Cheat Signature Scan - 80+ cheat signatures
6. Cheat Client Detection - 35+ known clients
7. File Integrity - SHA256 hashing, executable detection
8. Network Analysis - C2 endpoints, hardcoded IPs
9. Summary Report - Color-coded threat breakdown

## Requirements
- Windows PowerShell 5.1+
- Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` if scripts are blocked
