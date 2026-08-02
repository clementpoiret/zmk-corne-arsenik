# ZMK Corne Arsenik

ZMK firmware for a wireless Corne split keyboard built around nice!nano v2
controllers and nice!view displays. The configuration provides a QWERTY base,
translated by Linux XKB Ergo-L, eight home-row mods, six shared public layers,
mouse controls, media keys, and guarded Bluetooth profile management. Two
private overlays provide temporary slow and fast pointer speeds without
changing the public layer numbering shared with QMK. The maintenance layer
also provides explicit USB/BLE routing and per-half recovery controls.

The firmware-independent daily behavior is defined in the canonical
[shared behavior specification](docs/shared-behavior.md), with its current
[parity acceptance record](docs/parity-acceptance.md). This README keeps the
Corne-specific build, transport, flashing, and recovery instructions.

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
usages; Linux XKB Ergo-L produces the following semantic characters:

```text
 Q       C       O        P       W      | J       M        D        ODK     Y
 A/GUI   S/Alt   E/Shift  N/Ctrl  F      | L       R/Ctrl   T/Shift  I/Alt   U/GUI
 Z       X       -        V       B      | .       H        G        ,       K
             Esc/NAV  Space/FUNCTION  Tab/MOUSE | Enter/NUM_EDIT  Backspace  RAlt
```

The raw positional QWERTY usages are retained in the keymap and documented in
the shared specification's debugging appendix.

The home-row positions become modifiers when held:

| Raw position | A | S | D | F | J | K | L | ; |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Ergo-L tap | A | S | E | N | R | T | I | U |
| Hold | GUI | Alt | Shift | Ctrl | Ctrl | Shift | Alt | GUI |

The four work layers are available momentarily from their Base thumb. To reach
`SYSTEM`, hold Space for `FUNCTION`, then hold the right outer thumb. From
`SYSTEM`, `NUM_EDIT` and `MOUSE` can also be toggled for sustained work. These
locks have no timeout; tap the locked layer's access thumb to return to Base.

| Layer | Access | Purpose |
| --- | --- | --- |
| 0 — BASE | Default | Positional QWERTY, home-row mods, and thumb tap-holds |
| 1 — NAV | Hold Escape | Navigation, browser controls, editing shortcuts, and Repeat |
| 2 — NUM_EDIT | Hold Enter, or toggle from `SYSTEM` | Digits, arithmetic, punctuation, navigation, and word editing |
| 3 — FUNCTION | Hold Space | Function keys, media, brightness, sticky modifiers, and ASCII Space |
| 4 — MOUSE | Hold Tab, or toggle from `SYSTEM` | Pointer movement, scrolling, buttons, and speed selection |
| 5 — SYSTEM | From FUNCTION, hold the right outer thumb | Output routing, Bluetooth, recovery, Caps Lock, Compose, and guarded layer toggles |

Programming symbols use native Ergo-L AltGr through the plain right-Alt thumb.
`FUNCTION` provides sticky AltGr and Shift; each remains active for the next
key or expires after one second:

```text
StickyAltGr  Space  x | StickyShift  Backspace  SYSTEM
```

Exact `NAV`, `NUM_EDIT`, `FUNCTION`, and `MOUSE` diagrams and their acceptance
criteria are maintained once in the shared behavior specification. On the
Corne, Slow and Fast temporarily activate transparent private overlays with
movement/scroll values of 200/4 and 1200/20; normal mode retains ZMK defaults.

### SYSTEM

```text
 BT1    BT2    BT3     BT4  BT5 | USB   BLE   Toggle  CapsLock  Compose
 Clear  x      x       x    x   | Num   Prev  Next    x         Mouse
 ALL+   ResetL BootL   x    x   | x     x     BootR   ResetR    +ALL
                    x  x  x      | x  x  x
```

`Compose` sends the Application/Menu key. On Linux XKB, configure
`compose:menu` so that key starts a Compose sequence. `NumEditLock` and
`MouseLock` toggle their layers with no idle timeout; use the access thumb
shown on the locked layer to unlock it. `USB`, `BLE`, and `Toggle` select the
output explicitly, including charging over USB while continuing to type over
BLE. `Clear` forgets only the current Bluetooth profile. To clear every
profile, press the two outer `ALL` keys together within 100 ms; remove the old
host bond and pair the keyboard again afterward. The reset and bootloader keys
act on the physical half where they are pressed.

The nice!view display uses a name for every public and private layer: Base,
Nav, Num/Edit, Function, Mouse, System, Mouse Slow, and Mouse Fast.

## Tap-hold implementation

The shared specification owns the observable timing contract. In ZMK, separate
`hml`/`hmr`, `tl`, and `sf` behaviors ensure prior-idle and positional hand
filtering apply only to HRMs. The three decisive layer thumbs are
hold-preferred, Space/Function is balanced with quick tap, and Backspace is a
plain repeatable key.

## Build

Nix is the sole build definition for this repository; there is intentionally
no separate `build.yaml` matrix. Install [Nix](https://nixos.org/download/)
with flakes enabled, then build the normal firmware:

```sh
nix build .#firmware
```

The build produces both halves under `result/`:

```text
result/zmk_left.uf2
result/zmk_right.uf2
```

Build the destructive settings-reset images separately:

```sh
nix build .#settings-reset --out-link result-settings-reset
```

This produces `result-settings-reset/zmk_left.uf2` and
`result-settings-reset/zmk_right.uf2`. The normal firmware remains the flake's
default package.

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

### Settings-reset recovery

Settings-reset firmware erases stored ZMK settings, including Bluetooth bonds.
Use it only when deliberate recovery is required:

1. Build with `nix build .#settings-reset --out-link result-settings-reset`,
   or start its guided flasher with `nix run .#flash-settings-reset`.
2. Flash the matching settings-reset image to both halves.
3. Flash the normal firmware back to both halves with `nix run .#flash` or the
   manual procedure above.
4. Remove the keyboard's old bond from the host.
5. Pair the keyboard again.

The `BootL`/`BootR` and `ResetL`/`ResetR` controls on `SYSTEM` provide an
assembled-keyboard recovery path without relying only on a physical reset
double-tap. Flashing is never performed automatically by a build.

### Sleep and wake validation

Deep sleep is enabled, but its thresholds are intentionally unchanged until
the hardware behavior is measured. Before tuning them, record the first key
after idle and deep sleep, reconnection delay, battery life, and any difference
between left- and right-half wake behavior.

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

After changing the keymap or configuration, run `nix flake check` followed by
`nix build .#firmware` and `nix build .#settings-reset`.

To update the pinned West dependencies and their Nix hash:

```sh
nix run .#update
```

Review the resulting changes to `config/west.yml` and `flake.nix`, then rebuild
both halves. GitHub Actions also checks pull requests and pushes to `main`,
uploads normal and recovery images as the `zmk_firmware` and
`zmk_settings_reset` artifacts, and opens scheduled dependency-update pull
requests.
