---
name: safe-w3x-change
description: Rules, safety steps and required evidence for changing the current development map FBF_v<Version>_dev.w3x of Forsaken Bastion's Fall directly with tools, in any internal area of the MPQ archive (object data, imports, trigger and script data, terrain, regions and others). Use only when the ticket explicitly requires a direct map change, before the first write access to the map, after writing it, and when reviewing a PR that changes a .w3x.
---

# Safe direct map change

A direct change to a `.w3x` is allowed only when the governing ticket explicitly requires that the agent change the current development map. Without that requirement, do not write any `.w3x`; list the needed World Editor or Object Editor changes in the PR for a human instead.

The permission covers every internal area of the map, for example object data (`war3map.w3u`, `war3map.w3a`, `war3map.w3t` and the other object files, including the `war3mapSkin.*` files), imported files and `war3map.imp`, trigger and script data (`war3map.wtg`, `war3map.wct`, `war3map.j`), strings (`war3map.wts`), terrain (`war3map.w3e`) and regions (`war3map.w3r`). It covers only what the ticket asks for, and only with the tools and checks below. Handling that works for one internal format proves nothing for another: every format you write needs its own format-aware, verified handling.

## Scope and protected files

- Determine the development map from the repository: `ls FBF_v*_dev.w3x` must match exactly one file in the repository root. Never hard-code the version. If nothing or more than one file matches, stop and ask.
- Maps in `release/` and a `Working copie` in the repository root stay untouched unless a separate ticket explicitly requires a change to that exact file. If one does, every rule in this skill applies to that map as it does to the development map.
- Never commit backups, extracted internal files, intermediate maps or test maps. The only map that may be committed is the map the ticket requires to change, staged by its explicit path.

## 1. Before the first write

1. Run `git status --short`. Never discard, stash, reset or commit changes you did not make. If the development map already has uncommitted changes that you did not make, stop and ask which state is the starting point.
2. Create a byte-identical backup outside the repository, in a location that outlives the session (not only a temporary directory the system may clean up). Confirm with `cmp` that the backup equals the original.
3. Record the SHA-256 of the original (`sha256sum`) and whether it equals the committed version: compare `git hash-object <map>` with `git rev-parse HEAD:<map>`.
4. Inspect the map read-only. Open it as an MPQ archive, list the internal files (from `(listfile)` plus the known names), read every internal file and record its size and SHA-256. Record the archive facts your change depends on: header and format version, sector size, size and position of the hash and block tables, and for every internal file you will change its position and flags (compression, encryption, key adjustment, sector checksums).
5. Parse every internal file you will change completely. The parser must consume the file exactly to its end; an unknown format version, an unknown field type or leftover bytes mean stop. Record the current value of every record and field you will touch and compare it with the state the ticket expects. If they differ, stop and report the difference.
6. Derive every new value from the ticket and existing data (the map itself, earlier map versions in the git history, `src/`, `documentation/`) and record the source of each value. Never guess object data values, rawcodes, paths or binary structures. If a value cannot be derived, leave that field unchanged and report it.

## 2. Tools

- The repository ships no MPQ tool. Use tools that understand the MPQ container (hash and block tables, encryption, compression, sector offset tables) and the internal format you change.
- Prove the tools on the real data before you use their output:
  - an unchanged internal file parsed and serialized again gives identical bytes;
  - re-encrypting an unchanged table or file with your routine reproduces the original bytes;
  - data you compress decompresses back to exactly the new content.
- Write only into a copy outside the repository. Replace the development map only after every check in section 3 passed.
- Change as little of the archive as possible: replace only the internal files the ticket needs and the integrity data that belongs to them. Keep the file list, the other internal files and the archive header unless the ticket requires otherwise.
- If an internal area cannot be read and written reliably, stop instead of changing unknown bytes experimentally.

## 3. Checks after writing

Run these checks on the copy:

1. Record the SHA-256 of the result.
2. Open the result again as an MPQ archive and read every internal file. If possible, also read it with an independent second implementation; a file that this second reader cannot handle must fail the same way in the original.
3. Compare the internal file list and the file size with the original. Every change must be required by the ticket.
4. Compare every internal file before and after by content hash. Every difference must be explained by the ticket: the intended content changes and the integrity data that belongs to them. An unexplained internal change means you must not use the result; in a review it is a `BLOCKER`.
5. Compare every changed internal file record by record and field by field: exactly the intended changes, nothing else added, removed or changed.
6. If the archive holds checksums or similar integrity data (for example CRC32, MD5 or file times in `(attributes)`), update the entries of the changed files and then verify every entry against the file contents. If there is integrity data you cannot update correctly (for example a `(signature)`), stop.
7. Copy the verified result over the development map and check that its SHA-256 equals the verified result.

Never claim that the map opens or saves in the World Editor or works in the game. Only a human can confirm that.

## 4. Commit and PR

- Commit on the issue branch only and stage the map by its explicit path (`git add FBF_v<Version>_dev.w3x` with the real file name). Never stage backups or temporary maps.
- Add this section to the PR body, in simple German:

```markdown
## Direkte Map-Änderung
- Map: `<Pfad der Map, meist FBF_v<Version>_dev.w3x>`
- SHA-256 vorher: `<hash>` (entspricht dem Stand in `<commit>`)
- SHA-256 nachher: `<hash>`
- Sicherung: lokal außerhalb des Repositorys, nicht committet
- Werkzeuge und Selbsttests: <womit gelesen und geschrieben wurde, welche Selbsttests bestanden>
- Absichtlich geänderte interne Dateien: <Datei und Grund>
- Geänderte Datensätze und Felder: <Objekt, Feld, Level: alt -> neu, Quelle des Werts>
- Unverändert: <Anzahl> interne Dateien mit gleichem Inhalts-Hash
- Dateiliste: <gleich oder geändert: ...>; Dateigröße: <gleich oder alt -> neu>
- Integritätsdaten: <aktualisiert und geprüft oder keine vorhanden>
- Nicht bestimmbar und daher nicht geändert: <optional>
```

## 5. Human merge gate

A PR that changes at least one `.w3x` stops before the merge, whether or not it also changes files under `src/`:

1. The agent first finishes the implementation, the static checks and the review. `BLOCKER`, `ERROR` and `MAJOR` are fixed unless a human has to decide.
2. The workflow stops before the merge and names the PR head to test.
3. A human opens the changed development map in the current Warcraft III World Editor.
4. The human saves it with `Enable JassHelper` and `Enable vJASS`.
5. The human checks that the intended map data is still present after saving. The World Editor can drop or normalize data when it saves; for example, the Warcraft III 3.0 World Editor removed level-5 ability values that were set to 0.
6. The human runs the Warcraft III playtest the ticket defines.
7. The human records the result and the tested commit on the PR.
8. If a later commit changes the `.w3x` again, the manual verification is required again for the new head.
9. Only then may `review-pr` merge.
