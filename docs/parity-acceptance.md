# Cheapino and Corne parity acceptance record

This record verifies the behavior in
[shared-behavior.md](shared-behavior.md). Automated firmware checks are run in
the repositories; physical results are recorded here only after observing the
actual keyboards on the target Linux/XKB Ergo-L host.

## Current status

- Preparation: **COMPLETE**
- Physical Cheapino suite: **NOT RUN — deferred by owner**
- Physical Corne suite: **NOT RUN — deferred by owner**
- Overall phase 7: **INCOMPLETE — hardware validation pending**

Status values are `PASS`, `FAIL`, `NOT RUN`, and `N/A`. Phase 7 is complete only
when every applicable physical row is `PASS`, no row is `FAIL` or `NOT RUN`, and
the candidate firmware hashes are recorded.

## Firmware identities

| Role | Repository state | Artifact evidence |
| --- | --- | --- |
| QMK rollback | Commit `5e04db69` | `artifacts/phase6-rollback/MANIFEST.md` in the parent workspace |
| ZMK rollback | Commit `614a5d18` | Normal and settings-reset UF2s in the same manifest |
| QMK candidate | Jujutsu change `swuptzqm` | Release SHA-256 `de6c14a9a65ed88fd420e584a12b768520fe39195a7785aed78aed80909286aa` |
| ZMK candidate | Firmware commit `d5988589`; docs change `srvtwqmp` | Left SHA-256 `ff9058c8ad72f85796ad390f95d046f185079d610f9ba373dba0b4de0a9a16af`; right SHA-256 `3fcfac62e494e752323e3be09df1b618b82ae7ea75852816070fdb17870cdf51` |

The ZMK documentation child does not enter the filtered firmware source. The
candidate firmware therefore comes from the preserved dependency-refresh
commit `d5988589`. Candidate and settings-reset files, including their complete
hashes, are recorded in `artifacts/phase7-candidate/MANIFEST.md` in the parent
workspace.

## Automated gates

| ID | Gate | Expected | Status | Evidence |
| --- | --- | --- | --- | --- |
| AUTO-QMK-01 | `qmk test-c --test cheapino` | 11 tests pass | PASS | 11/11 tests passed |
| AUTO-QMK-02 | Clean Arsenik release build | `cheapino_arsenik.uf2` produced | PASS | Candidate hash recorded above |
| AUTO-QMK-03 | Clean Arsenik Console build | Diagnostic UF2 produced | PASS | `CONSOLE_ENABLE=yes` build exited successfully |
| AUTO-QMK-04 | Clean default-keymap build | `cheapino_default.uf2` produced | PASS | Clean build exited successfully |
| AUTO-ZMK-01 | `nix flake check --no-write-lock-file` | All checks pass | PASS | All native-system flake checks passed |
| AUTO-ZMK-02 | Build `.#firmware` | Left and right normal UF2s produced | PASS | Both candidate hashes recorded above |
| AUTO-ZMK-03 | Build `.#settings-reset` | Left and right reset UF2s produced | PASS | Both images verified against the candidate manifest |
| AUTO-DOC-01 | Compare keymaps with the shared specification | Common positions and gestures match | PASS | Layer order, common actions, HRMs, thumbs, locks, and `SYSTEM` positions compared |
| AUTO-DOC-02 | Search active keymaps for retired features | No Lafayette, Number Row, or firmware Unicode path | PASS | Case-insensitive searches returned no matches |

`qmk lint -kb cheapino` is not a phase-7 gate. Before this work it already
reported unrelated legacy license-header issues in `halconf.h` and `mcuconf.h`
and the pre-existing VIA keymap.

## Host preflight

Record these before physical testing:

| ID | Check | Required evidence |
| --- | --- | --- |
| PRE-01 | Linux XKB Ergo-L 1.0.0 is active | Layout name/version and active XKB options |
| PRE-02 | `compose:menu` is active | Application/Menu begins a Compose sequence |
| PRE-03 | Candidate firmware is flashed | Exact UF2 filename and SHA-256 per device/half |
| PRE-04 | Rollback firmware is available | Re-run the manifest checksum verification |
| PRE-05 | Corne bonds are healthy | Both halves connected; host profile recorded |

For exact text comparison, type each requested corpus into separate UTF-8 files
without copy/paste, then run:

```sh
cmp --silent cheapino-output.txt corne-output.txt
sha256sum cheapino-output.txt corne-output.txt
```

