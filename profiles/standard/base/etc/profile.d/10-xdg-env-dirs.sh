# XDG Freedesktop specification for user directories
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables
# Although the specification calls out that if not set you should simply fall back on directory
# variants based on $HOME i'm codifying it here to make is simpler

# $XDG_CONFIG_HOME defines the base directory relative to which user-specific configuration files
# should be stored. If $XDG_CONFIG_HOME is either not set or empty, a default equal to $HOME/.config
# should be used.
export XDG_CONFIG_HOME="${HOME}/.config"

# $XDG_DATA_HOME defines the base directory relative to which user-specific data files should be
# stored. If $XDG_DATA_HOME is either not set or empty, a default equal to $HOME/.local/share should
# be used.
export XDG_DATA_HOME="${HOME}/.local/share"

# $XDG_STATE_HOME defines the base directory relative to which user-specific state files should be
# stored. If $XDG_STATE_HOME is either not set or empty, a default equal to $HOME/.local/state should
# be used.
export XDG_STATE_HOME="${HOME}/.local/state"

# $XDG_CACHE_HOME defines the base directory relative to which user-specific non-essential data files
# should be stored. If $XDG_CACHE_HOME is either not set or empty, a default equal to $HOME/.cache
# should be used.
export XDG_CACHE_HOME="${HOME}/.cache"
