#!/usr/bin/env bash

# =============================================================================
# Apollo Perception Model Installation Script (Container Side)
#
# This script is intended to be run *inside* the Apollo development container
# to download and install default perception models using the 'amodel' tool.
# It will attempt to install ALL default models defined in the script.
# The FAST_MODE logic has been removed as requested.
# =============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Exit if any command in a pipeline fails.
set -o pipefail

# Assuming standard Apollo container setup
APOLLO_ROOT_DIR="/apollo"

info "Installing perception models inside the container..."

# Check if amodel tool is available
# This script assumes amodel has been installed previously (e.g., by a tool
# installation script or during the container image build).
if ! command -v amodel &> /dev/null; then
    error "amodel command not found. Please ensure amodel is installed in the container."
    error "You might need to run a tool installation script first."
    exit 1 # Exit if the prerequisite tool is missing
fi
info "amodel tool found. Proceeding with model installation."

# Define the model repository base URL
MODEL_REPOSITORY="https://apollo-pkg-beta.cdn.bcebos.com/perception_model"

# Define the list of default models to install (ALL models, regardless of FAST_MODE)
DEFAULT_INSTALL_MODEL=(
    "${MODEL_REPOSITORY}/tl_detection_caffe.zip"
    "${MODEL_REPOSITORY}/horizontal_caffe.zip"
    "${MODEL_REPOSITORY}/quadrate_caffe.zip"
    "${MODEL_REPOSITORY}/vertical_caffe.zip"
    "${MODEL_REPOSITORY}/darkSCNN_caffe.zip"
    "${MODEL_REPOSITORY}/cnnseg16_caffe.zip"
    "${MODEL_REPOSITORY}/3d-r4-half_caffe.zip"
)

# Assign the list of models to process
local models_to_install=("${DEFAULT_INSTALL_MODEL[@]}")

# Check if the list is empty
if [ "${#models_to_install[@]}" -eq 0 ]; then
    warning "No models defined in the DEFAULT_INSTALL_MODEL list to install."
else
    info "Starting model download and installation for ${#models_to_install[@]} models..."
    # Loop through the list and install each model
    for model_url in "${models_to_install[@]}"; do
        info "  Attempting to install model: ${model_url}"
        # 'amodel install -s' downloads and installs the model silently/non-interactively.
        # The models are typically installed to /opt/apollo/data/models
        if ! amodel install "${model_url}" -s; then
            # If a model fails, issue a warning and continue with the next one,
            # rather than failing the entire script. Adjust this behavior
            # (exit or continue) based on how critical individual model failures are.
            warning "  Failed to install model: ${model_url}. Installation for this model skipped."
            # Optionally, you could log failed models to a file
            # echo "${model_url}" >> "${APOLLO_ROOT_DIR}/failed_model_installs.log"
        else
            info "  Successfully installed model: ${model_url}."
        fi
    done
    info "Finished attempting to install models."

    # Provide a summary if there were failures (optional)
    # if [ -f "${APOLLO_ROOT_DIR}/failed_model_installs.log" ]; then
    #     warning "Some models failed to install. Check ${APOLLO_ROOT_DIR}/failed_model_installs.log for details."
    # fi
fi

ok "Perception model installation script finished."
