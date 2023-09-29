import sys
import time
import threading

from mpv import MPV


class MyMPV(MPV):
    #-------------------------------------------------------------------------
    # Initialization.
    #-------------------------------------------------------------------------

    # The mpv process and the communication code run in their own thread
    # context. This results in the callback methods below being run in that
    # thread as well.
    def __init__(self, path, fileloadedC):
        # Pass a window id to embed mpv into that window. Change debug to True
        # to see the json communication.
        super().__init__(window_id=None, debug=False)

        self.command("loadfile", path, "append")
        self.set_property("playlist-pos", 0)
        self.fileloadedC = fileloadedC
        # self.loaded = threading.Event()
        # self.loaded.wait()

    #-------------------------------------------------------------------------
    # Callbacks
    #-------------------------------------------------------------------------

    # The MPV base class automagically registers event callback methods
    # if they are specially named: "file-loaded" -> on_file_loaded().
    def on_file_loaded(self):
        # self.loaded.set()
        self.fileloadedC()

    #-------------------------------------------------------------------------
    # Commands
    #-------------------------------------------------------------------------
    # Many commands must be implemented by changing properties.
    def play(self):
        self.set_property("pause", False)

    def pause(self):
        self.set_property("pause", True)

    def seek(self, position):
        self.command("seek", position, "absolute")


if __name__ == "__main__":
    # Open the video player and load a file.
    try:
        mpv = MyMPV(sys.argv[1], print)
    except IndexError:
        raise SystemExit("usage: python example.py <path>")

    # Seek to 5 minutes.
    mpv.seek(300)

    # Start playback.
    mpv.play()

    # Playback for 15 seconds.
    time.sleep(15)

    # Pause playback.
    mpv.pause()

    # Wait again.
    time.sleep(3)

    # Terminate the video player.
    mpv.close()
