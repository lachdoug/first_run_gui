Engines system first run application
-------

This app presents a form (and associated submit routines) for configuring a freshly installed Engines system.

Sinatra app. No DB or persistent directories required.

Environment variables:
- ENV['SYSTEM_API_URL'] ( e.g. "http://127.0.0.1:2380/" )
- ENV['HOSTNAME'] ( current system host name, e.g. "fred" )

Launch the app with: start.rb
