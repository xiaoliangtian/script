#!/usr/bin/python2.7 
# -*- coding: utf-8 -*- 

import numpy as np

import sys

import math

from scipy import stats

import os
import argparse
import random

# optional args
parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input', help='input gvcf files, separate with comma')
parser.add_argument("-f", "--dad", required=True, type=int, help="dad column num in input file")
parser.add_argument("-m", "--mom", required=True, type=int, help="mom column num in input file")
parser.add_argument("-s1", "--son1", required=True, type=int, help="son1 column num in input file")
parser.add_argument("-s2", "--son2", required=True, type=int, help="son2 column num in input file")
parser.add_argument("-o1", "--out1",  help="out1")
parser.add_argument("-o2", "--out2",  help="out2")
parser.add_argument("-t", required=True, help="analyse type F or M" )
parser.add_argument("--no_header", action="store_true",default=False, help="whether or not  print a" )

args = parser.parse_args()
if args.input:
    inputFile = args.input
if args.son2:
    sonCol = args.son2

dad = args.dad
mom = args.mom
son1 = args.son1

si = [] 

class HMM:
    def __init__(self, Ann, Btn, Pi, O):
        self.A = np.array(Ann, np.float)#A表示状态转移概率矩阵
        self.B = np.array(Btn, np.float)#B表示观测概率矩阵
        self.Pi = np.array(Pi, np.float)#Pi表示初始状态概率向量
        self.O = np.array(O)#O是对应的观测序列
        self.N = self.A.shape[1]#N表示可能的状态数:2
          
    def viterbi(self):
        T = len(self.O)
        I = np.zeros(T, np.int)#初始化一维矩阵,存放状态序列       
        delta = np.zeros((T, self.N), np.float)  
        psi = np.zeros((T, self.N), np.int)
        
        #print(B)
        #初始化
        for i in range(self.N):
            #print(self.B[0, i])
            delta[0, i] = self.Pi[i] * self.B[0, i]
            psi[0, i] = 0
        #print(delta)

        # 迭代
        for t in range(1, T):
            for i in range(self.N):
                delta[t, i] = self.B[t, i] * np.array( [delta[t-1, j] * self.A[t, j, i] for j in range(self.N)] ).max()
                #delta[t, i] = np.array( self.B[t, i] for i in range(self.N)).max * self.A[t,]
                psi[t,i] = np.array( [delta[t-1, j] * self.A[t, j, i] for j in range(self.N)] ).argmax()
        P_T = round( delta[T-1, :].max(), 20)#最大概率
        I[T-1] = delta[T-1, :].argmax()
        for t in range(T-2, -1, -1):
            I[t] = psi[ t+1, I[t+1] ]
        #print(P_T)
        return(I, P_T) 

