# Repository Guidelines

## Project Structure & Module Organization

This repository contains the Warcraft III map *Forsaken Bastion's Fall*. The root `FBF_v0.4.9_dev.w3x` is the current development map and the one verified to open and run in the current World Editor. The root also holds a tracked copy, `FBF_v0.4.9_dev - Working copie.w3x`; `release/` holds older packaged `.w3x` versions. Gameplay source is primarily vJASS (`.vj`), organized by feature under `src/`: for example, `src/Heroes/<Hero>/` contains abilities, `src/AI-Systems/` contains hero and tower AI, and `src/Libraries/` contains shared vJASS code. `src/imports.j` is the compile manifest (see below). `documentation/` contains versioned artwork, project files, an archived website, and separate experimental test-map material. Keep new gameplay code with its related system rather than in `documentation/`.

## Build, Test, and Development Commands

There is no repository-wide CLI build and no automated gameplay test suite; do not introduce or suggest build or test commands that do not exist. The verified workflow is:

1. Edit the vJASS source in `src/`.
2. Make sure every new `.vj` file is listed in `src/imports.j`. It is the compile manifest: a file that is not imported there is not compiled into the map.
3. Open `FBF_v0.4.9_dev.w3x` in the current Warcraft III World Editor, which includes JassHelper and pJASS, with `Enable JassHelper` and `Enable vJASS` turned on, and save the map to compile it.
4. Start the map from the editor and playtest the change in Warcraft III.

`src/imports.j` currently contains machine-specific absolute Windows paths to one checkout location, so it only compiles where the checkout sits at that path. On another machine, change the path prefix to your checkout before compiling, and keep that local path change out of unrelated commits. Do not convert the entries to relative paths or any other scheme unless that has been verified to compile in the current editor.

`git status --short` shows changed files before a commit; `git diff --check` catches whitespace errors. If working with layered artwork, run `git lfs pull` to fetch tracked `.psd` files.

## Coding Style & Naming Conventions

Use `.vj` for vJASS modules and follow the surrounding file's indentation; existing code mixes tabs and spaces, so avoid reformatting unrelated lines. Match the established `scope`/`library`, `struct`, and `private` conventions. Use descriptive PascalCase module and ability filenames such as `HeroAIThreat.vj` or `Cleave.vj`; keep raw Warcraft object IDs and related constants close to the ability that uses them. No project-wide formatter or linter is configured.

Source files use CRLF line endings. Most are UTF-8 or ASCII, but some `.vj` files are Latin-1 (Windows-1252) with German umlauts in comments, for example `src/GameConfig/GameConfig.vj`; keep each file's existing encoding. Comments mix German and English; match the file you are editing.

## Testing Guidelines

There is no gameplay test suite or coverage target. For gameplay changes, compile the map and playtest the affected hero, system, or game mode; describe the scenario and result in the pull request. The archived website has a separate `documentation/FBF-Website/tests/phpunit.xml` for its PHP tests; it is not a test harness for the map.

There is no verified way for an agent to compile or run the map, and static checks such as grep or `git diff --check` do not show that a change compiles or works. Never claim that a change compiles or behaves correctly in game unless a human saved the map in the editor or playtested it and reported the result. Otherwise, state explicitly that the change has not been compiled or playtested, and name the scenario a human should test.

## Commit & Pull Request Guidelines

Recent commits use short, descriptive subjects, often beginning with a verb such as “Configure,” “Integrate,” or “changed.” Write a specific subject that names the affected behavior or asset. In pull requests, summarize the change, list map compile and playtest results (or state that none were performed), link any relevant issue, and attach screenshots or a short clip for visible gameplay or artwork changes. Avoid committing editor backups or unrelated generated map files.
