import os
import sys
import ntpath
import eyed3

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

def ext(path):
    return ntpath.basename(path).split('.')[-1]

def noExt(path):
    return ''.join(ntpath.basename(path).split('.')[:-1])

if len(sys.argv)>1:
    savePath=sys.argv[1]
else:
    savePath=''
imageFormat = 'jpg'
audioFormat = 'mp3'

names = {}

for base, dirs, files in os.walk(savePath):
    for file in files:
        if ext(file) in [imageFormat]:
            if noExt(file) in names:
                names[noExt(file)]['image'] = file
                continue
            names[noExt(file)] = {'image': file}
        if ext(file) == audioFormat:
            if noExt(file) in names:
                names[noExt(file)]['audio'] = file
                continue
            names[noExt(file)] = {'audio': file,}

for key in names:
    item = names[key]
    if len(item.keys())<2:
        # print(key)
        # print('--error-->image or audio not found')
        continue

    picPath = ntpath.join(savePath, item['image']).replace('\\','/')
    audioPath = ntpath.join(savePath, item['audio']).replace('\\','/')

    audio = eyed3.load(audioPath)
    if audio == None or audio.tag == None:
        audio.initTag()


    audio.tag.images.set(3, open(picPath, 'rb').read(), 'image/jpeg')

    audio.tag.save()

    print(bcolors.OKCYAN+key+bcolors.ENDC)
    print(f'{bcolors.HEADER}--image-->{bcolors.ENDC}{picPath}')
    print(f'{bcolors.HEADER}--audio-->{bcolors.ENDC}{audioPath}')


