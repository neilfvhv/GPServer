import os

from flask import request, abort

from .. import en

from ..configs import algorithm_directory
from ..configs import upload_directory
from ..configs import result_directory
from ..models import User


# check that the name of file is allowed
def is_allowed_file(filename):
    return ('.' in filename) and (filename.rsplit('.', 1)[1].lower() in
                                  {'png', 'jpg', 'jpeg'})


# process image
def process_image(algorithm_type, algorithm_version, original_image_name):
    # define the processed image name
    processed_image_name = algorithm_type + '_' + algorithm_version + '_' + original_image_name
    # change working directory for MATLAB
    en.cd(os.path.join(algorithm_directory, algorithm_type, algorithm_version, 'code'))
    # run deblur algorithm
    en.run(os.path.join(upload_directory, original_image_name),
           os.path.join(result_directory, processed_image_name),
           nargout=0)
    # return the processed image name
    return processed_image_name


# check permission
def permission_check(func):
    def inner(*args, **kwargs):
        username = request.form['username']
        password = request.form['password']
        user = User.query.filter_by(username=username).first()
        if user.verify_password(password):
            return func(*args, **kwargs)
        else:
            abort(401)
    return inner
