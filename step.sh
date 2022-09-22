#!/bin/bash
set -ex

# Required parameters
if [ -z "${eschecker_token}" ] ; then
  echo " [!] Missing required input: eschecker_token"
  exit 1
fi

if [ -z "${eschecker_app_id}" ] ; then
  echo " [!] Missing required input: eschecker_app_id"
  exit 1
fi

if [ -z "${eschecker_campaign_id}" ] ; then
  echo " [!] Missing required input: eschecker_campaign_id"
  exit 1
fi

if [ -z "${upload_path}" ] ; then
  echo " [!] Missing required input: upload_path"
  exit 1
fi


if [[ "$OSTYPE" == "darwin"* ]]; then
  curl https://downloads.eschecker.io/eschecker-cli/latest/esc-macos -o ./eschecker
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if [[ -f "/etc/alpine-release" ]]; then
    curl https://downloads.eschecker.io/eschecker-cli/latest/esc-alpine -o ./eschecker
  else
    curl https://downloads.eschecker.io/eschecker-cli/latest/esc-linux -o ./eschecker
  fi
fi

chmod +x ./eschecker

if [[ $upload_path == *.ipa ]]
then
    platform="ios"
fi

if [[ $upload_path == *.apk ]]
then
    platform="android"
fi

./eschecker application upload-binary --app-id $eschecker_app_id --file ${upload_path} --platform $platform
RUN_ID=$(./eschecker campaign run --app-id=$eschecker_app_id --campaign-id=$eschecker_campaign_id --platform $platform)
./eschecker run wait   --run-id $RUN_ID --app-id=$eschecker_app_id --platform $platform
./eschecker run report --run-id $RUN_ID --app-id=$eschecker_app_id --platform $platform
./eschecker run report --run-id $RUN_ID --app-id=$eschecker_app_id --platform $platform --format pdf

PDFPATH=$(ls -l *.pdf | awk '{ print $9 }' | head -1)

#
# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
envman add --key eschecker_pdf_report --value $PDFPATH

# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.
