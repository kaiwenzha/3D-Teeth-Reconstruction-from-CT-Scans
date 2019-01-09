import os
from utils.tf_records import write_image_annotation_pairs_to_tfrecord

image_root_path = './data/images'
label_root_path = './data/labels'

image_label_pairs = []
for mid_path in os.listdir(label_root_path):
	image_label_pairs.append([])
	for post_path in os.listdir(os.path.join(label_root_path, mid_path)):
		image_label_pairs[-1].append((os.path.join(image_root_path, mid_path, post_path), os.path.join(label_root_path, mid_path, post_path)))
	image_label_pairs[-1].sort()

train_pairs = image_label_pairs[0] + image_label_pairs[1]
test_pairs = image_label_pairs[1]

write_image_annotation_pairs_to_tfrecord(filename_pairs=train_pairs,
                                         tfrecords_filename='./data/train.tfrecords')

write_image_annotation_pairs_to_tfrecord(filename_pairs=test_pairs,
                                         tfrecords_filename='./data/test.tfrecords')



