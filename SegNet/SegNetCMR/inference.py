import tensorflow as tf
import tensorflow.contrib.slim as slim

from .layers import unpool_with_argmax

def inference_scope(is_training, batch_norm_decay=0.9):
    with slim.arg_scope([slim.conv2d],
                        activation_fn=tf.nn.relu,
                        weights_initializer=tf.truncated_normal_initializer(stddev=0.01),
                        normalizer_fn=slim.batch_norm,
                        stride=1,
                        padding='SAME'):

        with slim.arg_scope([slim.batch_norm],
                            is_training=is_training,
                            decay=batch_norm_decay) as sc:
            return sc

def inference(images, class_inc_bg = None):

    tf.summary.image('input', images, max_outputs=3)

    with tf.variable_scope('pool1'):
        net = slim.conv2d(images, 64, [3, 3], scope='conv1_1')
        net = slim.conv2d(net, 64, [3, 3], scope='conv1_2')
        net, arg1 = tf.nn.max_pool_with_argmax(net, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME', name='maxpool1')

    with tf.variable_scope('pool2'):
        net = slim.conv2d(net, 128, [3, 3], scope='conv2_1')
        net = slim.conv2d(net, 128, [3, 3], scope='conv2_2')
        net, arg2 = tf.nn.max_pool_with_argmax(net, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME', name='maxpool2')

    with tf.variable_scope('pool3'):
        net = slim.conv2d(net, 256, [3, 3], scope='conv3_1')
        net = slim.conv2d(net, 256, [3, 3], scope='conv3_2')
        net = slim.conv2d(net, 256, [3, 3], scope='conv3_3')
        net, arg3 = tf.nn.max_pool_with_argmax(net, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME', name='maxpool3')

    with tf.variable_scope('pool4'):
        net = slim.conv2d(net, 512, [3, 3], scope='conv4_1')
        net = slim.conv2d(net, 512, [3, 3], scope='conv4_2')
        net = slim.conv2d(net, 512, [3, 3], scope='conv4_3')
        net, arg4 = tf.nn.max_pool_with_argmax(net, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME', name='maxpool4')

    with tf.variable_scope('pool5'):
        net = slim.conv2d(net, 512, [3, 3], scope='conv5_1')
        net = slim.conv2d(net, 512, [3, 3], scope='conv5_2')
        net = slim.conv2d(net, 512, [3, 3], scope='conv5_3')
        net, arg5 = tf.nn.max_pool_with_argmax(net, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME', name='maxpool5')

    with tf.variable_scope('unpool5'):
        net = unpool_with_argmax(net, arg5, name='maxunpool5')
        net = slim.conv2d(net, 512, [3, 3], scope='uconv5_3')
        net = slim.conv2d(net, 512, [3, 3], scope='uconv5_2')
        net = slim.conv2d(net, 512, [3, 3], scope='uconv5_1')

    with tf.variable_scope('unpool4'):
        net = unpool_with_argmax(net, arg4, name='maxunpool4')
        net = slim.conv2d(net, 512, [3, 3], scope='uconv4_3')
        net = slim.conv2d(net, 512, [3, 3], scope='uconv4_2')
        net = slim.conv2d(net, 256, [3, 3], scope='uconv4_1')

    with tf.variable_scope('unpool3'):
        net = unpool_with_argmax(net, arg3, name='maxunpool3')
        net = slim.conv2d(net, 256, [3, 3], scope='uconv3_3')
        net = slim.conv2d(net, 256, [3, 3], scope='uconv3_2')
        net = slim.conv2d(net, 128, [3, 3], scope='uconv3_1')

    with tf.variable_scope('unpool2'):
        net = unpool_with_argmax(net, arg2, name='maxunpool2')
        net = slim.conv2d(net, 128, [3, 3], scope='uconv2_2')
        net = slim.conv2d(net, 64, [3, 3], scope='uconv2_1')

    with tf.variable_scope('unpool1'):
        net = unpool_with_argmax(net, arg1, name='maxunpool1')
        net = slim.conv2d(net, 64, [3, 3], scope='uconv1_2')
        logits = slim.conv2d(net, class_inc_bg, [3, 3], scope='uconv1_1')

    return logits
