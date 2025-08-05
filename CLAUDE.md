## Project

This app is `wildfire`, a standalone python script that uses a `uv` shebang with all dependencies to download Canadian wildfire data from a website and create composite images showing the fire perimiter for one to many days.

example command: 

    ./wildfire 2025-08-01 2025-08-04 -o 2025 -z 6 -w 9 -h 4

will create 4 images, one for each day between August 1st 2025 and August 4th 2025 at a zoom level of 6, a tile width of 9 and a tile height of 4, and it will put these images in the output directory `2025`

This command:

    ./wildfire 2025-08-01 -o 2025 -z 6 -w 9 -h 4

does the same thing, but only for August 1st

# TODO list

- new ideas that we want to implement are in @TODO.md.  
- You can edit this file to add new ideas.  
- Ted should be consulted with any questions before implementation of these ideas.

## Git Workflow
- As we make progress, commit changes to git with a descriptive message

## Comments
- Comments must be evergreen. 
  - They should talk about the current state of the code, not changes that were made from prior versions that are no longer present.