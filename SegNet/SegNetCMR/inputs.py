import tensorflow as tf

def placeholder_inputs(batch_size):

    images = tf.placeholder(tf.float32, [batch_size, 256, 256, 1])
    labels = tf.placeholder(tf.int64, [batch_size, 256, 256])
    is_training = tf.placeholder(tf.bool)

    return images, labels, is_training