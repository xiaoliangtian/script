#!/usr/bin/python2.6  
# -*- coding: utf-8 -*- 

import numpy as np

import sys

import math

from scipy import stats

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
	

	###get aaaaaa, bbbbbb, aabbab, bbaaab, abaaaa, abaaab, abbbab, abbbbb, aaabaa, aaabab, bbabab, bbabbb, Si_wndp{}, ftl{}

	with open(sys.argv[1],"r") as fr:
	
		lines = fr.readlines()
		
		for line in lines:
		
			items = line.strip().split()
			
					
			if line[0:5] != "chr11" :
				
				continue
						
			else:
				
				pos = items[1]		

                                
				if items[4] == ".":

					aaaaaa.append(pos)

					#print(1)

					Si_wndp[pos] = [pos, "0/0", "0/0", "0/0"]

					ftl[pos] = "0/0"

					#print(Si_wndp[pos])

				else:

					Fgt = items[4].split(":")[0]
				
					Mgt = items[5].split(":")[0]
					
					Pgt = items[6].split(":")[0]
					
					Sgt = items[7].split(":")[0]

					#FTgt = items[12].split(":")[0]	
                                        p = items[7].split(":")[3].split(",")[0]
                                           
                                        q = items[7].split(":")[3].split(",")[1]	

					Si_wndp[pos] = [pos, Fgt, Mgt, Pgt]
                                          
                                        sam_dp[pos] = [p, q]
					#print(sam_dp[pos])
					#print(Si_wndp[pos])

					#ftl[pos] = FTgt

					if Fgt== Mgt == "0/0":

						aaaaaa.append(pos)

						#print(Si_wndp[pos])
						
						
					if Fgt == Mgt == "1/1":
						
						bbbbbb.append(pos)

						#print(Si_wndp[pos])
						
					
					if Fgt == "0/0" and Mgt == "1/1":
						
						aabbab.append(pos)

						#print(Si_wndp[pos])
						
					if Fgt == "1/1" and Mgt == "0/0":
						
						bbaaab.append(pos)	

						#print(Si_wndp[pos])
										
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

					'''
					
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

					'''
		#print(len(Si_wndp),len(ftl))#28660
		hq_pos = sam_dp.keys()
		#print hq_pos
	

	
	###get depth of alt and ref of all hq_pos,sam_dp{}
        '''
	with open(sampvcf) as fr:
		
		lines = fr.readlines()
		
		for line in lines:
			
			items = line.strip().split()
			
			if line[0:5] != "chr11":
		
				continue

			else:

				qual = items[5]

				pos = items[1]

				depth = items[7].split(";")[0].split("=")[1]

				#print(line)

				if float(qual) > 30 and int(depth) > 20:

					#print("*" * 10, qual, dp)

					if items[7].find("DP4=") != -1:

						in_items = items[7].split(";")

						p, q = 0, 0

						for in_item in in_items:
							
							if in_item[0:4] == "DP4=":
								
								dp = in_item.split("=")[1].split(",")
								
								p += (int(dp[0])+int(dp[1]))
								
								q += (int(dp[2])+int(dp[3]))

						sam_dp[pos] = [p, q]

						#print(p, q)

					else:####为什么没有呢？？？

						#print(int(dp))

						p = depth

						q = 0

						sam_dp[pos] = [p, q]

						print(p, q)

	hq_pos = sam_dp.keys()

	#print(len(sam_dp), len(hq_pos))

	

	'''
        
	###将famvcf文件得到的pos与hq_pos求交集
	ll = [aaaaaa, bbbbbb, aabbab, bbaaab, abaaaa, abaaab, abbbab, abbbbb, aaabaa, aaabab, bbabab, bbabbb]

	for i in range(len(ll)):

		#print(len(ll[i]))

		ll[i] = list( set( ll[i] ).intersection( set( hq_pos ) ) )

		#print(len(ll[i]))

	[aaaaaa, bbbbbb, aabbab, bbaaab, abaaaa, abaaab, abbbab, abbbbb, aaabaa, aaabab, bbabab, bbabbb] = ll
	
	'''
	##pos for access system error and fetal fraction
	pos_Ee = []

	for i in [aaaaaa, bbbbbb, aabbab, bbaaab]:

		#print(len(i))

		pos_Ee = list( set(pos_Ee).union(set(i)))

		#print(len(pos_Ee))

	pos_Ee.sort()

	#system erroe
	pos_e = []

	for i in [aaaaaa, bbbbbb]:

		#print(len(i))

		pos_e = list( set(pos_e).union(set(i)))
	
	pos_e.sort()

	#fetal fraction
	pos_E = []

	for i in [aabbab, bbaaab]:

		#print(len(i))

		pos_E = list( set(pos_E).union(set(i)))

	pos_E.sort()
        
	'''
	##pos for Si
	pos_hmm = []

	for i in [abaaaa, abaaab, abbbab, abbbbb, aaabaa, aaabab, bbabab, bbabbb]:

		#print(len(i))
		
		pos_hmm = list( set(pos_hmm).union(set(i)))

	pos_hmm.sort()	

	#print(pos_hmm)	

	
	##make ftl qual hmm_pos
        
	'''	
	for key in ftl.keys():

		if key not in pos_hmm:

			del ftl[key]
	print(ftl[key])
	'''
	#print(len(pos_hmm), len(ftl), len(pos_Ee), len(Si_wndp), len(sam_dp), len(hq_pos))
        	
        
	###get observation sequence Si
	for pos in hq_pos:

		if pos in pos_hmm:

			Si_wndp[pos].append(sam_dp[pos][0])

			Si_wndp[pos].append(sam_dp[pos][1])

			#print(Si_wndp[pos])

			Si.append( Si_wndp[pos] )
		'''
		elif pos in pos_Ee:

			Si_wndp[pos].append(sam_dp[pos][0])

			Si_wndp[pos].append(sam_dp[pos][1])

			#print(Si_wndp[pos])
		'''

	#print(len(pos_Ee), len(pos_hmm), len(ftl), len(Si), len(hq_pos), len(sam_dp), len(Si_wndp))
	##validation of results
	
	Si.sort()
	#print(Si)
	return(Si)		
				

