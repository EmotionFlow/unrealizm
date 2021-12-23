import csv

csv_file = open("./result.csv", "r", errors="", newline="" )

f = csv.reader(csv_file, delimiter=",", skipinitialspace=True)
header = next(f)
print(header)
for row in f:
    if row[-1]:
        print(f'update orders set creditcard_id={row[-1]} where id={row[0]};')
