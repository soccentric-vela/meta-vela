SUMMARY = "Vela OS image for consumer-electronics deployments"
DESCRIPTION = "Full-featured embedded Linux image (generic x86-64) with A/B OTA, gRPC, and hardware interface tools, tuned for the consumer-electronics vertical."
LICENSE = "MIT"

require recipes-core/images/vela-image.bb
require recipes-core/images/vela-image-common.inc

IMAGE_INSTALL:append = "     packagegroup-core-full-cmdline "
