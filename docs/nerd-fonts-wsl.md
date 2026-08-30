# Nerd Fonts on WSL (omp + yazi glyphs)

How the **Agave Nerd Font** is installed and wired up so the `omp` coding agent
and `yazi` file manager render their icons/glyphs correctly on this WSL2 box.

## The key gotcha

WSL has **two** font surfaces, and they are independent:

| Surface | Rendered by | Font source |
|---|---|---|
| Windows Terminal (what you actually look at) | Windows | Windows-installed fonts |
| WSLg GUI apps + anything using `fontconfig` | Linux | `~/.local/share/fonts` |

`omp` and `yazi` are TUIs — their glyphs are drawn by **Windows Terminal**, so a
Linux-side font install alone does **nothing** for them. The Windows Terminal
profile font must also be a Nerd Font. Setup is therefore two-part.

## Part 1 — Linux side (chezmoi-managed, reproducible)

Declared in `brew/linux/dot_Brewfile-wsl.tmpl` (the WSL superset Brewfile):

```ruby
cask "font-agave-nerd-font"
```

Homebrew on Linux (6.x) supports font casks and installs the TTFs into
`~/.local/share/fonts/`, registering them with `fontconfig`. This is picked up
automatically by the bootstrap (`scripts/run_10_homebrew` runs `brew bundle`), so
it reproduces with no manual step. Covers WSLg GUI apps and fontconfig consumers.

Manual equivalent:

```sh
brew install --cask font-agave-nerd-font
fc-list | grep -i agave   # verify
```

## Part 2 — Windows side (per-machine, NOT chezmoi-managed)

chezmoi targets `~/` on Linux; the Windows font store and the Windows Terminal
settings live outside its scope, so this part is manual per Windows machine.

### 2a. Install the fonts on Windows (per-user, no admin)

The TTFs already exist in the WSL brew dir. Stage them somewhere Windows can read
and register them under `HKCU` (per-user, no elevation):

```powershell
# Run in PowerShell. Assumes the TTFs were copied to %LOCALAPPDATA%\Temp\agave-nf
Add-Type -AssemblyName System.Drawing
$src = "$env:LOCALAPPDATA\Temp\agave-nf"
$dst = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$reg = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
Get-ChildItem "$src\*.ttf" | ForEach-Object {
    $target = Join-Path $dst $_.Name
    Copy-Item $_.FullName $target -Force
    $fc = New-Object System.Drawing.Text.PrivateFontCollection
    $fc.AddFontFile($_.FullName); $family = $fc.Families[0].Name; $fc.Dispose()
    $style = if ($_.Name -match "Bold") { " Bold" } else { "" }
    New-ItemProperty -Path $reg -Name "$family$style (TrueType)" -Value $target -PropertyType String -Force | Out-Null
}
```

To stage the TTFs from WSL first:

```sh
mkdir -p "/mnt/c/Users/<WINUSER>/AppData/Local/Temp/agave-nf"
cp ~/.local/share/fonts/AgaveNerdFont*.ttf "/mnt/c/Users/<WINUSER>/AppData/Local/Temp/agave-nf/"
```

(Alternatively: open the `.ttf` files in Windows Explorer and click **Install**.)

Verify Windows sees the family:

```powershell
Add-Type -AssemblyName System.Drawing
(New-Object System.Drawing.Text.InstalledFontCollection).Families |
  Where-Object { $_.Name -like '*Agave*' } | ForEach-Object { $_.Name }
# -> Agave Nerd Font / Agave Nerd Font Mono / Agave Nerd Font Propo
```

### 2b. Point Windows Terminal at the font

In Windows Terminal `settings.json` (Settings → JSON), set the default font for
all profiles under `profiles.defaults`:

```json
"profiles": {
    "defaults": {
        "font": {
            "face": "Agave Nerd Font Mono"
        }
    }
}
```

Use the **Mono** variant for terminals (fixed-advance glyphs; `Propo` and the
plain family have variable-width icons that misalign in a grid). **Restart
Windows Terminal** — already-open tabs keep the old font.

## Verify

Restart Windows Terminal, then in the WSL shell run `yazi` (directory/file icons)
and `omp` (its TUI glyphs). Both should show icons instead of tofu boxes (□).

## Why not automate Part 2 with chezmoi?

chezmoi manages `~/` on the Linux side only. The Windows per-user font store
(`%LOCALAPPDATA%\Microsoft\Windows\Fonts` + `HKCU` registry) and Windows Terminal
`settings.json` are Windows artifacts. Automating them would need a Windows-side
config manager; for a single work box the manual steps above are recorded here
instead. The Linux-side font install (Part 1) is the only piece that reproduces
automatically via `brew bundle`.
