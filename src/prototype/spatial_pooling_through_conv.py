import math
import tensorflow as tf
import tensorflow.keras as keras
import matplotlib.pyplot as plt
import numpy as np
import PIL

def spatial_pooling_4x4(img):
    img_w = img[0].shape[1]
    img_h = img[0].shape[0]

    bin_w = 4
    bin_h = 4

    _pool_size = (math.floor(img_h / bin_h), math.floor(img_w / bin_w))
    _pool_stride = (math.floor(img_h / bin_h), math.floor(img_w / bin_w))

    max_pool = keras.layers.MaxPooling2D(pool_size=_pool_size, strides=_pool_stride)

    return max_pool(img)


def construct_conv_model():
    model = keras.applications.MobileNetV2(
        alpha=1.0,
        include_top=False,
        weights="imagenet",
        input_shape=None,
        input_tensor=None,
        pooling=None,
        classes=1000,
        classifier_activation="softmax",
    )

    return model


img_dir = "/home/howard/project/object-detection/images/test/animal_4.jpg"

perfect_size = 512  # (7*7)

img = tf.expand_dims(
    tf.cast(tf.convert_to_tensor(np.asarray(PIL.Image.open(img_dir))), tf.float32),
    axis=0,
)
print(img.shape)

img_w = img[0].shape[1]
img_h = img[0].shape[0]

if img_h >= img_w:
    new_w = perfect_size
    new_h = math.ceil(img_h * (new_w / img_w))
else:
    new_h = perfect_size
    new_w = math.ceil(img_w * (new_h / img_h))

img = tf.image.resize(img, [new_h, new_w], preserve_aspect_ratio=False)

conv_model = construct_conv_model()
output_img = spatial_pooling_4x4(
    conv_model(keras.applications.mobilenet_v2.preprocess_input(img)).numpy()) 

# Output 4 x 4 x 1280
# Maybe add a single dense of 2048 neurons + softmax logits would do