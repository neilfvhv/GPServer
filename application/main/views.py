import os

from flask import request, make_response, send_file, redirect

from werkzeug.utils import secure_filename

from . import main

from .utils import is_allowed_file
from .utils import process_image
from .utils import permission_check

from ..configs import upload_directory
from ..configs import result_directory


@main.route('/')
def index():
    """
            Just for test whether the server is ok or not.
    """

    return 'Server OK'


@main.route('/upload/<algorithm_type>/<algorithm_version>', methods=['POST'])
@permission_check
def upload(algorithm_type, algorithm_version):
    """
            Accept the image uploaded from the client, and process the image with
        the specific algorithm, then return the processed image to the client.
            Permission check is used here to verify whether the client has the
        permission to access this API in case of abusing use.

    :param algorithm_type: algorithm type - deblur
    :param algorithm_version: algorithm version - v1 (deblur)
    """

    # get the uploaded image: image (same with the name uploaded from client)
    original_image = request.files['image']

    # get the uploaded image name
    original_image_name = secure_filename(original_image.filename)

    # check that the filename is allowed
    # then, save to the folder for uploaded images
    if is_allowed_file(original_image.filename):
        original_image.save(os.path.join(upload_directory,original_image_name))
    else:
        redirect(500)

    try:
        # process the image
        processed_image_name = process_image(algorithm_type, algorithm_version, original_image_name)

        # make response for sending the processed image to client
        response = make_response(send_file(os.path.join(result_directory, processed_image_name)))

        # set headers for response
        response.headers["Content-Disposition"] = "attachment; filename=" + processed_image_name + ";"

        # success
        return response
    except:
        # internal server error
        redirect(500)
