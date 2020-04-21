# Pleb
A cooperative project to write a fancy cross platform card game with various AI styles.

# Table of Contents

1. [About](#about)
1. [Screenshots](#screenshots)
1. [Documentation](#documentation)
1. [Development](#development)
1. [Licenses](#licenses)

### About
Pleb is an implementation of the popular German card game **Arschloch** and English card game **President**. See at the [documentation](#documentation) for common rules.

It is based on the former Windows version [arschloch3d](https://sourceforge.net/projects/arschloch3d/) which uses [Direct3D](https://en.wikipedia.org/wiki/Direct3D).

### Screenshots
* Android:
<img src="docs/imgs/screenshot_android-1920x1080.png" width="30%">

* IOS:

### Documentation
* [Arschloch Rules](https://de.wikipedia.org/wiki/Arschloch_(Kartenspiel)) auf Deutsch
* [President Rules](https://en.wikipedia.org/wiki/President_(card_game)) in English


### Development
1. [Changes](#changes)
1. [ToDo](#todo)
1. [Architecture](#architecture)
1. [CI Continuous Integration](#CI)
1. [Dependencies](#dependencies)


#### Changes

#### ToDo
* use from Felgo independent multi-player cross platform system. Proposals:
    - [Google Play Game Services](https://developers.google.com/games/services/) - unfortunately deprecated

#### Architecture
![Diagram](docs/PlebArchitecture.svg)

(still early version of drawing, and [editable](https://app.diagrams.net/?mode=github)

#### CI
* with Felgo comes [Felgo Cloud](https://felgo.com/pricing) for individual developers that supports [android deployment](https://felgo.com/doc/felgo-deployment-android/)
* f-droid as deployment: [Publishing Nightly Builds](https://f-droid.org/de/docs/Publishing_Nightly_Builds/)

#### Dependencies
* [Felgo](https://felgo.com/): Multiplayer

### Licenses
* Software:
   * Felgo license: https://felgo.com/pricing
* Graphics:
   * Background image: "Secessione della plebe sul Monte Sacro" Gravur von B. Barloccini, 1849, from Wikipedia as [public domain](https://commons.wikimedia.org/wiki/File:Secessio_plebis.JPG).
* Sound/Music:
   * Music: Bensound.com
   * Sound: freesound.org


