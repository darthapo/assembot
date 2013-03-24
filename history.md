# Version 0.2.5
- New server-latency plugin, to simulate server latency in dev server.


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