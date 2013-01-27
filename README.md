Ms. Pacman's Box
==============

Frontend for my arcade cabinet

Getting Started
---------------

 * Fill `app/public/themes` with game themes and wheel images.
 * `bundle install`
 * `foreman start`
 * Browse to `http://localhost:3000`

Configuration
-------------

I've included the entire MAME game database inside of `config/MAME-full.xml`.
Remove games that you don't want showing up and save to `config/MAME.xml`.

### Themes

Supports Hyperspin themes. Folder should be set up like such:

```
dkong/
---dkong.png       # Wheel image
---Background.png  # Background
---Theme.xml       # Animation configuration
```
