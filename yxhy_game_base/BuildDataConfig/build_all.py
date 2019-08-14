
import sys
import os
import subprocess 
#import win32api
#import win32con

def listAllFiles(mydir):
    ret = [] 
    filterNames = ['xlsc_lua','xlsc_cs','AddBuildFilesAndMetasToSVN','generate_all', 'echo', 'build_all_xlsc', 'A_build_all']
    for filename in os.listdir(mydir):
        filepath = os.path.join(mydir, filename)
        if os.path.isfile(filepath):
            isFilter = 0
            for filterName in filterNames:
                if (filename.find(filterName) != -1):
                    isFilter = 1
            if (isFilter == 0 and filename.find('.bat') != -1):
                ret.append(filepath)
    return ret  


########################################__main__###########################################
if __name__ == '__main__' :
    #walk_dir(True)
    print os.path.abspath('.')
    ret = listAllFiles(os.path.abspath('.'))
    echoBat = os.path.join(os.path.abspath('.'), 'echo.bat')

    for batFile in ret:
        print batFile
        p = subprocess.Popen("cmd.exe /c" + batFile, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)  
        curline = p.stdout.readline()  
        while(curline != b''):  
            print(curline)  
            curline = p.stdout.readline()  
            #win32api.keybd_event(86,0,0,0)
        #win32api.keybd_event(86,0,0,0)
        p.wait()  
        #win32api.keybd_event(86,0,0,0)
        print(p.returncode)



        