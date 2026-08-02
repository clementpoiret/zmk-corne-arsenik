# Shared Cheapino and Corne behavior specification

**Specification version:** 2026-08-02

This document is the normative, firmware-independent behavior contract for:

- the QMK Cheapino v2 `arsenik` keymap on the `cheapinov2` branch; and
- this ZMK Corne configuration.

The two firmwares may use different implementation mechanisms and tuning
constants where their input models differ. A gesture is conformant when it
produces the behavior specified here on both keyboards.

## Host contract

- The host runs Linux XKB Ergo-L 1.0.0.
- Firmware `BASE` emits physical QWERTY-position HID usages. XKB performs the
  Ergo-L translation; semantic Ergo-L keycodes must not be placed on `BASE`.
- Non-base letters, punctuation, operators, and shortcuts use semantic Ergo-L
  aliases.
- The right outer thumb emits plain Right Alt and provides native Ergo-L AltGr
  symbols.
- The Application/Menu key is configured as Compose with the XKB option
  `compose:menu`.
- Firmware Unicode entry is not part of the input path. Ergo-L's one-dead-key
  position (`ODK`) and host Compose provide extended characters.

There is no Lafayette/Symbol layer and no separate Number Row layer.

## Public layers and access

The public layer order is fixed across both firmwares:

| # | Layer | Access | Responsibility |
| --- | --- | --- | --- |
| 0 | `BASE` | Default | Text entry, home-row mods, and thumb tap-holds |
| 1 | `NAV` | Hold left outer thumb | Navigation, editing, browser actions, and Repeat |
| 2 | `NUM_EDIT` | Hold right inner thumb | Digits, arithmetic, punctuation, and numeric editing |
| 3 | `FUNCTION` | Hold left home thumb | Function, media, brightness, sticky modifiers, and literal Space |
| 4 | `MOUSE` | Hold left inner thumb | Pointer movement, scrolling, buttons, and speed selection |
| 5 | `SYSTEM` | From `FUNCTION`, hold right outer thumb | Guarded maintenance and layer locks |

ZMK may use private layers above 5 for temporary mouse-speed overlays. They do
not change this public order or expose another daily layer.

`NUM_EDIT` and `MOUSE` can be toggled from `SYSTEM`. Locks have no timeout on
either keyboard. The locked layer's access thumb unlocks it, and `MOUSE` also
has an explicit `BASE` exit.

## BASE and home-row modifiers

The primary diagram shows semantic Ergo-L output:

```text
 Q        C        O         P        W      | J        M        D        ODK      Y
 A/GUI    S/Alt    E/Shift   N/Ctrl   F      | L        R/Ctrl   T/Shift  I/Alt    U/GUI
 Z        X        -         V        B      | .        H        G        ,        K

                   Esc/NAV   Space/FUNCTION  Tab/MOUSE | Enter/NUM_EDIT  Backspace  AltGr
```

For firmware debugging, the corresponding raw HID positions are:

```text
 Q        W        E         R        T      | Y        U        I        O        P
 A/GUI    S/Alt    D/Shift   F/Ctrl   G      | H        J/Ctrl   K/Shift  L/Alt    ;/GUI
 Z        X        C         V        B      | N        M        ,        .        /
```

The thumb contract is:

| Physical thumb | Tap | Hold |
| --- | --- | --- |
| Left outer | Escape | `NAV` |
| Left home | Space | `FUNCTION` |
| Left inner | Tab | `MOUSE` |
| Right inner | Enter | `NUM_EDIT` |
| Right home | Backspace | None; plain repeatable key |
| Right outer | Right Alt / AltGr | None; plain modifier |

### Tap-hold invariants

| Key class | Policy | Tapping term | Quick tap |
| --- | --- | --- | --- |
| Eight HRMs | Balanced, prior-idle filtering, opposite-hand targets | 200 ms | 175 ms |
| Escape/NAV, Tab/MOUSE, Enter/NUM_EDIT | Decisive hold, either-hand targets, no prior-idle filter | 150 ms | Disabled |
| Space/FUNCTION | Conservative balanced policy, either-hand targets, no prior-idle filter | 150 ms | 175 ms |

Fast same-hand HRM rolls must produce letters. Opposite-hand modifier chords
and two- or three-modifier chords must remain available. A recently typed
ordinary character must not prevent a layer thumb from activating. Holding an
HRM alone past its tapping term must produce its modifier.

## Common work layers

### NAV

