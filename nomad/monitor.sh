 multitail -l "/usr/bin/nomad alloc logs -job -stderr -f -tail mercure router" \
	-L "/usr/bin/nomad alloc logs -job -stderr -f -tail mercure processor" \
	-L "/usr/bin/nomad alloc logs -job -f -tail mercure receiver" \
	-L "/usr/bin/nomad alloc logs -job -stderr -f -tail mercure-ui" \
	-L "/usr/bin/nomad alloc logs -job -stderr -f -tail mercure dispatcher"
