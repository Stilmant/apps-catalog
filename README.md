# apps-catalog

Winget catalogs + PowerShell scripts to bootstrap a Windows 11 machine (including notes specific to the GPD Pocket 4).

The goals are:
- Make installs reproducible (catalogs are versioned).
- Keep everything inspectable (no magic “one-click repair”).
- Prefer safe, idempotent operations (re-running should be fine).

---

## What this repo does

This repository provides:
- Winget import catalogs (JSON) to install apps in logical groups.
- A convenience script that imports all catalogs in a fixed order.
- A script to install a PowerShell profile (Oh My Posh + shell preferences), with explicit conflict handling.

Repository layout:

```text
apps-catalog\
   scripts\
      install-all.ps1
      install-profile.ps1
   winget-apps-catalogs\
      _notes\
         not-winget-installable.md
      base.json
      dev.json
      tools.json
      apps.json
      hardware.json
   powershell\
      profile\Microsoft.PowerShell_profile.ps1
      oh-my-posh\upstream\
```

Catalog intent (high-level):
- `base.json`: minimal essentials (browser, unzip tools, terminal basics).
- `dev.json`: development environment.
- `tools.json`: favorite utilities.
- `apps.json`: general applications (creativity, multimedia, communication).
- `hardware.json`: drivers and OEM utilities (best-effort; many OEM drivers/apps still come from Windows Update or vendor installers).

Note: GPD does not provide an official winget package feed. Chipset/NPU drivers typically come via Windows Update.

Notes:
- `winget-apps-catalogs\_notes` is documentation/scratchpad content and is not used by any scripts.

---

## How to use

### Prerequisites

- Windows 11
- Winget available (`winget --version`)
- PowerShell (PowerShell 7+ recommended)

### Install everything (recommended)

Run in an elevated PowerShell (Administrator) from the repo root:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\install-all.ps1
```

What happens:
- Catalogs are imported in this order: base → dev → tools → apps → hardware
- Apps already installed are skipped by winget

### Install a single catalog

```powershell
winget import .\winget-apps-catalogs\base.json --disable-interactivity
```

### Install the PowerShell profile (Oh My Posh setup)

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\install-profile.ps1
```

Expected impact:
- If no profile exists yet, it copies the reference profile into your PowerShell profile location.
- If a profile already exists, it will not auto-merge; it will ask what to do (overwrite/keep/diff).

---

## Common problems

### 1) Execution policy prevents scripts from running

If PowerShell reports scripts are disabled, run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### 2) Winget import error: source not installed

If winget reports:

```text
Source required for import is not installed: winget
```

One common cause is running the import from a cloud-synced folder (e.g. OneDrive). Winget import can be unreliable with cloud file providers.

Fix:
- Clone/move this repo outside OneDrive, e.g. `C:\Users\Michael\Projects\apps-catalog`
- Re-run `.\scripts\install-all.ps1`

---

## Concepts and philosophy (project documentation)

This section keeps the “why” and the operational notes that influenced the scripts and catalogs.

### Why winget catalogs

- Catalogs are explicit and reviewable: you can see exactly what will be installed.
- They can be evolved gradually as your setup changes.
- The workflow is deterministic: same repo state ⇒ same intended app set.

### OEM apps vs Windows apps (GPD Pocket 4 notes)

When you export winget packages, Windows may include:
- Microsoft inbox apps (part of Windows / Store defaults)
- OEM-installed tools (GPD/AMD/Realtek/etc.)
- Apps installed later by the user

To identify “true OEM” apps:
1. Export immediately after unboxing.
2. Compare with a clean Windows 11 baseline.
3. Document only non-Microsoft vendor apps when the intent is OEM reconstruction.

#### Examples (not exhaustive)

Windows 11 preinstalled / inbox examples:
- Outlook (new)
- Microsoft Teams (Personal)
- OneDrive
- Microsoft Store
- Edge
- Windows Terminal

OEM / vendor examples seen on some GPD Pocket 4 units:
- AMD Software: Adrenalin Edition
- AMD Bug Report Tool
- Realtek Audio Console
- Motion Assistant

#### Observed OEM app groups (reference)

