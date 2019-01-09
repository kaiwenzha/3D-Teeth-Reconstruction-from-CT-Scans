import os
import scipy
import tensorflow as tf
import tensorflow.contrib.slim as slim

import SegNetCMR


WORKING_DIR = os.getcwd()
TRAINING_DIR = os.path.join(WORKING_DIR, 'Data', 'Training')
TEST_DIR = os.path.join(WORKING_DIR, 'Data', 'Test')

ROOT_LOG_DIR = os.path.join(WORKING_DIR, 'Output')
RUN_NAME = "Run_new"
LOG_DIR = os.path.join(ROOT_LOG_DIR, RUN_NAME)
TRAIN_WRITER_DIR = os.path.join(LOG_DIR, 'Train')
TEST_WRITER_DIR = os.path.join(LOG_DIR, 'Test')
OUTPUT_IMAGE_DIR = os.path.join(LOG_DIR, 'Image_Output')

CHECKPOINT_FN = 'model.ckpt'
CHECKPOINT_FL = os.path.join(LOG_DIR, CHECKPOINT_FN)


BATCH_NORM_DECAY = 0.95 #Start off at 0.9, then increase.
MAX_STEPS = 1000
BATCH_SIZE = 5
SAVE_INTERVAL = 50

def main():
    test_data = SegNetCMR.GetData(TEST_DIR)
    g = tf.Graph()

    with g.as_default():

        images, labels, is_training = SegNetCMR.placeholder_inputs(batch_size=BATCH_SIZE)

        arg_scope = SegNetCMR.inference_scope(is_training=False, batch_norm_decay=BATCH_NORM_DECAY)

        with slim.arg_scope(arg_scope):
            logits = SegNetCMR.inference(images, class_inc_bg=2)

        accuracy = SegNetCMR.evaluation(logits=logits, labels=labels)

        init = tf.global_variables_initializer()

        saver = tf.train.Saver([x for x in tf.global_variables() if 'Adam' not in x.name])

        sm = tf.train.SessionManager()

        with sm.prepare_session("", init_op=init, saver=saver, checkpoint_dir=LOG_DIR) as sess:

            sess.run(tf.variables_initializer([x for x in tf.global_variables() if 'Adam' in x.name]))

            accuracy_all = 0
            now = 0
            epochs = 30
            for step in range(epochs):
                images_batch, labels_batch = test_data.next_batch_test(now, BATCH_SIZE)

                test_feed_dict = {images: images_batch,
                                  labels: labels_batch,
                                  is_training: False}

                mask, accuracy_batch = sess.run([logits, accuracy], feed_dict=test_feed_dict)

                for idx in range(BATCH_SIZE):
                    name = str(step*BATCH_SIZE+idx)
                    resize_image = scipy.misc.imresize(mask[idx, :, :, 1].astype(int), [768, 768], interp='cubic')
                    scipy.misc.imsave(os.path.join(OUTPUT_IMAGE_DIR, '{}.png'.format(name)), resize_image)

                now += BATCH_SIZE
                accuracy_all += accuracy_batch

            accuracy_mean = accuracy_all / epochs
            print('accuracy:{}'.format(accuracy_mean))

if __name__ == '__main__':
    main()