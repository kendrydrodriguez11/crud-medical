import os
import uuid


def user_directory_path(_, filename):
    ext = filename.split('.')[-1]
    filename = f'{uuid.uuid4()}.{ext}'
    return os.path.join('media/user_image', filename)
