#!./.venv/bin/python

from pywnp import WNPRedux
import time
import os
import sys

# Custom logger, type can be 'Error', 'Debug' or 'Warning'
def logger(type, message):
    print(f'{type}: {message}')

# Start WNP, providing a port, version number and a logger

# Write the current title to the console and

def daemon():
    WNPRedux.start(1234, '1.0.0', logger)

    prev_cover = ''
    while True:
        cover=WNPRedux.media_info.cover_url

        if cover != prev_cover:
            prev_cover = cover
            print('Downloading cover...')
            print(cover)
            os.system(f'{os.path.expanduser("~/.config/eww/scripts/music_helper.sh")} --parse_cover "{cover}"')
            sys.stdout.flush()

        # You don't need to check for `supports_play_pause`,
        # but it's good to know about.
        time.sleep(1)

try:
    print("Started WebNowPlaying cover daemon!")
    sys.stdout.flush()
    daemon()
except:
    print("Stopping...")
    # Stop WNP and restart
    WNPRedux.stop()
    # daemon()
