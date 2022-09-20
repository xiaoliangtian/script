import subprocess, time, sys, os
import codecs
sys.stdout = codecs.getwriter("utf-8")(sys.stdout.detach())
sys.stdin = codecs.getwriter('utf-8')(sys.stdin.detach())
def run(cmd, flag=0, cwdDir=None, outfile=None):
    backstage = ''
    if flag != 0:
        backstage = '&'
    print ('##[%s]##\n%s %s' %(time.strftime("%H:%M:%S", time.localtime()), cmd, backstage))
    if outfile is not None:
        p = subprocess.Popen(cmd, shell=True, stdout=fout, stderr=fout,cwd=cwdDir)
    else:
        p = subprocess.Popen(cmd, shell=True,stdout=subprocess.PIPE, stderr=subprocess.PIPE,cwd=cwdDir)

    if flag == 0:
        stdout_data, stderr_data = p.communicate()
        if p.returncode != 0:
            raise RuntimeError("%r failed, status code %s stdout %r stderr %r" % (cmd, p.returncode, stdout_data, stderr_data))
        return stdout_data
    else:
        p.communicate()
        # p.wait()
        return p


def checkfile(path):
    if not os.path.isfile(path):
        print ('the %s file is not exists, please check.' %path)
        sys.exit(2)

def checkdir(path):
    if not os.path.isdir(path):
        print ('##[%s]##\nmkdir -p %s' %(time.strftime("%H:%M:%S", time.localtime()), path))
        os.makedirs(path)

def pdf2png(name):
    run('convert -density 300 %s.pdf %s.png' %(name, name))
