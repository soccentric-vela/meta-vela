# Drop the SM6115 (RB2) specific kernel patches that do not apply cleanly
# against the linux-yocto 6.6 kernel used by meta-qcom scarthgap, and that
# are irrelevant to the Vela target (RB3 Gen 2 / QCS6490).
#
# The `0001-iommu-arm-smmu-qcom-Add-SM6115-MDSS-compatible.patch` from
# meta-qcom's linux-yocto_6.6.bbappend fails to apply (the arm-smmu-qcom
# driver context in 6.6.144 has moved on).  It is qrb4210-rb2 (SM6115)
# specific and is not needed for the QCS6490, so drop it from SRC_URI.
SRC_URI:remove = "file://qrb4210-drivers/icc/0001-iommu-arm-smmu-qcom-Add-SM6115-MDSS-compatible.patch"
