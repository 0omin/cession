# Prefer a swiftly-managed toolchain when present: some Command Line Tools installs
# ship a SwiftPM whose PackageDescription library and swiftmodule disagree, and
# manifests fail to link there. Xcode is not required either way.
SWIFT := $(shell if [ -x "$$HOME/.swiftly/bin/swift" ]; then echo "$$HOME/.swiftly/bin/swift"; else echo swift; fi)

.PHONY: test build run clean

test:
	$(SWIFT) test

build:
	$(SWIFT) build

run:
	$(SWIFT) run CessionApp

clean:
	rm -rf .build build
