#!/bin/sh

#  ci_post_clone.sh
#  WeatherIsMyMood
#
#  Created by HappyDuck on 3/7/24.
#  

FOLDER_PATH="Volumes/workspace/repository"
CONFIG_FILE_NAME="Config.xcconfig"
CONFIG_FILE_PATH="$FOLDER_PATH/$CONFIG_FILE_NAME"

# Add environment variables to xcconfig.
echo "OPEN_WEATHER_API_KEY = $OPEN_WEATHER_API_KEY" >> "$CONFIG_FILE_PATH"

cat "$CONFIG_FILE_PATH"

