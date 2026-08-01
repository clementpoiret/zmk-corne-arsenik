# ZMK Corne Arsenik

ZMK firmware for a wireless Corne split keyboard built around nice!nano v2
controllers and nice!view displays. The configuration provides a QWERTY base,
translated by Linux XKB Ergo-L, eight home-row mods, a shared six-layer
architecture, mouse controls, media keys, and guarded Bluetooth profile
management.

## Hardware and firmware

- Board: `nice_nano_v2`
- Shields: `corne_left` and `corne_right`
- Displays: `nice_view_adapter` with `nice_view`
- Firmware: ZMK `v0.3.0`

Display support, pointing behaviors, and deep sleep are enabled in
[`config/corne.conf`](config/corne.conf). RGB underglow is available there as a
commented-out option.

## Keymap

The full keymap is defined in
[`config/corne.keymap`](config/corne.keymap). Base keys emit positional QWERTY
usages; Linux XKB Ergo-L produces the semantic characters:

```text
 Q       W       E        R       T      | Y       U        I        O       P
 A/GUI   S/Alt   D/Shift  F/Ctrl  G      | H       J/Ctrl   K/Shift  L/Alt   ;/GUI
 Z       X       C        V       B      | N       M        ,        .       /
             Esc/NAV  Space/FUNCTION  Tab/MOUSE | Enter/NUM_EDIT  Backspace  RAlt
```

The home-row keys become modifiers when held:

| Key | A | S | D | F | J | K | L | ; |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Hold | GUI | Alt | Shift | Ctrl | Ctrl | Shift | Alt | GUI |

Layer access is momentary: hold the listed thumb key to use a layer, then
release it to return. `NUM_EDIT` is directly available from Enter. To reach
`SYSTEM`, hold Space for `FUNCTION`, then hold the right outer thumb.

| Layer | Access | Purpose |
| --- | --- | --- |
| 0 — BASE | Default | Positional QWERTY, home-row mods, and thumb tap-holds |
| 1 — NAV | Hold Escape | Navigation, browser controls, editing shortcuts, and scrolling |
| 2 — NUM_EDIT | Hold Enter, or use `NUM_EDIT` from NAV | Digits, arithmetic, punctuation, navigation, and word editing |
| 3 — FUNCTION | Hold Space, or use `FUNCTION` from NAV | Function keys, media controls, brightness, and modifiers |
| 4 — MOUSE | Hold Tab | Pointer movement, scrolling, and mouse buttons |
| 5 — SYSTEM | From FUNCTION, hold the right outer thumb | Bluetooth profile selection and clearing |

Programming symbols use native Ergo-L AltGr through the plain right-Alt thumb.
The left outer thumb on `FUNCTION` provides sticky AltGr; its right outer thumb
opens `SYSTEM`:

```text
StickyAltGr  Space  transparent | transparent  Backspace  SYSTEM
```

`NUM_EDIT` is shared with the Cheapino:

```text
 =       Home       Up          End         PgUp       | /   7   8   9   *
 +       Left       Down        Right       PgDn       | -   4   5   6   0
 ODK     Ctrl+Left  Ctrl+Bsp    Ctrl+Del    Ctrl+Right | ,   1   2   3   .
                         Tab  Backspace  Enter         | held  x  x
```

`ODK` emits Ergo-L's host-native one-dead-key position. Follow it with digits
1–5 for `„`, `“`, `”`, `¢`, and `‰` respectively. Backspace is plain and
repeatable; Bluetooth is available only on `SYSTEM`. Existing HRM and remaining
thumb hold-tap timing is unchanged in this phase.

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
| `config/corne.keymap` | Layers, bindings, hold-taps, and Ergo-L semantic behavior |
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