#输入家系的vcf文件和单个样本的vcf文件
#得到观测序列Si{pos_hmm, Fgt, Mgt, Pgt, dep_ref, dep_alt} 
#得到胎儿以pos_hmm为键，hap为值的字典ftl,以hq_pos为键，dp为值的字典sam_dp,Si_wndp{}
#aaaaaa, bbbbbb, aabbab, bbaaab, abaaaa, abaaab, abbbab, abbbbb, aaabaa, aaabab, bbabab, bbabbb
#得到在家系中存在多态的SNP位点，即时间长度len(pos_hmm)
def get_si(famvcf):
    global Si
    Si = []
    global ftl, Si_wndp, sam_dp
    Si_wndp, sam_dp, ftl = {}, {}, {}
    global aaaaaa, bbbbbb, aabbab, bbaaab, Sgt
    global abaaaa, abaaab, abbbab, abbbbb, aaabaa, aaabab, bbabab, bbabbb
    aaaaaa, bbbbbb, aabbab, bbaaab = [], [], [], []
    abaaaa, abaaab, abbbab, abbbbb, aaabaa, aaabab, bbabab, bbabbb = [], [], [], [], [], [], [], []
    global pos_hmm, pos_Ee, hq_pos, pos_info
    pos_hmm, pos_Ee, pos_info = [], [], []
    global num_false,num_all
    num_false = 0
    num_all = 0
   
    with open(inputFile,"r") as fr:
        lines = fr.readlines()
        for line in lines:
            items = line.strip().split()
            pos = items[1]         
            if (line[0:5] != "chr11" or (line[0:5] == "chr11" and (int(items[1]) < 5144348 or int(items[1]) > 5347511) )) and items[0] !="#CHROM" and int(items[dad].split(":")[-2])>80 and int(items[sonCol].split(":")[-2]) > 80:
                Fgt = items[dad].split(":")[0]
                Mgt = items[mom].split(":")[0]
                Pgt = items[son1].split(":")[0]
                Sgt = items[sonCol].split(":")[0]
                #FTgt = items[12].split(":")[0]
                num_all += 1    
                p = items[sonCol].split(":")[3].split(",")[0]
                q = items[sonCol].split(":")[3].split(",")[1]
                Si_wndp[pos] = [pos, Fgt, Mgt, Pgt]
                sam_dp[pos] = [p, q]
                if ((Fgt == "0/0" and Mgt == "1/1") or (Fgt == "1/1" and Mgt == "0/0")) and Pgt != "0/1":
                    num_false +=1
                    #print(pos)
                elif ((Fgt == "0/0" and Mgt == "0/1") or (Fgt == "0/1" and Mgt == "0/0")) and Pgt == "1/1":
                    num_false +=1
                    #print(pos)
                elif ((Fgt == "0/1" and Mgt == "1/1") or (Fgt == "1/1" and Mgt == "0/1")) and Pgt == "0/0":
                    num_false +=1
                    #print(pos)
               
                elif Fgt== Mgt == "0/0":
                    #print(pos)
                    aaaaaa.append(pos)
                elif Fgt == Mgt == "1/1":
                    
                    bbbbbb.append(pos)
                elif Fgt == "0/0" and Mgt == "1/1":
                    
                    aabbab.append(pos)
                elif Fgt == "1/1" and Mgt == "0/0":
                    
                    bbaaab.append(pos)
                
                #if Pgt:
                #    Si_wndp[pos] = [pos, Fgt, Mgt, Pgt]
            
            elif items[0] =="#CHROM" and not args.no_header:
                print (items[dad],'\t',items[mom],'\t',items[son1],'\t',items[sonCol],'\n')
		
            elif items[0] !="#CHROM" and int(items[dad].split(":")[-2])>80 and int(items[sonCol].split(":")[-2]) > 80:
                pos = items[1] 
                if items[3] == ".":
                    aaaaaa.append(pos)
                    #print(1)
                    Si_wndp[pos] = [pos, "0/0", "0/0", "0/0"]
                    ftl[pos] = "0/0"
                    #print(Si_wndp[pos])
                else:
                    num_all += 1
                    Fgt = items[dad].split(":")[0]
                    Mgt = items[mom].split(":")[0]
                    Pgt = items[son1].split(":")[0]
                    Sgt = items[sonCol].split(":")[0]
                    #FTgt = items[12].split(":")[0]
                    p = items[sonCol].split(":")[3].split(",")[0]
                    q = items[sonCol].split(":")[3].split(",")[1]
                    Si_wndp[pos] = [pos, Fgt, Mgt, Pgt]
                    sam_dp[pos] = [p, q]
                    if ((Fgt == "0/0" and Mgt == "1/1") or (Fgt == "1/1" and Mgt == "0/0")) and Pgt != "0/1":
                        num_false +=1
                        #print(pos)
                    elif ((Fgt == "0/0" and Mgt == "0/1") or (Fgt == "0/1" and Mgt == "0/0")) and Pgt == "1/1": 
                        num_false +=1
                        #print(pos)
                    elif ((Fgt == "0/1" and Mgt == "1/1") or (Fgt == "1/1" and Mgt == "0/1")) and Pgt == "0/0":   
                        num_false +=1
                        #print(pos)
                    
                    #print(sam_dp[pos])
                    #print(Si_wndp[pos])
                    #ftl[pos] = FTgt
                    elif Fgt== Mgt == "0/0":
                        aaaaaa.append(pos)
                        #print(Si_wndp[pos])
                    elif Fgt == Mgt == "1/1":
                        bbbbbb.append(pos)
                    elif Fgt == "0/0" and Mgt == "1/1":
                        aabbab.append(pos)
                    elif Fgt == "1/1" and Mgt == "0/0":
                        bbaaab.append(pos)    
                    if args.t == "F":                    
                        if Fgt == "0/1" and Mgt == "0/0":
                            if Pgt == "0/0":
                                abaaaa.append(pos)
                                #print(Si_wndp[pos])
                            elif Pgt == "0/1":
                                abaaab.append(pos)
                                #print(Si_wndp[pos])
                        if Fgt == "0/1" and Mgt == "1/1":
                            if Pgt == "0/1":
                                abbbab.append(pos)
                                #print(Si_wndp[pos])
                            elif Pgt == "1/1":
                                abbbbb.append(pos)
                                #print(Si_wndp[pos])
                    if args.t == "M":
                        if Fgt == "0/0" and Mgt == "0/1":
                            if Pgt == "0/0":
                                aaabaa.append(pos)
                                #print(Si_wndp[pos])
                            elif Pgt == "0/1":
                                aaabab.append(pos)
                                #print(Si_wndp[pos])
                        if Fgt == "1/1" and Mgt == "0/1":
                            if Pgt == "0/1":
                                bbabab.append(pos)
                                #print(Si_wndp[pos])
                            elif Pgt == "1/1":
                                bbabbb.append(pos) 
                                #print(Si_wndp[pos])
        #print(len(Si_wndp),len(ftl))#28660
        hq_pos = sam_dp.keys()
        #print hq_pos
    ###get depth of alt and ref of all hq_pos,sam_dp{}
    ###将famvcf文件得到的pos与hq_pos求交集
    ll = [aaaaaa, bbbbbb, aabbab, bbaaab, abaaaa, abaaab, abbbab, abbbbb, aaabaa, aaabab, bbabab, bbabbb]
    for i in range(len(ll)):
        #print(len(ll[i]))
        ll[i] = list( set( ll[i] ).intersection( set( hq_pos ) ) )
        #print(len(ll[i]))
    [aaaaaa, bbbbbb, aabbab, bbaaab, abaaaa, abaaab, abbbab, abbbbb, aaabaa, aaabab, bbabab, bbabbb] = ll
    ##pos for Si
    pos_hmm = []
    for i in [abaaaa, abaaab, abbbab, abbbbb, aaabaa, aaabab, bbabab, bbabbb]:
        #print(len(i))
        pos_hmm = list( set(pos_hmm).union(set(i)))
    pos_hmm.sort(key=lambda d:int(d))    
    #print(pos_hmm)    
    
    ##make ftl qual hmm_pos
    #print(len(pos_hmm), len(ftl), len(pos_Ee), len(Si_wndp), len(sam_dp), len(hq_pos))
        
    ###get observation sequence Si
    for pos in hq_pos:
        if pos in pos_hmm:
            Si_wndp[pos].append(sam_dp[pos][0])
            Si_wndp[pos].append(sam_dp[pos][1])
            #print(Si_wndp[pos])
            Si.append( Si_wndp[pos] )
    #print(len(pos_Ee), len(pos_hmm), len(ftl), len(Si), len(hq_pos), len(sam_dp), len(Si_wndp))
    ##validation of results
    Si.sort(key=lambda x:int(x[0]))
    #print(Si)
    return(Si)        

