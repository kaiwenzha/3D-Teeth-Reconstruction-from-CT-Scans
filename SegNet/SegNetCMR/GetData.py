import os
import random

import numpy as np

import scipy.misc

class GetData():
    def __init__(self, data_dir):
        images_list =[]
        labels_list = []

        self.source_list = []

        examples = 0
        print("loading images")
        label_dir = os.path.join(data_dir, "Labels")
        image_dir = os.path.join(data_dir, "Images")
        for label_root, dir, files in os.walk(label_dir):
            for file in files:
                if not file.endswith((".png", ".jpg", ".gif")):
                    continue
                try:
                    folder = os.path.relpath(label_root, label_dir)
                    image_root = os.path.join(image_dir, folder)


                    image = scipy.misc.imread(os.path.join(image_root, file))
                    resize_image = scipy.misc.imresize(image, [256, 256], interp='nearest')
                    label = scipy.misc.imread(os.path.join(label_root, file))
                    resize_label = scipy.misc.imresize(label, [256, 256], interp='nearest')

                    images_list.append(resize_image[..., np.newaxis]/255)
                    labels_list.append((resize_label>1).astype(np.int64))
                    examples = examples + 1
                except Exception as e:
                    print(e)
        print("finished loading images")
        self.examples = examples
        print("Number of examples found: ", examples)
        self.images = np.array(images_list)
        self.labels = np.array(labels_list)

    def next_batch(self, batch_size):

        if len(self.source_list) < batch_size:
            new_source = list(range(self.examples))
            random.shuffle(new_source)
            self.source_list.extend(new_source)

        examples_idx = self.source_list[:batch_size]
        del self.source_list[:batch_size]

        return self.images[examples_idx,...], self.labels[examples_idx,...]

    def next_batch_test(self, start, batch_size):
        return self.images[start:start+batch_size, ...], self.labels[start:start+batch_size, ...]

