import tensorflow as tf


def loss_calc(logits, labels):
    cross_entropy = tf.nn.sparse_softmax_cross_entropy_with_logits(logits=logits, labels=labels)
    loss = tf.reduce_mean(cross_entropy)
    tf.summary.scalar('loss', loss)
    return loss


def evaluation(logits, labels):
    correct_prediction = tf.equal(tf.argmax(logits, 3) > 0, labels > 0)
    accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
    tf.summary.scalar('accuracy', accuracy)
    return accuracy

def IoU_calc(logits, labels):
    inter = tf.reduce_sum(tf.cast((tf.argmax(logits, 3) > 0) & (labels > 0), tf.float32), [1, 2])
    union = tf.reduce_sum(tf.cast((tf.argmax(logits, 3) > 0) | (labels > 0), tf.float32), [1, 2])
    IoU = tf.reduce_mean(tf.cast(inter/union, tf.float32))
    return IoU