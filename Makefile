.PHONY: init update

init:
	@bash ./init.sh --no-exec && (which zsh >/dev/null 2>&1 && exec zsh -l || echo "✓ Setup complete. Please restart your shell.")

update:
	@bash ./update.sh
