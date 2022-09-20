global num
num = 100
def func():
    global num
    num = 123
    print(num)
    num = 124

 
func()

print (num)