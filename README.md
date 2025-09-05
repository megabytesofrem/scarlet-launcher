<div align="center">
  <img width="128px" height="128px" src="resources/icon.png"></img>
  <h1>Scarlet</h1>
  <p>THCRAP powered launcher for Touhou games for Linux.</p>

  <table>
    <td><img src="screenshots/ui_01.png" alt="Screenshot of Scarlet Launcher" width="300"></td>
    <td><img src="screenshots/ui_02.png" alt="Screenshot of Scarlet Launcher" width="300"></td>
  </table>
</div>

## Installation

Installation is handled via `CMake`.
By default `cmake --install build` will install to `/usr/local/bin`.

To install to a different directory, set `-DCMAKE_INSTALL_PREFIX` e.g
`cmake -DCMAKE_INSTALL_PREFIX=/usr --install build`

## Steam Deck?

Flatpak support for the Steam Deck is being looked into, as is controller
support. Until then, you can build the application locally by installing to `~/.local/share/bin` and adding this to `PATH`.

## Requirements

- A C++ compiler (`gcc/g++`) and `cmake`
- QT development libraries, will depend on distro

## Credits

- Touhou Patch Center for making thcrap
- Flags are provided by https://flagpedia.net
