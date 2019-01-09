import os

import tensorflow as tf
import tensorflow.contrib.slim as slim

import SegNetCMR


WORKING_DIR = os.getcwd()
TRAINING_DIR = os.path.join(WORKING_DIR, 'Data', 'Training')
TEST_DIR = os.path.join(WORKING_DIR, 'Data', 'Test')

ROOT_LOG_DIR = os.path.join(WORKING_DIR, 'Output')
RUN_NAME = "Run_double"
LOG_DIR = os.path.join(ROOT_LOG_DIR, RUN_NAME)
TRAIN_WRITER_DIR = os.path.join(LOG_DIR, 'Train')
TEST_WRITER_DIR = os.path.join(LOG_DIR, 'Test')

CHECKPOINT_FN = 'model.ckpt'
CHECKPOINT_FL = os.path.join(LOG_DIR, CHECKPOINT_FN)


BATCH_NORM_DECAY = 0.95 #Start off at 0.9, then increase.
MAX_STEPS = 10000
BATCH_SIZE = 3
SAVE_INTERVAL = 50

TEST = True
def main():
    training_data = SegNetCMR.GetData(TRAINING_DIR)
    test_data = SegNetCMR.GetData(TEST_DIR)

    g = tf.Graph()

    with g.as_default():

        images, labels, is_training = SegNetCMR.placeholder_inputs(batch_size=BATCH_SIZE)

        arg_scope = SegNetCMR.inference_scope(is_training=True, batch_norm_decay=BATCH_NORM_DECAY)

        with slim.arg_scope(arg_scope):
            logits = SegNetCMR.inference(images, class_inc_bg=2)

        SegNetCMR.add_output_images(images=images, logits=logits, labels=labels)

        loss = SegNetCMR.loss_calc(logits=logits, labels=labels)

        train_op, global_step = SegNetCMR.training(loss=loss, learning_rate=1e-04)

        accuracy = SegNetCMR.evaluation(logits=logits, labels=labels)

        summary = tf.summary.merge_all()

        init = tf.global_variables_initializer()

        saver = tf.train.Saver([x for x in tf.global_variables() if 'Adam' not in x.name])

        sm = tf.train.SessionManager()

        with sm.prepare_session("", init_op=init, saver=saver, checkpoint_dir=LOG_DIR) as sess:

            sess.run(tf.variables_initializer([x for x in tf.global_variables() if 'Adam' in x.name]))

            train_writer = tf.summary.FileWriter(TRAIN_WRITER_DIR, sess.graph)
            test_writer = tf.summary.FileWriter(TEST_WRITER_DIR)

            global_step_value, = sess.run([global_step])

            print("Last trained iteration was: ", global_step_value)

            for step in range(global_step_value+1, global_step_value+MAX_STEPS+1):

                print("Iteration: ", step)

                images_batch, labels_batch = training_data.next_batch(BATCH_SIZE)

                train_feed_dict = {images: images_batch,
                                   labels: labels_batch,
                                   is_training: True}

                _, train_loss_value, train_accuracy_value, train_summary_str = sess.run([train_op, loss, accuracy, summary], feed_dict=train_feed_dict)

                if step % SAVE_INTERVAL == 0 and TEST:

                    print("Train Loss: ", train_loss_value)
                    print("Train accuracy: ", train_accuracy_value)
                    train_writer.add_summary(train_summary_str, step)
                    train_writer.flush()

                    images_batch, labels_batch = test_data.next_batch(BATCH_SIZE)

                    test_feed_dict = {images: images_batch,
                                      labels: labels_batch,
                                      is_training: False}

                    test_loss_value, test_accuracy_value, test_summary_str = sess.run([loss, accuracy, summary], feed_dict=test_feed_dict)

                    print("Test Loss: ", test_loss_value)
                    print("Test accuracy: ", test_accuracy_value)
                    test_writer.add_summary(test_summary_str, step)
                    test_writer.flush()

                    saver.save(sess, CHECKPOINT_FL, global_step=step)
                    print("Session Saved")
                    print("================")


if __name__ == '__main__':
    main()