wget https://github.com/mmatl/travis_debs/raw/master/xenial/mesa_18.3.3-0.deb
apt --fix-broken install
dpkg -i ./mesa_18.3.3-0.deb || true

apt-get install libosmesa6-dev
pip install PyOpenGL PyOpenGL_accelerate