#!/bin/bash

# Kill any existing Jekyll processes
pkill -f jekyll 2>/dev/null

# Start Jekyll on port 4000 with livereload
bundle exec jekyll serve --port 4000 --livereload --drafts --incremental

EOF