###from pos_hmm get A matrix with T*2*2(49*2*2)
def get_A(pos):
    T = len(pos)
    A = np.zeros((T, 2,2), np.float)
    Pr = list(range(T))
    #print(T)
    Pr[0] = 0
    for i in range(1, T):
        Pr[i] = ( float(pos[i]) - float(pos[i-1]) )/1000000
                #print(pos[i])
        A[i] = [ [1-Pr[i], Pr[i]], [Pr[i], 1-Pr[i]] ]##
    return(A)

###from ab_pos and sam_dp access systemerror and fetal fract
def get_Ee():
    global num_homoe
    p, q = 0, 0
    num_homoe = 0
    for pos in Si_wndp.keys():
        if pos in aaaaaa :
            num_homoe +=1
            p += int(sam_dp[pos][0])
            q += int(sam_dp[pos][1])
            #print(pos+"\t"+str(sam_dp[pos][0])+"\t"+str(sam_dp[pos][1]))
        elif pos in bbbbbb:
            num_homoe +=1
            q += int(sam_dp[pos][0])
            p += int(sam_dp[pos][1])
            #print(pos+"\t"+str(sam_dp[pos][0])+"\t"+str(sam_dp[pos][1]))
        #print(p, q)
    try:
        e = float(q)/(p+q)
        #e=0.001
    except ZeroDivisionError:
        e = 0
    #print(p, q, e)
    p, q = 0, 0
    num_homo = 0
    for pos in Si_wndp.keys():
        #print(pos)
        if pos in aabbab :
            num_homo += 1 
            q += int(sam_dp[pos][0])
            p += int(sam_dp[pos][1])
            #print(pos)
        elif pos in bbaaab:
            #print(pos)
            num_homo += 1
            p += int(sam_dp[pos][0])
            q += int(sam_dp[pos][1])
            #print(2, Si_wndp[pos])
    try:    
        E = float(q)*2/(p+q)
    except ZeroDivisionError:
        E = 0
    #print(p, q, E)
    #print (num_homo)
    return(E, e, num_homo)