###from pos_hmm get A matrix with T*2*2(49*2*2)
def get_A(pos):

	T = len(pos)

	A = np.zeros((T, 2,2), np.float)

	Pr = range(T)

	#print(T)

	Pr[0] = 0

	for i in range(1, T):

		Pr[i] = ( float(pos[i]) - float(pos[i-1]) )/1000000
                #print(pos[i])

		A[i] = [ [1-Pr[i], Pr[i]], [Pr[i], 1-Pr[i]] ]##


	return(A)


###from ab_pos and sam_dp access systemerror and fetal fract
def get_Ee():

        p, q = 0, 0
        
        for pos in Si_wndp.keys():

                if pos in aaaaaa :

                        p += int(sam_dp[pos][0])

                        q += int(sam_dp[pos][1])

                        #print(p, q)

                elif pos in bbbbbb:

                        q += int(sam_dp[pos][0])

                        p += int(sam_dp[pos][1])

                        #print(2)

                #print(p, q)
        try:

                e = float(q)/(p+q)

        except ZeroDivisionError:

                e = 0
        
        #print(p, q, e)

        p, q = 0, 0

        for pos in Si_wndp.keys():

                
                if pos in aabbab :


                        q += int(sam_dp[pos][0])

                        p += int(sam_dp[pos][1])

                        #print(1, Si_wndp[pos])

                        


                elif pos in bbaaab:

                        p += int(sam_dp[pos][0])

                        q += int(sam_dp[pos][1])

                        #print(2, Si_wndp[pos])

        try:    

                E = float(q)*2/(p+q)

        except ZeroDivisionError:

                E = 0

        #print(p, q, E)


        return(E, e)

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
		
		
		n = (int(item[4]) + int(item[5]))

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
		
		#print (binom0,"\n",binom1)

       		print(Si[t], prob0, prob1, n, k[-1], binom0[-1], binom1[-1])

		P_hap0 = binom0[-1]/(binom0[-1]+binom1[-1])

		P_hap1 = binom1[-1]/(binom0[-1]+binom1[-1])

		B[t] = [P_hap0, P_hap1]

		#print("\t".join( [ str(n), str(k), str(prob0), str(prob1), str(round(binom0, 3)), str(round(binom1, 3)), str(round(P_hap0, 3)), str(round(P_hap1, 3))]))

		#print(B[t])

		N += n

		a += 1

	print(N/a)

	return(B)




		#print(P_hap0, P_hap1)



#Si = get_si( "/Users/asang/Desktop/important/original_vcf/family-0.vcf", 
#	"/Users/asang/Desktop/important/original_vcf/YZ3-004.vcf" )


#Si = get_si( "/Users/asang/Desktop/important/original_vcf/family-0.vcf", 
#	"/Users/asang/Desktop/rm_vcf/YZ3-004_rm.vcf" )

#filename = [ "yunzhongtest.txt" ]

#PATH = "./"

#PATH = "/Users/asang/Desktop/important/original_vcf/"

#famvcf = "/mnt/workshop/tianxl/50gene/20180402_yunzhong/result/test.txt_05"

famvcf = open(sys.argv[1],"r")

lines=famvcf.readlines()

#filename = [ "YZ3-004.vcf", "YZ3-005.vcf", "YZ3-006.vcf", "YZ3-007.vcf" ]

#for f in filename:


Si = get_si(lines)


#E, e = get_Ee()

A = get_A(pos_hmm)

E, e = get_Ee()

B = get_B(Si)

Pi = [0.5, 0.5]

hmm = HMM(A, B, Pi, Si)

I, P_T = hmm.viterbi()

print(I)

a = 0

for i in I:

	if i == 1:

		a += 1

print(float(a)/len(I), P_T, len(pos_hmm), E, e)
















