# ZMK Corne Arsenik

ZMK firmware for a wireless Corne split keyboard built around nice!nano v2
controllers and nice!view displays. The configuration provides a QWERTY base,
home-row mods, navigation and number layers, mouse controls, media keys,
Bluetooth profile management, and Linux Unicode input.

## Hardware and firmware

- Board: `nice_nano_v2`
- Shields: `corne_left` and `corne_right`
- Displays: `nice_view_adapter` with `nice_view`
- Firmware: ZMK `v0.3.0`
- Extra module: `zmk-unicode` `v0.3.0`

Display support, pointing behaviors, and deep sleep are enabled in
[`config/corne.conf`](config/corne.conf). RGB underglow is available there as a
commented-out option.

## Keymap

The full keymap is defined in
[`config/corne.keymap`](config/corne.keymap). The base layer is:

```text
 TAB    Q    W    E    R    T   |   Y    U    I    O    P   BSPC
 ESC    A    S    D    F    G   |   H    J    K    L    ;   ENTER
SHIFT   Z    X    C    V    B   |   N    M    ,    .    /   SHIFT
              ESC  SPACE  TAB   | ENTER  BSPC  RALT
```

The home-row keys become modifiers when held:

| Key | A | S | D | F | J | K | L | ; |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Hold | GUI | Alt | Shift | Ctrl | Ctrl | Shift | Alt | Ctrl |

Layer access is momentary: hold the listed thumb key to use a layer, then
release it to return to the previous layer. The two symbol/number layers are
nested as shown below.

| Layer | Hold | Purpose |
| --- | --- | --- |
| 0 — Base | — | QWERTY typing and home-row mods |
| 1 — Lafayette | A `SYM` thumb on the function layer | Programming symbols |
| 2 — Number row | A `NUM` thumb on the Lafayette layer | Numbers and Unicode punctuation |
| 3 — Vim navigation | `Esc` | Arrows, paging, browser navigation, shortcuts, and scrolling |
| 4 — Number navigation | `Enter` | Numpad plus left-hand navigation and editing shortcuts |
| 5 — Function pad | `Space` | Function keys, media controls, brightness, and modifiers |
| 6 — Mouse pad | `Tab` | Pointer movement, scrolling, and mouse buttons |
| 7 — Bluetooth | `Backspace` | Select, cycle, or clear Bluetooth profiles |

`Esc`, `Space`, `Tab`, `Enter`, and `Backspace` still send their normal keycode
when tapped. Hold-tap timing and opposite-hand activation rules are configured
alongside the layers in the keymap.

## Build

Install [Nix](https://nixos.org/download/) with flakes enabled, then run:

```sh
nix build
```

The build produces both halves under `result/`:

```text
result/zmk_left.uf2
result/zmk_right.uf2
```

To run the same evaluation check used by CI:

```sh
nix flake check
```

## Flash

On Linux, the included helper builds the firmware, prompts for each half, waits
for its UF2 bootloader, and copies the matching image:

```sh
nix run .#flash
```

To flash manually:

1. Connect one keyboard half over USB and double-tap its reset button.
2. Copy `result/zmk_left.uf2` or `result/zmk_right.uf2` to the mounted UF2
   bootloader volume.
3. Wait for the controller to reboot, then repeat for the other half.

Make sure the firmware filename matches the half being flashed.

## Development

Enter the supplied development shell with:

```sh
nix develop
```

The main files are:

| Path | Purpose |
| --- | --- |
| `config/corne.keymap` | Layers, bindings, hold-taps, and Unicode behavior |
| `config/corne.conf` | ZMK feature flags |
| `config/west.yml` | Pinned ZMK and module revisions |
| `flake.nix` | Reproducible firmware, flash, and update packages |
| `build.yaml` | Left/right build matrix for the standard ZMK workflow |

After changing the keymap or configuration, run `nix flake check` followed by
`nix build`.

To update the pinned West dependencies and their Nix hash:

```sh
nix run .#update
```

Review the resulting changes to `config/west.yml` and `flake.nix`, then rebuild
both halves. GitHub Actions also checks pull requests and pushes to `main`,
uploads the firmware as the `zmk_firmware` artifact, and opens scheduled
dependency-update pull requests.