###from Si, ab_pos get B matrix
def get_B(Si):
    T = len(Si)
    B = np.zeros((T, 2), np.float)
    #P = np.zeros((T, 9), np.float)
    N = 0
    a = 0
    for t, item in enumerate(Si):
        pos = item[0]
                #global prob0
                #global prob1
        k = np.arange(0,int(item[5])+1)
        n = int(item[4]) + int(item[5])
        #print(pos,k,n)
        if pos in aaabaa:
            prob0 = (1-e-E+e/3)/2
            prob1 = float(1-e)/2
        elif pos in aaabab:
            prob0 = float(1-e)/2
            #print prob0
            prob1 = (1-e-E+e/3)/2
        elif pos in bbabab:
            prob0 = float(1-e)/2
            #print prob0
            prob1 = (1-e+E-e/3)/2
        elif pos in bbabbb:
            prob0 = (1-e+E-e/3)/2
            #print prob0
            prob1 = float(1-e)/2
        elif pos in abaaaa:
            prob0 = e
            #print prob0
            prob1 = (E-e/3)/2
        elif pos in abaaab:
            prob0 = (E-e/3)/2
            #print prob0
            prob1 = e
        elif pos in abbbab:   
            prob0 = 1-e-((E-e/3)/2)
            #print prob0
            prob1 = 1-e
        elif pos in abbbbb: 
            prob0 = 1-e
            #print prob0
            prob1 = 1-e-(E-e/3)/2
        rate1 = n*prob0
        rate2 = n*prob1
        binom0 = stats.poisson.pmf(k, rate1)
        binom1 = stats.poisson.pmf(k, rate2)
        si.append('\t'.join(Si[t] + [str(prob0), str(prob1), str(n), str(k[-1]), str(binom0[-1]), str(binom1[-1])]))
        #Si[t].append([prob0, prob1, n, k[-1], binom0[-1], binom1[-1]])
        #print(si)
        #print(Si[t], prob0, prob1, n, k[-1], binom0[-1], binom1[-1])
        P_hap0 = binom0[-1]/(binom0[-1]+binom1[-1])
        P_hap1 = binom1[-1]/(binom0[-1]+binom1[-1])
        B[t] = [P_hap0, P_hap1]
        #print("\t".join( [ str(n), str(k), str(prob0), str(prob1), str(round(binom0, 3)), str(round(binom1, 3)), str(round(P_hap0, 3)), str(round(P_hap1, 3))]))
        #print(B[t])
        N += n
        a += 1
    #print(N/a)
    return(B)
famvcf = open(inputFile,"r")
lines=famvcf.readlines()
Si = get_si(lines)
A = get_A(pos_hmm)
E, e ,num_homo = get_Ee()
B = get_B(Si)
Pi = [0.5, 0.5]
hmm = HMM(A, B, Pi, Si)
I, P_T = hmm.viterbi()
outFile1 = args.out1
outResults1 = []
num = -1
for i in I:
    num = num + 1
    outResults1.append(si[num]+'\t'+str(i))
outResults1 = '\n'.join(outResults1)
a = 0
for i in I:
    if i == 1:
        a += 1
finalOut = (str(float(a)/len(I)), str(P_T), str(len(pos_hmm)), str(E), str(e), str(num_homo), str(num_homoe),str(num_false), str(num_all))
outResults2 = '\t'.join(finalOut)
with open(outFile1, 'w') as file1:
    print (outResults1+"\n")
    print ('hap'+"\t"+outResults2)

