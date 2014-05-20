Ms. Pacman's Box
==============

Frontend for my arcade cabinet

Getting Started
---------------

 * Fill `app/assets/themes` with game themes and wheel images.
 * `npm install`
 * `npm run compiler`
 * `cd _public && npm install`
 * `npm run app`

Configuration
-------------

I've included the entire MAME game database inside of `app/assets/config/MAME-full.xml`.
Remove games that you don't want showing up and save to `app/assets/config/MAME.xml`.

### Themes

Supports Hyperspin themes. Folder should be set up like such:

```
dkong/
---dkong.png       # Wheel image
---Background.png  # Background
---Theme.xml       # Animation configuration
```

Launching
---------

Compile with `npm run deploy` to get some bins
