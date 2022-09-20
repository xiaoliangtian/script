
def complement(sequence):
    trantab = str.maketrans('ACGTacgtRYMKrymkVBHDvbhd', 'TGCAtgcaYRKMyrkmBVDHbvdh')     # trantab = str.maketrans(intab, outtab)   # 制作翻译表
    string = sequence.translate(trantab)
    string = (''.join(string))    # str.translate(trantab)  # 转换字符
    return string

def rev(seq):
    string = (''.join(reversed(seq)))
    return string
