APP_NAME = DevPorts
BUILD_DIR = .build/release
APP_BUNDLE = $(APP_NAME).app
PLIST = com.devports.app.plist
LAUNCH_AGENTS = $(HOME)/Library/LaunchAgents

.PHONY: build bundle install run clean launchagent uninstall-launchagent

build:
	swift build -c release

run:
	swift run

bundle: build
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp Resources/Info.plist $(APP_BUNDLE)/Contents/
	codesign --force --sign - $(APP_BUNDLE)
	@echo "Built $(APP_BUNDLE)"

install: bundle
	cp -R $(APP_BUNDLE) /Applications/
	@echo "Installed to /Applications/$(APP_BUNDLE)"

launchagent: install
	@mkdir -p $(LAUNCH_AGENTS)
	cp $(PLIST) $(LAUNCH_AGENTS)/
	launchctl load $(LAUNCH_AGENTS)/$(PLIST)
	@echo "LaunchAgent installed — app will auto-start on login"

uninstall-launchagent:
	-launchctl unload $(LAUNCH_AGENTS)/$(PLIST) 2>/dev/null
	rm -f $(LAUNCH_AGENTS)/$(PLIST)
	@echo "LaunchAgent removed"

clean:
	swift package clean
	rm -rf $(APP_BUNDLE)
