import csv 

file = 'accidentDB 1993 - 2024.csv'

columnNames = ['Date', 'Time', 'Fatalities']
newData = []

def getElement(element, array):
    for i,ele in enumerate(array):
        if ele == element:
            break
    return array[i+1]

def rowString2finalString(stringArray):
    newString = stringArray[0]
    for col in columnNames[1:]:
        newString += ',' + getElement(col, stringArray)
    return newString


with open(file) as file_obj: 
    reader_obj = csv.reader(file_obj) 
    for row in reader_obj: 
        newString = rowString2finalString(row)
        newData.append(newString)

with open('accidentDB res.csv', 'w') as f:
    labelString = 'Date,Time,Fatalities'
    f.write(f"{labelString}\n")
    for line in newData:
        f.write(f"{line}\n")