This is kept as a notes section for documentation/triage. It is not guaranteed that these can (or should) be installed via winget.

- AMD drivers & tools
   - AMD Software: Adrenalin Edition
   - AMD Bug Report Tool
   - AMD Install Manager
   - AMD Software
- OEM-licensed audio components
   - Rapture3D Speaker Layout
   - Rapture3D User Guide
   - DTS Sound Unbound
   - DTS:X Ultra
- HID / gamepad drivers & utilities
   - ViGEmBus
   - HidHide Configuration Client
- Motion / sensors
   - Motion Assistant
- Audio
   - Realtek Audio Console

### AMD Software incompatibility warning (Adrenalin)

Some units show an “AMD Software: Adrenalin Edition” warning after a fresh install.

Why it happens:
- Windows Update installs a WHQL GPU driver.
- The preinstalled Adrenalin control panel expects an exact driver match.
- When versions diverge, the control panel may refuse to launch.

Impact:
- The GPU works normally.
- Only advanced Adrenalin features are unavailable (tuning/overlays).

Recommended action (for development/productivity, not gaming tuning):
- Uninstall “AMD Software: Adrenalin Edition”.
- Keep the Windows-provided GPU driver.

### PowerShell profile installation philosophy

The profile installer is intentionally conservative:
- No silent fixes
- No hidden side effects
- No automatic merge

Prerequisites are enforced:
- PowerShell must be installed and started at least once
- The PowerShell profile folder must already exist

Notes:
- Fonts required by Oh My Posh (e.g. Nerd Fonts) must be installed separately.
- PSReadLine history is not migrated by this repo.

#### Font setup for Oh My Posh (one-time manual step)

Oh My Posh relies on Nerd Fonts to render icons and separators correctly.
While fonts can be installed programmatically, **terminal font selection is intentionally not automated**.

Why fonts cannot be auto-configured:
- PowerShell is not the terminal host (it runs inside Windows Terminal, ConHost, etc.)
- Windows Terminal settings are user-owned JSON files
- Admin and user profiles differ
- Automatic modification would be unsafe and brittle

This setup follows a clear separation:
- Shell behavior (profile, prompt) is automated and reproducible
- UI capabilities (fonts) require explicit user confirmation

**Installing the font** (programmatic, one-time):

```powershell
oh-my-posh font install Meslo
```

**Selecting the font in Windows Terminal** (manual, one-time per profile):

1. Open Windows Terminal
2. Settings (Ctrl+,)
3. Profiles → PowerShell
4. Appearance → Font face
5. Select: **MesloLGS NF**
6. Repeat for "PowerShell (Admin)" if you use it
7. Restart Terminal

**Which font to choose (recommended):**

👉 **MesloLGS NF**

This is the correct and canonical choice for Oh My Posh.

**What the font names mean** (so you can ignore the rest):

- **LGS / LGM**: Variants of Meslo tuned for different spacing. Both work, LGS is the usual reference.
- **Mono**: Fixed-width. This is what you want in a terminal.
- **Propo**: Proportional spacing. Do not use in terminals.
- **DZ / SDZ / MDZ**: Internal Nerd Font variants. You can ignore them.

If you see multiple "MesloLGS NF" entries, they're all equivalent (regular/bold/italic variants). Pick any.

That's it. The profile will now display Oh My Posh icons correctly.

#### PowerShell profile installer behavior (reference)

This repo treats profile installation as a deliberate, manual migration.

Prerequisites:
- PowerShell installed (PowerShell 7+ recommended)
- PowerShell started at least once (so `$PROFILE` and profile folder exist)

Reference profile source:
- `powershell\profile\Microsoft.PowerShell_profile.ps1`

What `scripts\install-profile.ps1` does:
1. Verifies that `$PROFILE` is defined.
2. Verifies that the destination profile folder exists.
3. Verifies that the source profile file exists.
4. If no destination profile exists: copies it.
5. If a destination profile exists:
   - If identical: exits successfully.
   - If different: prompts for overwrite/keep/diff.

Conflict handling options when profiles differ:
- Overwrite the existing profile
- Keep the existing profile unchanged
- Generate a `profile.diff.txt` file for manual comparison

---

## License

MIT. See [LICENSE](LICENSE).
