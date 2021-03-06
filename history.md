# Version 0.2.6
- New vendorize plugin to prefix or postfix vendor scripts to output targets
- Updated plugin api to include an identity callback (optional, but recommended)
- Added support for verbose and minimal logging flags in CLI
- Added support for disabling targets
- Cleaned up CLI output for default log level


# Version 0.2.5
- New server-latency plugin, to simulate server latency in dev server
- Updated prune plugin to build dependency list (parses coffeescript now)
  and whitelists pre-render. So files that are referenced won't be transpiled
- Moved project creation to fgen


# Version 0.2.4
- Added target source path to stylus load_paths
- Tweaked CLI. It shouldn't choke on systems that don't have coffee-script 
  installed globally anymore (What's wrong with you people? :)
- Added configuration option to disable console logging of requests when
  using the dev server
- Added support for callback (treated as plugins) in configuration file --
  This allow for creating an assembot.coffee (or .js, jeez learn to love
  the coffee) for dynamic configuration
- Pruning now works with relative, back reference, paths (../)
- Cleaned up build console output a bit


# Version 0.2.3
- Pruning will now append '/index' and recheck missing modules
- ResourceList won't allow duplicate paths for resources with the same target


# Version 0.2.2
- Reorganized source structure
- Added support for pruning modulelist based on `require`s


# Version 0.2.1
- Bugfixes
- More tests
- Initial docs


# Version 0.2.0
- Reorganized code base
- Added plugin support
- New project boilerplate


# Version 0.1.0
- First release! W00t!