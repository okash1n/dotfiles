.PHONY: init update

init:
	@bash ./init.sh --no-exec && exec zsh -l

update:
	@bash ./update.sh
