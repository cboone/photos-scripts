# Photography scripts

## Workflow

NB: Path context is `~/Pictures/Photographs`.

1. I insert "Untitled" card with X-T5 raw photos
2. On mount, Chronosync copies all new photos from the card to `./Importing`
3. Then runs `finalize-x-t5-card-sync-chronosync-wrapper`
4. Which runs `finalize-x-t5-card-sync` with timestamped logging to `./Scripts/logs` (which can be viewed using `less-log` or `tail-log`)
   1. Which runs `backup-new-imports` which uses `exiftool` to
      1. Copy all photos in `Importing/` to `Originals/YYYY/YY-MM-DD/` (using the photo creation date)
      2. Create a structured log of all backed up photos in `Logs/YYYY/YYYYmmddTHHMMSS-imported.csv` (using today's date in ISO 8601-ish format)
   2. Then runs `update-new-imports-metadata` which uses `exiftool` to
      1. Update the copyright metadata to standard values
      2. Update the exposure metadata to remove existing adjustments and set a linear (gamma 2.2) contrast curve, to create a flat-toned / linearized photo, following the FastRawViewer approach: <https://www.fastrawviewer.com/blog/red_flowers_photography_to-see-the-real-picture>
      3. Update the lens metadata, iff the lens used (per file) appears to have been a manual lens without exif data (the Laowa 10mm)
      4. Copy all metadata from the RAF file to an XMP sidecar file
   3. Then runs `move-and-rename-newly-imported-photos` which uses `exiftool` to
      1. Move the photos to `Ready for Review/YYYY-MM-DD-FILENAME.{RAF,xmp}` (using the photo creation date)
      2. Create a structured log of all imported photos in `Logs/YYYY/YYYYmmddTHHMMSS-renamed.csv` (using today's date in ISO 8601-ish format)
   4. Then runs `open-new-imports-for-review`
      1. Which opens `Ready for Review/` in FastRawViewer
         1. In which I review the photos by
            1. Marking selects with >= 1 star
            2. Marking rejects with -1 star
   5. Then runs `unmount-card` (without waiting for the manual review process)
5. I run `finish-review` after reviewing the photos in FRV
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
         2. And mark them for syncing to the Lightroom cloud, via adding them to a synced collection
      4. Opens the selected photos and their sidecars in Adobe Lightroom CC
   3. Waits for me to "press any key", which I do after
      1. I import the photos into the Lightroom Cloud (again), which replaces the Smart Previews generated by Lightroom Classic with the real RAF files
   4. Then runs `move-reviewed-photos` which uses `exiftool` to
      1. Move all remaining files (RAF and xmp) from `Ready to review/` to `YYYY/` (using the photo creation date)
      2. Create a structured log of all reviewed (but not selected or rejected) photos in `Logs/YYYY/YYYYmmddTHHMMSS-reviewed.csv` (using today's date)

### Goals

- Store all the unmodified original RAFs straight OOC
- Add all necessary metadata and set exposure setttings as early in the pipeline as possible, so as not to rely on external tools
- Store the working copies in a datestamped directory structure, independent of any external tools
- Only import selects into Lightroom, but store all non-rejected photos as working copies
- Import selects into Lightroom such that Classic uses the local working copy and CC (desktop, iOS, and web) uses the full RAF in the cloud, and changes are synced between them
- Log all automated changes in a lightweight but structured format so that future changes to the workflow can be more easily accomodated

#### Other notes

I suspect there are still ways for Lightroom Classic / the local catalog and Lightroom CC / the cloud to get out of sync. For example, if I use "Enhance" in Classic, it creates a new file alongside the original and imports it, and presumably syncs it as appropriate with the cloud; but what happens if I use "Enhance" in CC?

### Structured log format

NB: Dates in photo filenames are the date of photo creation. Dates in log filenames are the current date (the date the script was run).

#### 1. Imported

`Logs/YYYY/YYYYmmddTHHMMSS-imported.csv`

|Original photo filename|Path to backed up original photo|
|-|-|
|DSCF2859.RAF|Originals/2023/2023-01-24/DSCF2859.RAF|

#### 2. Renamed

`Logs/YYYY/YYYYmmddTHHMMSS-renamed.csv`

|Original photo filename|Updated photo filename|Sidecar filename|
|-|-|-|
|DSCF2859.RAF|20230124-DSCF2859.RAF|20230124-DSCF2859.xmp|

#### 3. Rejected

`Logs/YYYY/YYYYmmddTHHMMSS-rejected.csv`

|Photo filename,Sidecar filename|
|-|-|
|20230124-DSCF2859.RAF|20230124-DSCF2859.xmp|

#### 4. Selected

`Logs/YYYY/YYYYmmddTHHMMSS-selected.csv`

|Path to photo|Path to sidecar|
|-|-|
|2023/2023-01-24/DSCF2859.RAF|2023/2023-01-2420230124-DSCF2859.xmp|

#### 5. Reviewed (non-rejected, non-selected)

`Logs/YYYY/YYYYmmddTHHMMSS-reviewed.csv`

|Path to photo|Path to sidecar|
|-|-|
|2023/2023-01-24/DSCF2859.RAF|2023/2023-01-24/DSCF2859.xmp|

### References

- The FastRawViewer approach to flattening / linearizing raw files is described in multiple blog posts and articles; this blog post has the most detailed description of the actual metadata tag changes used to accomplish it: <https://www.fastrawviewer.com/blog/red_flowers_photography_to-see-the-real-picture>

### Tools

- `qsv`: <https://github.com/jqnatividad/qsv>, `brew install qsv`
- `trash`: <https://hasseg.org/trash/>, `brew install trash`
