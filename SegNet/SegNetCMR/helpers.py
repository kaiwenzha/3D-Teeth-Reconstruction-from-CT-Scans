import tensorflow as tf

def add_output_images(images, logits, labels):
    cast_labels = tf.cast(labels, tf.uint8) * 128
    cast_labels = cast_labels[...,None]
    tf.summary.image('input_labels', cast_labels, max_outputs=3)

    classification1 = tf.nn.softmax(logits = logits, dim=-1)[...,1]
    output_image_gb = images[...,0]
    output_image_r = classification1 + tf.multiply(images[...,0], (1-classification1))
    output_image = tf.stack([output_image_r, output_image_gb, output_image_gb], axis=3)
    tf.summary.image('output_mixed', output_image, max_outputs=3)

    output_image_binary = tf.argmax(logits, 3)
    output_image_binary = tf.cast(output_image_binary[...,None], tf.float32) * 128/255
    tf.summary.image('output_labels', output_image_binary, max_outputs=3)

    output_labels_mixed_r = output_image_binary[...,0] + tf.multiply(images[...,0], (1-output_image_binary[...,0]))
    output_labels_mixed = tf.stack([output_labels_mixed_r, output_image_gb, output_image_gb], axis=3)
    tf.summary.image('output_labels_mixed', output_labels_mixed, max_outputs=3)

    return

def add_test_output_images(images, logits):
    output_image_gb = images[..., 0]

    output_image_binary = tf.argmax(logits, 3)
    output_image_binary = tf.cast(output_image_binary[..., None], tf.float32) * 128 / 255
    tf.summary.image('test_prediction_labels', output_image_binary, max_outputs=3)

    output_labels_mixed_r = output_image_binary[..., 0] + tf.multiply(images[..., 0], (1 - output_image_binary[..., 0]))
    output_labels_mixed = tf.stack([output_labels_mixed_r, output_image_gb, output_image_gb], axis=3)
    tf.summary.image('test_prediction_labels_mixed', output_labels_mixed, max_outputs=3)

    return