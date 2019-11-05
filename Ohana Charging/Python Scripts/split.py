import numpy as np
import pandas as pd

data = pd.read_csv('Data_HACC.csv')

json_data = data[['Charge Station Name', 'Start Time', 'End Time', 'Duration', 'Energy(kWh)', 'Session Amount', 'Port Type', 'Payment Mode',]].copy()

#seconds conversion
for index, row in json_data.iterrows():
    (hours, minutes, seconds) = row[3].split(':')
    row[3] = int(hours)*3600 + int(minutes)*60 + int(seconds)
    json_data.iloc[index, json_data.columns.get_loc('Duration')] = row[3]

a_json = pd.DataFrame(columns=['Charge Station Name', 'Start Time', 'End Time', 'Duration', 'Energy(kWh)', 'Session Amount', 'Port Type', 'Payment Mode',])
b_json = pd.DataFrame(columns=['Charge Station Name', 'Start Time', 'End Time', 'Duration', 'Energy(kWh)', 'Session Amount', 'Port Type', 'Payment Mode',])

a_json = json_data.loc[json_data['Charge Station Name'] == 'A']
b_json = json_data.loc[json_data['Charge Station Name'] == 'B']


a_json.to_csv("a_json.csv")
b_json.to_csv("b_json.csv")
