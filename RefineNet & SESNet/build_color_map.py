import pickle

map_dict = dict()

map_dict['0'] = [0, 0, 0]
map_dict['255'] = [255, 255, 255]

with open('data/color_map', 'w') as f:
	pickle.dump(map_dict, f)