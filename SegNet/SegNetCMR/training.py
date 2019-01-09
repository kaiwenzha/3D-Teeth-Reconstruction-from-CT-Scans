import tensorflow as tf


def training(loss, learning_rate):

    global_step = tf.Variable(0, name='global_step', trainable=False)

    #This motif is needed to hook up the batch_norm updates to the training
    update_ops = tf.get_collection(tf.GraphKeys.UPDATE_OPS)
    with tf.control_dependencies(update_ops):
        optimizer = tf.train.AdamOptimizer(learning_rate=learning_rate)
        train_op = optimizer.minimize(loss=loss, global_step=global_step)

    return train_op, global_step