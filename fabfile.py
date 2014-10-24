import os
import logging
logging.root.setLevel(logging.DEBUG)

from cotton.salt_shaker import Shaker
from fabric.api import env as fab_env
from fabric.api import task, run, sudo, put, local, hide

@task
def vendor_formulas():
    shaker = Shaker(root_dir=os.path.dirname(fab_env.real_fabfile))
    shaker.install_requirements()

