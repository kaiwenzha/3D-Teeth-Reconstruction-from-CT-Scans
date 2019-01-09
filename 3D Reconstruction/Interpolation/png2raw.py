import numpy
import os
import argparse
from PIL import Image

parser = argparse.ArgumentParser(
    description = 'Convert continuous PNG file to RAW file(volume data)')
parser.add_argument('-in', '--input_dir', default = '', help='Input directory for PNG files')
parser.add_argument('-out', '--output_dir', default = '', help='Output directory for RAW file')

args = parser.parse_args()

images = []
for dirName, subdirList, fileList in os.walk(args.input_dir):
    for filename in fileList:
        if '.png' in filename.lower():
            image = Image.open(os.path.join(dirName, filename))
            images.append(numpy.array(image))

dimZ = len(images)
dimX = images[0].shape[0]
dimY = images[0].shape[1]

ArrayRaw = numpy.zeros((dimZ, dimX, dimY), dtype=numpy.uint8)

# loop through all the image files
for idx, image in enumerate(images):
    # store the raw image data
    ArrayRaw[idx, :, :] = image

# save raw
ArrayRaw.tofile(os.path.join(args.output_dir,'output.raw'))