.PHONY: default install version release
.MAIN: default

SHELL := fish

default:

install:
	./installer -l

version:
	@string match -qr "major|minor|patch|auto" -- "$(type)";\
		or begin;\
			echo -e "\x1b[31m------- Usage: make tag type=(major|minor|patch|auto) -------\x1b[0m";\
			and exit 1;\
		end;

	cambi change $$(cat ./version) $(type) > ./version

release:
	@test -z "$(git status -s 2>/dev/null)";\
		or begin;\
			echo -e "\x1b[31m------- Before triggering the workflow, make sure that the GIT branch is clean and pushed. -------\x1b[0m";\
			and exit 1;\
		end;

	git push origin main
	gh release create v$$(cat ./version) --generate-notes
