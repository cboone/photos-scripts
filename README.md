# Photography scripts

## Goals

- Store all the unmodified original RAFs straight OOC
- Add all necessary metadata as early in the pipeline as possible, so as not to rely on external tools
- Store the working copies in a datestamped directory structure, independent of any external tools
- Only import selects into Lightroom, but store all non-rejected photos as working copies
- Import selects into Lightroom such that Classic uses the local working copy and CC (desktop, iOS, and web) uses the full RAF in the cloud, and changes are synced between them
- Log all automated changes in a lightweight but structured format so that future changes to the workflow can be more easily accommodated

## Workflow

NB: Path context is `~/Pictures/Photographs`. Directory structure overview [below](#directories), details in [../Notes/directories.md](https://github.com/cboone/photos-notes/blob/main/directories.md).

1. I insert "Untitled" card with X-T5 raw photos
2. On mount, `Chronosync` copies all new photos from the card to `Importing`
   1. Then runs `finalize-x-t5-card-sync-chronosync-wrapper`
   2. Which runs `finalize-x-t5-card-sync` with timestamped logging to `Scripts/logs` (which can be viewed using `less-log` or `tail-log`)
      1. Which runs `backup-new-imports` which uses `exiftool` to
         1. Copy all photos in `Importing/` to `Originals/YYYY/YY-MM-DD/` (using the photo creation date)
         2. Create a structured log of all backed up photos in `Logs/YYYY/YYYYmmddTHHMMSS-imported.csv` (using today's date in ISO 8601-ish format)
      2. Then runs `update-new-imports-metadata`
         1. Which runs `update-copyright-metadata` which uses `exiftool` to update the copyright metadata to standard values
         2. Then runs `update-lens-metadata` to update the lens metadata, iff the lens used (per file) appears to have been a manual lens without exif data (the Laowa 10mm)
         3. Then runs `download-tracks-and-geotag-photos`
            1. Which runs `download-tracks`
               1. Which uses `gaiagps` to download all tracks newly created within the past week and save them as GPF files in `~/Documents/Gaia GPS/Tracks`
            2. Then runs `geotag-photos` which uses `exiftool` to geotag all newly imported photos
         4. Then runs `create-sidecar` which uses `exiftool` to copy all metadat from the RAF photo file to a new xmp sidecar file
      3. Then runs `move-and-rename-newly-imported-photos` which uses `exiftool` to
         1. Move the files to `Reviewing/YYYY-MM-DD-FILENAME.{RAF,xmp}` (using the photo creation date)
         2. Create a structured log of all imported photos in `Logs/YYYY/YYYYmmddTHHMMSS-renamed.csv` (using today's date in ISO 8601-ish format)
      4. Then runs `open-new-imports-for-review`
         1. Which quits `FastRawViewer` if it's already running (to reset the date filters)
         2. Which opens `Reviewing/` in `FastRawViewer`
            1. In which I review the photos by
               1. Marking selects with >= 1 star
               2. Marking rejects with -1 star
      5. Then runs `unmount-card` (without waiting for the manual review process)
3. After reviewing the photos in `FastRawViewer`, I run `finish-review`
   1. Which runs `trash-rejected-photos` which uses `exiftool` to
      1. Find all photos with -1 stars in `Ready to review/`
      2. Pass them to `trash` for soft deletion
      3. Create a structured log of all rejected photo filenames in `Logs/YYYY/YYYYmmddTHHMMSS-rejected.csv` (using today's date)
   2. Then runs `move-and-import-selected-photos` which
      1. Which uses `exiftool` to
         1. Find all photos with ≥ 1 star in `Ready to review/`
         2. Move them (and their sidecars) to `YYYY/` (using the photo creation date)
         3. Create a structured log of all selected photos in `Logs/YYYY/YYYYmmddTHHMMSS-selected.csv` (using today's date)
      2. Opens the selected photos and their sidecars in Adobe Lightroom Classic
      3. Waits for me to "press any key", which I do after
         1. I import the photos into the local Lightroom catalog
         2. Mark them for syncing to the Lightroom cloud, via adding them to a synced collection
      4. Opens the selected photos and their sidecars in Adobe Lightroom CC
         1. Then I import the photos into the Lightroom cloud (again), which replaces the Smart Previews generated by Lightroom Classic with the real RAF files
      5. Waits for me to "press any key", which I do after I confirm the photos have been imported into Lightroom CC successfully
      6. Then runs `move-reviewed-photos` which uses `exiftool` to
         1. Move all remaining files (RAF and xmp) from `Reviewing/` to `YYYY/` (using the photo creation date)
         2. Create a structured log of all reviewed (but not selected or rejected) photos in `Logs/YYYY/YYYYmmddTHHMMSS-reviewed.csv` (using today's date)

## Directories

Overview of relevant directories, details in [../Notes/directories.md](https://github.com/cboone/photos-notes/blob/main/directories.md):

- ~/Pictures/
  - Photographs/
    - YYYY/
    - History/
    - Importing/
    - Logs/
    - Originals/
    - Reviewing/
  - Scripts/
    - logs/

## Structured log format

NB: Dates in photo and sidecar filenames are the date of photo creation (`DateTimeOriginal` in `exiftool`). Dates in log filenames are the current date (the date the script was run).

### 1. Imported

`Logs/YYYY/YYYYmmddTHHMMSS-imported.csv`

|Original photo filename|Path to backed up original photo|
|-|-|
|DSCF2859.RAF|Originals/2023/2023-01-24/DSCF2859.RAF|

### 2. Renamed

`Logs/YYYY/YYYYmmddTHHMMSS-renamed.csv`

|Original photo filename|Updated photo filename|Sidecar filename|
|-|-|-|
|DSCF2859.RAF|20230124-DSCF2859.RAF|20230124-DSCF2859.xmp|

### 3. Rejected

`Logs/YYYY/YYYYmmddTHHMMSS-rejected.csv`

|Photo filename|Sidecar filename|
|-|-|
|20230124-DSCF2859.RAF|20230124-DSCF2859.xmp|

### 4. Selected

`Logs/YYYY/YYYYmmddTHHMMSS-selected.csv`

|Path to photo|Path to sidecar|
|-|-|
|2023/2023-01-24/DSCF2859.RAF|2023/2023-01-2420230124-DSCF2859.xmp|

### 5. Reviewed (non-rejected, non-selected)

`Logs/YYYY/YYYYmmddTHHMMSS-reviewed.csv`

|Path to photo|Path to sidecar|
|-|-|
|2023/2023-01-24/DSCF2859.RAF|2023/2023-01-24/DSCF2859.xmp|

## Other notes

I suspect there are still ways for Lightroom Classic / the local catalog and Lightroom CC / the cloud to get out of sync. For example, if I use "Enhance" in Classic, it creates a new file alongside the original and imports it, and presumably syncs it as appropriate with the cloud; but what happens if I use "Enhance" in CC?

## To do

- ~~Geotagging~~
- Don't import photos that already exist in the catalog
- Store xmp history snapshots
- Automate xmp history snapshots
- Create reconciliation scripts
- Don't back up already datestamped photos
- Don't rename already datestamped photos
- ~~Subtract one star before import~~

## References

- The FastRawViewer approach to flattening / linearizing raw files is described in multiple blog posts and articles; this blog post has the most detailed description of the actual metadata tag changes used to accomplish it: <https://www.fastrawviewer.com/blog/red_flowers_photography_to-see-the-real-picture>

## Tools

- `ChronoSync`: <https://www.econtechnologies.com/chronosync/overview.html>
- `FastRawViewer`: <https://www.fastrawviewer.com>
- `gaiagps`: <https://github.com/kk7ds/gaiagpsclient>
- `trash`: <https://hasseg.org/trash/>, `brew install trash`
