NODE_VERSION = $(shell node --version)
GROUP = $(shell id -gn)

install:
	@echo "Setting up Claude Code UI as systemd user service..."

	# Copy .env.example to .env if it doesn't exist
	@if [ ! -f .env ]; then \
		echo "Creating .env file from .env.example..."; \
		cp .env.example .env; \
	else \
		echo ".env file already exists, skipping..."; \
	fi

	# Run npm install
	@echo "Installing npm dependencies..."
	npm install

	# Create systemd user service directory if it doesn't exist
	@mkdir -p ~/.config/systemd/user

	# Generate systemd service file from template
	@echo "Generating systemd user service file from template..."
	@cp claude-code-ui.service.template claude-code-ui.service
	@sed -i 's|$$HOME|$(HOME)|g' claude-code-ui.service
	@sed -i 's|$$PWD|$(PWD)|g' claude-code-ui.service
	@sed -i 's/$$NODE_VERSION/$(NODE_VERSION)/g' claude-code-ui.service
	@cp claude-code-ui.service ~/.config/systemd/user/

	# Reload systemd user daemon
	@echo "Reloading systemd user daemon..."
	systemctl --user daemon-reload

	# Enable the service
	@echo "Enabling claude-code-ui service..."
	systemctl --user enable claude-code-ui.service

	@echo ""
	@echo "Installation complete! You can now:"
	@echo "  Start the service: make start"
	@echo "  Check status:      make status"
	@echo "  View logs:         make logs"
	@echo "  Stop the service:  make stop"

start:
	@echo "Starting claude-code-ui service..."
	systemctl --user start claude-code-ui.service

stop:
	@echo "Stopping claude-code-ui service..."
	systemctl --user stop claude-code-ui.service

status:
	systemctl --user status claude-code-ui.service

logs:
	journalctl --user -u claude-code-ui -f

.PHONY: install start stop status logs
