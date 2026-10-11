# OMS trading workspace commands. Run `make` to see them.
#
#   make run                      Benemoy on UAT
#   make run ENV=prod             Benemoy on production servers
#   make run APP=fakhrul          another broker-house app
#   make appbundle                Play Store bundle (production)

APP ?= benemoy
ENV ?= uat

# Release builds default to production unless ENV is given explicitly.
RELEASE_ENV = $(if $(filter command line environment,$(origin ENV)),$(ENV),prod)

FLUTTER = fvm flutter
DART = fvm dart

.DEFAULT_GOAL := help
.PHONY: help setup apps devices doctor run apk appbundle ipa pods check analyze test validate new-app clean

help: ## Show available commands
	@echo "Usage: make <command> [APP=benemoy] [ENV=uat|prod]\n"
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
	@echo "\nApps: $$(ls apps | tr '\n' ' ')"

setup: ## First time / after pulling: pinned Flutter for IDE + all dependencies
	fvm use --skip-pub-get --force
	$(DART) run melos bootstrap

apps: ## List broker-house apps
	@ls apps

devices: ## List phones, emulators and simulators
	$(FLUTTER) devices

doctor: ## Check the Flutter/Xcode/Android setup
	$(FLUTTER) doctor

run: _env ## Run on a connected device (default: Benemoy, UAT)
	cd apps/$(APP) && $(FLUTTER) run -t lib/main_$(ENV).dart --dart-define-from-file=env/$(ENV).json

apk: ## Build a release APK (default: production)
	@$(MAKE) --no-print-directory _env ENV=$(RELEASE_ENV)
	cd apps/$(APP) && $(FLUTTER) build apk --release -t lib/main_$(RELEASE_ENV).dart --dart-define-from-file=env/$(RELEASE_ENV).json

appbundle: ## Build the Play Store bundle (default: production)
	@$(MAKE) --no-print-directory _env ENV=$(RELEASE_ENV)
	cd apps/$(APP) && $(FLUTTER) build appbundle --release -t lib/main_$(RELEASE_ENV).dart --dart-define-from-file=env/$(RELEASE_ENV).json

ipa: ## Build the App Store archive (default: production)
	@$(MAKE) --no-print-directory _env ENV=$(RELEASE_ENV)
	cd apps/$(APP) && $(FLUTTER) build ipa --release -t lib/main_$(RELEASE_ENV).dart --dart-define-from-file=env/$(RELEASE_ENV).json

check: analyze test validate ## Analyze, test and validate everything

analyze: ## Static analysis (warnings fail; oms_shared only fails on errors)
	$(DART) run melos run analyze
	$(DART) run melos run analyze:legacy

test: ## Run all tests (unit + widget/UI tests)
	cd packages/core/broker_config && $(DART) test
	cd packages/shared/oms_shared && $(FLUTTER) test

validate: ## Check env files, brand assets and app ids of every app
	$(DART) run tool/validate_apps.dart

new-app: ## Create a broker app: make new-app ID=x NAME="X Ltd" ANDROID_ID=com.x.app IOS_ID=com.x.app
	$(DART) run tool/new_app.dart --id "$(ID)" --name "$(NAME)" --android-id "$(ANDROID_ID)" --ios-id "$(IOS_ID)"

pods: ## Reinstall iOS pods when an iOS build complains about pods
	cd apps/$(APP) && $(FLUTTER) pub get
	cd apps/$(APP)/ios && pod install --repo-update

clean: ## Fix strange build errors: wipe build outputs and iOS pods of the app
	cd apps/$(APP) && $(FLUTTER) clean
	rm -rf apps/$(APP)/ios/Pods
	cd apps/$(APP) && $(FLUTTER) pub get

_env:
	@test -d apps/$(APP) || (echo "No app 'apps/$(APP)'. Apps: $$(ls apps | tr '\n' ' ')" && exit 1)
	@test "$(ENV)" = uat -o "$(ENV)" = prod || (echo "ENV must be uat or prod" && exit 1)
	@test -f apps/$(APP)/env/$(ENV).json || (echo "Missing apps/$(APP)/env/$(ENV).json — copy apps/$(APP)/env/example.json and fill it in." && exit 1)
