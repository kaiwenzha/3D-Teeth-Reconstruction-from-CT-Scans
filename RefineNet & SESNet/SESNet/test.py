import time
import os
import numpy as np
import tensorflow as tf
import sys
import cv2

slim = tf.contrib.slim
sys.path.append(os.getcwd())
from nets import model as model
from matplotlib import pyplot as plt
from utils.tf_records import read_tfrecord_and_decode_into_image_annotation_pair_tensors

tf.app.flags.DEFINE_string('model_type', 'refinenet', '')
tf.app.flags.DEFINE_string('test_data_path', 'data/test.tfrecords', '')
tf.app.flags.DEFINE_string('gpu_list', '1', '')
tf.app.flags.DEFINE_integer('num_classes', 2, '')
tf.app.flags.DEFINE_string('checkpoint_path', 'checkpoints/', '')
tf.app.flags.DEFINE_string('result_path', 'result/', '')
tf.app.flags.DEFINE_integer('test_size', 384, '')

FLAGS = tf.app.flags.FLAGS

def main(argv=None):
	os.environ['CUDA_VISIBLE_DEVICES'] = FLAGS.gpu_list

	if not os.path.exists(FLAGS.result_path):
		os.makedirs(FLAGS.result_path)

	filename_queue = tf.train.string_input_producer([FLAGS.test_data_path], num_epochs=1)
	image, annotation = read_tfrecord_and_decode_into_image_annotation_pair_tensors(filename_queue)

	image_batch_tensor = tf.expand_dims(image, axis=0)
	annotation_batch_tensor = tf.expand_dims(annotation, axis=0)

	input_image_shape = tf.shape(image_batch_tensor)
	image_height_width = input_image_shape[1:3]
	image_height_width_float = tf.to_float(image_height_width)
	image_height_width_multiple = tf.to_int32(tf.round(image_height_width_float / 32) * 32)

	image_batch_tensor = tf.image.resize_images(image_batch_tensor, image_height_width_multiple)

	global_step = tf.get_variable('global_step', [], initializer=tf.constant_initializer(0), trainable=False)
	logits = model.model(FLAGS.model_type, image_batch_tensor, is_training=False)
	pred = tf.argmax(logits, dimension=3)
	pred = tf.expand_dims(pred, 3)
	pred = tf.image.resize_bilinear(images=pred, size=image_height_width)
	annotation_batch_tensor = tf.image.resize_bilinear(images=annotation_batch_tensor, size=image_height_width)
	annotation_batch_tensor = tf.div(annotation_batch_tensor, 255)

	pred = tf.reshape(pred, [-1, ])
	gt = tf.reshape(annotation_batch_tensor, [-1, ])

	acc, acc_update_op = tf.contrib.metrics.streaming_accuracy(pred, gt)
	miou, miou_update_op = tf.contrib.metrics.streaming_mean_iou(pred, gt, num_classes=FLAGS.num_classes)

	with tf.get_default_graph().as_default():
		global_vars_init_op = tf.global_variables_initializer()
		local_vars_init_op = tf.local_variables_initializer()
		init = tf.group(local_vars_init_op, global_vars_init_op)

		variable_averages = tf.train.ExponentialMovingAverage(0.997, global_step)
		saver = tf.train.Saver(variable_averages.variables_to_restore())

		gpu_options = tf.GPUOptions(per_process_gpu_memory_fraction=1.0)
		config = tf.ConfigProto(allow_soft_placement=True,
		                        log_device_placement=False,
		                        gpu_options=gpu_options)
		config.gpu_options.allow_growth = True

		with tf.Session(config=config) as sess:
			sess.run(init)
			ckpt_state = tf.train.get_checkpoint_state(FLAGS.checkpoint_path)
			model_path = os.path.join(FLAGS.checkpoint_path, os.path.basename(ckpt_state.model_checkpoint_path))
			print('Restore from {}'.format(model_path))
			saver.restore(sess, model_path)

			coord = tf.train.Coordinator()
			threads = tf.train.start_queue_runners(coord=coord)

			for i in range(150):
				start = time.time()
				image_np, annotation_np, pred_np, tmp_acc, tmp_miou = sess.run(
					[image, annotation, pred, acc_update_op, miou_update_op])
				_diff_time = time.time() - start
				print('{}: cost {:.0f}ms').format(i, _diff_time * 1000)
				# upsampled_predictions = pred_np.squeeze()
				# plt.subplot(131)
				# plt.imshow(image_np)
				# plt.subplot(132)
				# plt.imshow(annotation_np.squeeze(), cmap='gray')
				# plt.subplot(133)
				# plt.imshow(np.reshape(pred_np, (annotation_np.shape[0], annotation_np.shape[1])).squeeze(), cmap='gray')
				# plt.savefig(os.path.join(FLAGS.result_path, str(i) + '.png'))
				prediction = np.reshape(pred_np, (annotation_np.shape[0], annotation_np.shape[1])).squeeze() * 255
				cv2.imwrite(os.path.join(FLAGS.result_path, str(i) + '.png'), prediction)
			print('Test Finished !')

	coord.request_stop()
	coord.join(threads)


if __name__ == '__main__':
	tf.app.run()
