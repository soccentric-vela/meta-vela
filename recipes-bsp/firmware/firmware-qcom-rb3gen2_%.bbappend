# Fix the linux-firmware license URL for firmware-qcom-rb3gen2.
#
# The upstream meta-qcom (scarthgap) recipe points at
#   .../linux-firmware.git/plain/LICENSE.qcom
# which is a 404 — the file actually lives under the LICENSES/ directory:
#   .../linux-firmware.git/plain/LICENSES/LICENSE.qcom
#
# The file content (and therefore its md5/sha256) is identical to what the
# recipe's LIC_FILES_CHKSUM / SRC_URI[license.sha256sum] expect, so only the
# path needs correcting.
#
# NOTE: this must re-state the FULL SRC_URI (including the Adreno GPU
# firmware archive that firmware-qcom-adreno.inc normally appends via
# `SRC_URI +=`), otherwise the Adreno firmware is silently dropped and the
# recipe fails at do_install (missing a660_zap.mbn).
SRC_URI = " \
    https://artifacts.codelinaro.org/artifactory/qli-ci/software/chip/qualcomm_linux-spf-1-0/qualcomm-linux-spf-1-0_test_device_public/r1.0_${PV}/QCM6490.LE.1.0/common/build/ufs/bin/${FW_D_NAME}.zip;name=fw \
    https://artifacts.codelinaro.org/artifactory/qli-ci/software/chip/qualcomm_linux-spf-1-0/qualcomm-linux-spf-1-0_test_device_public/r1.0_${PV}/QCM6490.LE.1.0/common/build/ufs/bin/${LICENSE_FILE_PDF};name=licensepdf \
    https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/LICENSES/LICENSE.qcom;name=license \
    ${ADRENO_URI};subdir=adreno;name=adreno \
    "