```text
 Ctrl+Left        Ctrl+Right        Ctrl+Bsp   Ctrl+Del   Repeat | BrowserBack  Home           PgDn     PgUp  End
 Ctrl+A           Ctrl+Z            Redo       Ctrl+C     Ctrl+V | BrowserFwd   Left           Down     Up    Right
 Ctrl+Shift+Left  Ctrl+Shift+Right  Shift+Home Shift+End Ctrl+X | x             Ctrl+Shift+Tab Ctrl+Tab x     x
                                      ___  ___  ___       | ___  Delete  Escape
```

Redo is `Ctrl+Shift+Z`. Every letter shortcut is encoded through an Ergo-L
semantic alias. Environment-specific Super shortcuts and generic `Ctrl+S` are
not part of the common layer.

### NUM_EDIT

```text
 =       Home       Up          End         PgUp       | /   7   8   9   *
 +       Left       Down        Right       PgDn       | -   4   5   6   0
 ODK     Ctrl+Left  Ctrl+Bsp    Ctrl+Del    Ctrl+Right | ,   1   2   3   .
                         Tab  Backspace  Enter         | NumEdit/Unlock  x  x
```

Digits use ordinary digit-row HID usages, not keypad usages. `ODK` followed by
1–5 produces `„`, `“`, `”`, `¢`, and `‰` through the host Ergo-L layout.

### FUNCTION

```text
 F1  F2   F3   F4   x   | PrintScreen  Brightness-  Brightness+  Mute       ASCII Space
 F5  F6   F7   F8   x   | LeftCtrl     LeftShift    LeftAlt      LeftGUI    x
 F9  F10  F11  F12  x   | Previous     Play/Pause   Next         Volume-    Volume+
             StickyAltGr  Space  x      | StickyShift  Backspace  SYSTEM
```

Sticky AltGr and Shift affect the next key or expire after one second. `ASCII
Space` emits U+0020 while suppressing active Shift and Right Alt for that action,
then restores the modifier state.

### MOUSE

```text
 Slow  Fast  x     x    x | Button4  WheelLeft  WheelDown  WheelUp  WheelRight
 Ctrl  Shift Alt   GUI  x | Button5  Left       Down       Up       Right
 Button1 Button2 Button3 x x | x        x          x          x        x
                 Base  Space  Mouse/Unlock | x  Backspace  Escape
```

The left hand supplies explicit modifiers and buttons; the right hand supplies
movement, scrolling, Back, and Forward. Slow, normal, and fast behavior is tuned
independently by firmware and compared by observed displacement rather than by
numeric constants.

## SYSTEM

`SYSTEM` deliberately uses a guarded two-step gesture: hold Space for
`FUNCTION`, then hold the right outer thumb. Common actions occupy the same
physical positions:

- Caps Lock: physical `O` position;
- Compose: physical `P` position;
- `NUM_EDIT` lock: physical `H` position;
- `MOUSE` lock: physical `;` position.

Cheapino-specific contents:

```text
 Bootloader  Diagnostics  x  x  x | x        x        x  CapsLock  Compose
 x           x            x  x  x | NumLock  x        x  x         MouseLock
 x           x            x  x  x | x        x        x  x         x
```

Corne-specific contents:

```text
 BT1   BT2     BT3    BT4  BT5 | USB      BLE   Toggle  CapsLock  Compose
 Clear x       x      x    x   | NumLock  Prev  Next    x         MouseLock
 ALL+  ResetL  BootL  x    x   | x        x     BootR   ResetR    +ALL
```

The Corne `ALL` keys form a two-key combo that clears every Bluetooth profile;
neither outer key clears anything by itself. Reset and bootloader actions are
source-local and act on the half where the binding was pressed. The Cheapino
bootloader and diagnostic actions are intentionally device-specific.

## Intentional differences

| Corne only | Cheapino only |
| --- | --- |
| BLE split transport, profiles, output routing, batteries, displays, sleep and reconnect behavior | Wired transport, rotary encoder, one RGB LED, custom bidirectional matrix, and ghost suppression |
| Per-half bootloader/reset and settings-reset images | One RP2040 UF2 and guarded `QK_BOOT` |
| Private mouse-speed overlay layers | QMK Mouse Keys acceleration selectors |

Hardware-specific behavior is conformant when it does not change ordinary text,
symbols, editing, layer access, HRMs, or thumb gestures. Validation requirements
and recorded evidence live in [parity-acceptance.md](parity-acceptance.md).