Use `od -An -tx1` or a Unicode-aware editor to distinguish U+0020, U+00A0, and
U+202F. For raw HID timestamps, select the keyboard event node with `evtest`;
for pointer displacement and scrolling, capture `libinput debug-events`. A QMK
diagnostic build plus `qmk console` supplies matrix, ghost, and encoder evidence.

## Common physical suite

### Character and symbol output

| ID | Procedure and expected result | Cheapino | Corne | Evidence/notes |
| --- | --- | --- | --- | --- |
| CHAR-01 | Tap every BASE position once; output matches the semantic Ergo-L BASE diagram | NOT RUN | NOT RUN | Deferred |
| CHAR-02 | Type `Portez ce vieux whisky au juge blond qui fume.` and `The quick brown fox jumps over the lazy dog.` exactly | NOT RUN | NOT RUN | Deferred |
| CHAR-03 | Type representative accented French text including `é è à ç œ É` with host-native Ergo-L/Compose behavior | NOT RUN | NOT RUN | Deferred |
| CHAR-04 | Produce apostrophes, straight/curly quotes, brackets, braces, and `+ - * / = , . : ; ! ? @ # $ % & \| \\ _ ~ ^` | NOT RUN | NOT RUN | Deferred |
| CHAR-05 | `ODK` followed by 1–5 produces exactly `„ “ ” ¢ ‰` | NOT RUN | NOT RUN | Deferred |
| CHAR-06 | Shift+Space, AltGr+Space, and AltGr+Shift+Space produce U+202F, U+0020, and U+00A0 respectively | NOT RUN | NOT RUN | Deferred |
| CHAR-07 | `FUNCTION` ASCII Space produces U+0020 while Shift or AltGr is active, then restores the modifier | NOT RUN | NOT RUN | Deferred |
| ALT-01 | Every native Ergo-L AltGr position matches on both keyboards; no firmware symbol layer participates | NOT RUN | NOT RUN | Deferred |

### Shortcuts and layers

| ID | Procedure and expected result | Cheapino | Corne | Evidence/notes |
| --- | --- | --- | --- | --- |
| NAV-01 | Verify arrows, Home/End, Page Up/Down, word movement/deletion/selection, and line selection | NOT RUN | NOT RUN | Deferred |
| NAV-02 | Verify Ctrl+A/C/V/X/Z, Ctrl+Shift+Z, previous/next tab, and browser Back/Forward through host events and target applications | NOT RUN | NOT RUN | Deferred |
| NAV-03 | Basic Repeat covers doubled letters, punctuation, deletion, arrows, paging, and one application command | NOT RUN | NOT RUN | Deferred |
| NUM-01 | Direct Enter-thumb access works after idle and immediately after ordinary typing | NOT RUN | NOT RUN | Deferred |
| NUM-02 | Verify digits 0–9, `+ - * / =`, comma, period, Tab, Backspace, Enter, arrows, paging, and word editing | NOT RUN | NOT RUN | Deferred |
| NUM-03 | Toggle `NUM_EDIT`, use it without holding Enter, then unlock with the layer thumb | NOT RUN | NOT RUN | Deferred |
| FUN-01 | Verify F1–F12, Print Screen, brightness, mute, volume, and media controls | NOT RUN | NOT RUN | Deferred |
| FUN-02 | Sticky Shift and Sticky AltGr affect one key, release correctly, and expire after one second | NOT RUN | NOT RUN | Deferred |
| SYS-01 | The shared `SYSTEM` gesture works; Caps Lock, Compose, Num lock, and Mouse lock occupy identical positions | NOT RUN | NOT RUN | Deferred |

### HRM and thumb timing

Run `HRM-01` through `HRM-08` for A/GUI, S/Alt, E/Shift, N/Ctrl,
R/Ctrl, T/Shift, I/Alt, and U/GUI respectively. For each HRM test tap, hold with
an opposite-hand target, fast and slow same-hand rolls, a two-modifier chord, a
three-modifier chord, activation immediately after rapid typing, and holding
alone beyond 200 ms. GUI HRMs must receive extra attention because a false hold
is more disruptive.

| ID | Expected result | Cheapino | Corne | Evidence/notes |
| --- | --- | --- | --- | --- |
| HRM-01…08 | Taps remain letters; intended holds and multi-modifier chords work; fast same-hand rolls do not become modifiers | NOT RUN | NOT RUN | Deferred |

For each layer thumb, press target keys after approximately 50, 100, 150, 200,
and 250 ms. Use targets on both hands.

