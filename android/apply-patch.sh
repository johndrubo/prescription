#!/bin/bash
        # This script will apply a patch to a local dependency if needed.
        set -e

        function apply_patch() {
            local patch_file="$1"
            local target_dir="$2"

            echo "Applying patch ${patch_file} to ${target_dir}"

            # Check if the patch file exists
            if [ ! -f "${patch_file}" ]; then
              echo "Error: Patch file ${patch_file} not found."
              exit 1
            fi

            # Apply the patch
            pushd "${target_dir}" > /dev/null
            patch -p1 -i "${patch_file}"
            popd > /dev/null
        }

        # Path to your patch file
        PATCH_FILE="./remove-package-attribute.patch"

        # Path to the AndroidManifest.xml file in the library
        TARGET_DIR="C:/Users/johnd/AppData/Local/Pub/Cache/hosted/pub.dev/google_mlkit_smart_reply-0.9.0/android/src/main/"

        # Ensure the TARGET_DIR is cleaned for safety
        if [ ! -d "$TARGET_DIR" ]; then
            echo "Target directory ${TARGET_DIR} does not exist. Check if the path is correct."
            exit 1
        fi

        apply_patch "$PATCH_FILE" "$TARGET_DIR"

        echo "Patch applied successfully."