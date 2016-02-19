# Be sure to restart your server when you modify this file.

# we do not secure the session cookie here so we can still publish non-ssl
# sites with a session (which is necessary even for the simplest comment form
# due to csrf protection). Secure cookies instead should be enforced per hostname by
# a middleware, i.e. the rack-tls-tools lib which I use:
# https://github.com/jkraemer/rack-tls_tools
Rails.application.config.session_store :cookie_store, key: '_session'
