HyperMike
==============

Frontend for my arcade cabinet

Getting Started
---------------

```bash
$ npm install
$ npm run compiler
# Ctrl-C once assets have been compiled
$ (cd _public && npm install)
# Configure config.yml before running! See [Configuration](#Configuration)
$ npm run app
```

Configuration
-------------

I've included the entire MAME game database inside of `app/assets/config/MAME-full.xml`.
Remove games that you don't want showing up and save to `app/assets/config/MAME.xml`.

I've included a sample config in `app/assets/config/config.sample.yml`

Copy that to `config.yml` and tailor it to your needs. This file is required to run the arcade.

### Themes

Supports Hyperspin wheel and background themes. Be sure to set the location of your themes in config.yml. Folder should be set up like such:

```
dkong/
---dkong.png       # Wheel image
---Background.png  # Background
---Theme.xml       # Animation configuration
```

Building
---------

```bash
$ npm run deploy
```
Look for the release in `dist/releases`
