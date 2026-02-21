numlist=[int(input('enter the numbers: '))for i in range(5)]
largest=smallest=numlist[1]
for i in numlist:
    if i>largest:
            largest=i
    if i<smallest:
        smallest=i
    
print('the largest number is: ',largest)
print('the smallest number is: ',smallest)
