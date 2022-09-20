import subprocess, time, sys, os
def run(cmd, flag=0, outfile=None):
    backstage = ''
    if flag != 0:
        backstage = '&'
    print '##[%s]##\n%s %s' %(time.strftime("%H:%M:%S", time.localtime()), cmd, backstage)
    if outfile is not None:
        fout = open(outfile,'w')
        p = subprocess.Popen(cmd, shell=True, stdout=fout, stderr=fout)
    else:
        p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if flag == 0:
        stdout_data, stderr_data = p.communicate()
        if p.returncode != 0:
            raise RuntimeError("%r failed, status code %s stdout %r stderr %r" % (cmd, p.returncode, stdout_data, stderr_data))
        return stdout_data
    else:
        return p
	#p.wait()

def checkfile(path):
    if not os.path.isfile(path):
        print 'the %s file is not exists, please check.' %path
        sys.exit(2)

def checkdir(path):
    if not os.path.isdir(path):
        print '##[%s]##\nmkdir -p %s' %(time.strftime("%H:%M:%S", time.localtime()), path)
        os.makedirs(path)

def pdf2png(name):
    run('convert -density 300 %s.pdf %s.png' %(name, name))
