.PHONY: init update

init:
	@bash ./init.sh --no-exec && \
	([ -z "$$SSH_CONNECTION" ] && [ -z "$$SSH_CLIENT" ] && [ -z "$$SSH_TTY" ] && \
	[ "$$(uname)" = "Darwin" ] && [ -d "/Applications/Ghostty.app" ] && \
	(echo "" && echo "Opening Ghostty terminal..." && open -a Ghostty 2>/dev/null) || true) && \
	(which zsh >/dev/null 2>&1 && exec zsh -l || echo "✓ Setup complete. Please restart your shell.")

update:
	@bash ./update.sh
