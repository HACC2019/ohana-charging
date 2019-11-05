import pandas as pd
import numpy as np
import datetime

a_json = pd.read_csv('a_json.csv')
b_json = pd.read_csv('b_json.csv')


on_peak = datetime.datetime.strptime('17:00', '%H:%M')
mid_day = datetime.datetime.strptime('9:00', '%H:%M')
off_peak = datetime.datetime.strptime('22:00', '%H:%M')

#check energy vs amount
clean_a = np.array([])
noise_a = np.array([])
for index, row in a_json.iterrows():
    if (not(float(row['duration']) == 0.0)) and (float(row['amount']) == 0.0):
        # print(row['duration'], row['amount'])
        noise_a = np.append(noise_a, index)
        continue

    es_pay = 0
    start_time = datetime.datetime.strptime(row['startTime'], '%H:%M')
    if start_time >= mid_day:
        if start_time >= on_peak:
            if start_time >= off_peak:
                es_pay = row['energy']*0.54
            else:
                es_pay = row['energy']*0.57
        else:
            es_pay = row['energy']*0.49
    else:
        es_pay = row['energy']*0.54
    #if amount is off less than 10cents, take the result
    if abs(round(es_pay, 2) - float(row['amount'])) <= 0.1:
        clean_a = np.append(clean_a, index)
    else:
        noise_a = np.append(noise_a, index)

#keep index of row will be selected
clean_b = np.array([])
noise_b = np.array([])
for index, row in b_json.iterrows():
    if (not(float(row['duration']) == 0.0)) and (float(row['amount']) == 0.0):
        noise_b = np.append(noise_b, index)
        continue

    es_pay = 0
    start_time = datetime.datetime.strptime(row['startTime'], '%H:%M')
    if start_time >= mid_day:
        if start_time >= on_peak:
            if start_time >= off_peak:
                es_pay = row['energy']*0.54
            else:
                es_pay = row['energy']*0.57
        else:
            es_pay = row['energy']*0.49
    else:
        es_pay = row['energy']*0.54

    if (abs(round(es_pay, 2) - float(row['amount'])) <= 0.1):
        clean_b = np.append(clean_b, index)
    else:
        noise_b = np.append(noise_b, index)

#based on a and b array to pick value from a_json and b_json)
a_frame = a_json.iloc[clean_a,:]
b_frame = b_json.iloc[clean_b,:]

#to csv
a_frame.to_csv('clean_a.csv')
b_frame.to_csv('clean_b.csv')

#based on a and b array to pick value from a_json and b_json)
a_frame = a_json.iloc[noise_a,:]
b_frame = b_json.iloc[noise_b,:]

#to csv
a_frame.to_csv('noise_a.csv')
b_frame.to_csv('noise_b.csv')