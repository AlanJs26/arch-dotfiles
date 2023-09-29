import time 
import ntpath
import os
import youtube_dl 
import random
from mympv import MyMPV 
import threading
from addMetadata import noExt

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

playlistUrls = [
    'https://music.youtube.com/watch?v=8nwhXb3zgcY&list=RDAMVM8nwhXb3zgcY',
    'https://music.youtube.com/watch?v=19QkG2TTI-s&list=RDAMVM19QkG2TTI-s',
    'https://music.youtube.com/watch?v=nwyVGjbAtVY&list=RDAMVMnwyVGjbAtVY',
    'https://music.youtube.com/watch?v=c4hGn2sTUh0&list=RDAMVMc4hGn2sTUh0',
    'https://music.youtube.com/watch?v=QKdp5O8O2Qo&list=RDAMVMQKdp5O8O2Qo',
    'https://music.youtube.com/watch?v=1buCERP_zOo&list=RDAMVM1buCERP_zOo',
    'https://music.youtube.com/watch?v=XQ5wFL2NVVA&list=RDAMVMXQ5wFL2NVVA',
    'https://music.youtube.com/watch?v=pN1MiYnyIAI&list=RDAMVMpN1MiYnyIAI',
    'https://music.youtube.com/watch?v=Qd4yQFMWdz4&list=RDAMVMQd4yQFMWdz4',
]

ownpath = ntpath.split(__file__)[0] or './'
savePath = '/home/alan/Documentos/tools/mpvYtBuffer/musics'
bufferSize = 1
playHist = []
mpv=False
possibleIndexes = []
currentPlaylistUrl = ''
bs='\\'
firsttime=True

def resetIndexesList():
    global possibleIndexes
    global currentPlaylistUrl
    possibleIndexes = [f'{i}' for i in range(25)]
    currentPlaylistUrl = playlistUrls[random.randint(0, len(playlistUrls)-1)]

def countFiles():
    totalFiles = 0
    totalDir = 0

    for base, dirs, files in os.walk(savePath):
        for directories in dirs:
            totalDir += 1
        for Files in files:
            totalFiles += 1

    return totalFiles

def downloadVideo(num=bufferSize): 
    print(bcolors.OKBLUE + f'\nSalvando em: {savePath}')
    for i in range(num):
        global currentPlaylistUrl
        if len(possibleIndexes)<=1:
            resetIndexesList()

        playlistIndex = possibleIndexes.pop(random.randint(0,len(possibleIndexes)-1)) 

        opts = {
            'format': 'bestaudio',
            'progress_hooks': [hook],
            'writethumbnail': True,
            # 'embedthumbnail': True,
            'outtmpl': f'{savePath}/%(title)s.%(ext)s',
            'nooverwrites': True,
            'ignoreerrors': True,
            'postprocessors': [
                {
                    'key': 'FFmpegVideoConvertor',
                    'preferedformat': 'mp3'
                },
                {
                    'key': 'MetadataFromTitle',
                    'titleformat': '%(artist)s'
                },
                {
                    'key': 'ExecAfterDownload',
                    'exec_cmd': f'bash {ntpath.join(ownpath, "crop.sh").replace(bs,"/")} {ntpath.abspath(savePath).replace(bs,"/")}/ {ntpath.abspath(ownpath).replace(bs,"/")}/'
                }
            ],
            # 'playlistrandom': True,
            'playlist_items': f'{playlistIndex}',
            # 'playlist_items': '5',
            # 'playlist_items': ','.join([str(i) for i in range(25)]),
            # 'noplaylist': True,
            'quiet': True,
        }
        ytdl = youtube_dl.YoutubeDL(opts)
        try:
            ytdl.download([currentPlaylistUrl])
        except:
            print('error on download sequence')
        
numOfFilesOnStart = countFiles()

def hook(d):
    if(d['status'] == 'finished'):
        playHist.append(d['filename'])

        os.system('clear')
        print(bcolors.OKCYAN + 'Histórico\n' + bcolors.ENDC)
        for item in playHist:
            print(ntpath.basename(item)[:-4])

        print(bcolors.OKGREEN + '\nParametros\n' + bcolors.ENDC)
        print(f'Músicas pré-carregada(s): {bufferSize}')
        print(f'Músicas já baixadas: {countFiles()}')
        print(f'Pasta de Músicas: {ntpath.basename(savePath)}')

        basename=noExt(d['filename'])
        extension='mp3'
        global firsttime

        if mpv and mpv.is_running():
            try:
                mpv.command(f"loadfile", f'{savePath}/{basename}.{extension}', 'append')
                if len(playHist)==1 and firsttime:
                    firsttime=False
                    mpv.set_property('playlist-pos', numOfFilesOnStart-1)
                    mpv.play()
            except:
                print('error on mpv playback')

mpv = MyMPV(savePath, downloadVideo)
# downloadVideo(bufferSize)


def loopFunc():
    global mpv
    while True:
        time.sleep(1)
        if len(playHist)>=2 and not mpv.is_running():
            os._exit(1)

loop = threading.Thread(target=loopFunc)
loop.start()