| ID | Required chords and expected result | Cheapino | Corne | Evidence/notes |
| --- | --- | --- | --- | --- |
| THUMB-01 | Esc/NAV with left and right actions always enters NAV when chording | NOT RUN | NOT RUN | Deferred |
| THUMB-02 | Space/FUNCTION with left F-keys and right media/modifier actions remains tap-biased for prose but usable as a hold | NOT RUN | NOT RUN | Deferred |
| THUMB-03 | Tab/MOUSE with movement and modified clicks always enters MOUSE when chording | NOT RUN | NOT RUN | Deferred |
| THUMB-04 | Enter/NUM_EDIT with right digits and left editing actions always enters NUM_EDIT when chording | NOT RUN | NOT RUN | Deferred |
| THUMB-05 | Tap-then-hold Space repeats Space; tap-then-hold Escape, Tab, and Enter enters their layers | NOT RUN | NOT RUN | Deferred |
| THUMB-06 | Held Backspace repeats normally and identically | NOT RUN | NOT RUN | Deferred |

### Mouse behavior

For normal, slow, and fast modes, record pointer displacement and scroll events
after one tap and 250, 500, and 1000 ms holds. Compare practical behavior rather
than firmware constants.

| ID | Procedure and expected result | Cheapino | Corne | Evidence/notes |
| --- | --- | --- | --- | --- |
| MOUSE-01 | Left/right/up/down pointer movement is usable and directionally correct in all speed modes | NOT RUN | NOT RUN | Deferred |
| MOUSE-02 | Vertical/horizontal scrolling and Back/Forward work | NOT RUN | NOT RUN | Deferred |
| MOUSE-03 | Left, right, middle, modified click, and modified drag work without HRM ambiguity | NOT RUN | NOT RUN | Deferred |
| MOUSE-04 | Momentary use, lock, unlock, and explicit Base exit behave identically | NOT RUN | NOT RUN | Deferred |

## Corne-specific suite

| ID | Procedure and expected result | Status | Evidence/notes |
| --- | --- | --- | --- |
| ZMK-01 | HRM and multi-modifier chords work when events originate on either half | NOT RUN | Deferred |
| ZMK-02 | Record first input after idle, first input after deep sleep, reconnection delay, and asymmetric-half wake behavior | NOT RUN | Deferred |
| ZMK-03 | Select profiles 1–5 and use previous/next profile | NOT RUN | Deferred |
| ZMK-04 | Force USB, force BLE, toggle output, and type over BLE while charging over USB | NOT RUN | Deferred |
| ZMK-05 | Clear the current profile without clearing others; the distant two-key combo clears all only when deliberately pressed | NOT RUN | Deferred |
| ZMK-06 | Left/right reset and bootloader keys act on the physical half where pressed | NOT RUN | Deferred |
| ZMK-07 | Settings-reset images clear both halves; normal firmware restores operation after host bond removal and re-pairing | NOT RUN | Deferred |
| ZMK-08 | nice!view shows every public/private layer name and makes locked-layer state observable | NOT RUN | Deferred |
| ZMK-09 | Mouse reports still work after re-pairing if the host cached an older HID descriptor | NOT RUN | Deferred |

## Cheapino-specific suite

| ID | Procedure and expected result | Status | Evidence/notes |
| --- | --- | --- | --- |
| QMK-01 | Every documented ghost pattern suppresses its observed phantom | NOT RUN | Deferred |
| QMK-02 | Intentionally press each ambiguous full pattern and record the expected legitimate-key loss | NOT RUN | Deferred |
| QMK-03 | Two- and three-HRM chords near every ghost pattern are characterized | NOT RUN | Deferred |
| QMK-04 | Slow/fast clockwise and counter-clockwise detents emit exactly one event each | NOT RUN | Deferred |
| QMK-05 | Invalid/skipped quadrature transitions and `AB → neutral` do not emit stale movement | NOT RUN | Deferred |
| QMK-06 | Encoder button bounce emits one Mute action per stable release | NOT RUN | Deferred |
| QMK-07 | Encoder rotation/press during dense nearby chords does not remove unrelated keys | NOT RUN | Deferred |
| QMK-08 | Startup sweep restores saved RGB state without persisting animation frames | NOT RUN | Deferred |
| QMK-09 | Guarded bootloader and diagnostic controls work; normal release has diagnostics disabled | NOT RUN | Deferred |

## Failure handling

On any physical failure:

1. record the exact firmware hash, host configuration, gesture, timestamps, and
   observed output;
2. restore the rollback artifact if the failure blocks ordinary use;
3. leave the row as `FAIL` and keep phase 7 incomplete; and
4. make a targeted corrective change with its own regression evidence rather
   than tuning unrelated timing or behavior.
